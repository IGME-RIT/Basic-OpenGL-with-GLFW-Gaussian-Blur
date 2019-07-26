/*
Title: Gaussian Blur
File Name: gaussianFrag.glsl
Copyright ? 2016
Author: David Erbelding
Written under the supervision of David I. Schwartz, Ph.D., and
supported by a professional development seed grant from the B. Thomas
Golisano College of Computing & Information Sciences
(https://www.rit.edu/gccis) at the Rochester Institute of Technology.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or (at
your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/


#version 400 core

in vec2 uv;
uniform sampler2D tex;

const int samples = 9; // Number of samples we want to take (this number is actually squared)
float weight[samples]; // This array will store weights to multiply our samples by
float mean = samples / 2; // Part of the gaussian equation, we want it in the middle of our sample pool
float standardDeviation = samples / 4; // The standard deviation. higher numbers will be more blurred, lower will be more accurate. Can't be less than 1
float sdsqrd = standardDeviation * standardDeviation * 2; // A precalculated value for the equation.

void main(void)
{

	// Generate an array of weights
	// This is the gaussian distribution formula.
	// The area under the curve is defined as being 1.
	// If we multiply a set pixels by these weights and add them together, we should end up with the same total color as we started with.
	// NOTE: In a more optimized solution, we would calculate these values once on the cpu, and send them to the gpu in a uniform buffer.
	for(int x = 0; x < samples; x++)
	{
		float exponent = -pow(x - mean, 2) / sdsqrd;
		weight[x] = pow(2.718, exponent) / pow(3.141 * sdsqrd, .5);
	}


	vec4 color = vec4(0, 0, 0, 0);

	// This function allows us to get the dimensions of a texture, (which in this case is the screen)
	vec2 screenSize = textureSize(tex, 0);

	// Loop over all pixels within a square
	// NOTE: An optmized solution would perform this operation as two passes, bluring horizontally, then vertically.
	// Basically, instead of sampling an NxN square each time, you would only need to do two Nx1 squares.
	// Conveniently, if you do the math, that method ends up giving the exact same result!
	for(int i = 0; i < samples; i ++)
	{
		for(int j = 0; j < samples; j ++)
		{
			// Each pixel is weighted using width and height weights multiplied. This makes pixels affect eachother in a circlular shape.
			color += texture(tex, uv + vec2(i / screenSize.x, j / screenSize.y)) * weight[i] * weight[j]; 
		}
	}

	// Once we have that coordinate, we can read from the texture at that location and output it to the screen.
	gl_FragColor = color;
}