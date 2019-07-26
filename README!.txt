Documentation Author: Niko Procopi 2019

This tutorial was designed for Visual Studio 2017 / 2019
If the solution does not compile, retarget the solution
to a different version of the Windows SDK. If you do not
have any version of the Windows SDK, it can be installed
from the Visual Studio Installer Tool

Welcome to the Gaussian Blur Tutorial!
Prerequesites: Render-To-Texture

In the last tutorial, we rendered a scene,
saved a screenshot of the scene to a texture, and 
then passed the texture to another shader, which 
changed the image by warping it, then sending it 
to the screen.

In this tutorial, we will be making the screen blurry,
with almost the exact same code. We will render a 
scene, take a screenshot of the scene, pass it back 
to the GPU, and we will apply a blurry effect.

The main focus here is Assets/gaussianFrag.glsl
To blur a pixel, we take the color of the pixel, and 
the surrounding pixels, and get the average color
of all 9 pixels.

-- This is not real code, just simplified --
-- For real code, scroll down --

For example, if we have a 2D array of pixels:
	pixels[1920][1080]
	
pixel[5][5] =
	pixel[4][4] +
	pixel[4][5] +
	pixel[4][6] +
	pixel[5][4] +
	pixel[5][5] +
	pixel[5][6] +
	pixel[6][4] +
	pixel[6][5] +
	pixel[6][6];
pixel[5][5] /= 9;

If we are on the edge, and if we are trying to
blur pixel [0][0], then it will look for pixels
outside of our frame

pixels[-1][-1]
pixels[-1][0]
pixels[-1][1], etc

OpenGL will default these pixels to black, so the
edge pixels will be slightly darker than the
rest of our pixels

-- Real Code --
We have a number of samples for each pixel
	const int samples = 9;
	
This is NOT the number of pixels we take into
consideration; this is the number of pixels
vertically and horizontally. That means 81
pixels are used to calculate the blurriness of one pixel
	
We have an array hold the weight of each
surrounding pixel. This tells the GPU
how much of each pixel to take into consideration
	float weight[samples];

When using the surrounding pixels to blur the
center pixel, pixels closer to the center should
have more impact on the center, than pixels on
the outside. That is why we have the weight values

Inside this 'for' loop, we use a gaussian 
distribution formula, the weight decreases as 'i'
increases, so that pixels far from the center have
less weight and pixels close to the center have more 
weight
	for(int x = 0; x < samples; x++)
	{
		float exponent = -pow(x - mean, 2) / sdsqrd;
		weight[x] = pow(2.718, exponent) / pow(3.141 * sdsqrd, .5);
	}
	
We set the color of the center pixel (of the final image),
to zero by default, before we start writing to it:
	vec4 color = vec4(0, 0, 0, 0);
	
We get the size dimensions of our texture
	vec2 screenSize = textureSize(tex, 0);
	
We add the weighted value of all surrounding
pixels (from the first pass), to get the blurred 
color of the center pixel in the final image:
	for(int i = 0; i < samples; i ++)
	{
		for(int j = 0; j < samples; j ++)
		{
			// Each pixel is weighted using width and height weights multiplied. This makes pixels affect eachother in a circlular shape.
			color += texture(tex, uv + vec2(i / screenSize.x, j / screenSize.y)) * weight[i] * weight[j]; 
		}
	}
	
Set the final color of the pixel to color:
	gl_FragColor = color;