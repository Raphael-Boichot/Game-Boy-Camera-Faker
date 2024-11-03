# The Game Boy Camera Faker

## Why?
Because it has to be done, this [GNU Octave code](https://octave.org/) allows to convert any image in Game Boy Camera style. GNU Octave scripts can be interpreted within their dedicated interface (Octave GUI) or in command line (Octave CLI). There is no dependencies at all, once installed, Octave is able to run all codes out of the box. There are tons of codes yet doing this but most are just crap. My goal is to make fake Game Boy Camera images impossible to recognize among legit ones.

## How ?
Just drop images in **png format** in ./Image_in folder and run the code. Converted images will appear in the ./Image_out folder. There are options you can play with but the default parameters are the closest as possible to what gives a Game Boy Camera. It perfectly mimicks all visual artifacts of the Mitsubishi M64282FP CMOS sensor and the dithering pattern used in the Game Boy Camera.

## What is the code doing ?
In this order (because it is important):
- It converts any color images to grayscales;
- It crops the image to make a square one;
- It resizes the image to 128x128 pixels;
- It enhances constrast in order to simulate the reduced sensor dynamic sensitivity;
- It creates a map simulating Game Boy Camera sensor artifacts (vertical stripes, Gaussian noise and amplification shadows) and apply it to the image;
- It applies the 2D enhancement algorithm of the M64282FP sensor;
- It applies the dithering algorithm of the Game Boy Camera;
- It finally crops the image to 112x128 and add border. Palette of the image is deduced from the border.

**Animation steps (with effects a bit exaggerated)**
![](Animation.gif)

## Anything else ?
The repo comes with a similar code allowing faking a Game Boy Printer. Same principle, but it mimicks paper strips coming out a Game Boy Printer. You can choose the paper color, it is optimized for publishing on social media. It is also implemented in the [Game Boy Camera Android manager](https://github.com/Mraulio/GBCamera-Android-Manager).

## Showcase
![](Pulp.gif)

The code does not directly convert animated gifs to animated gifs because it would break the tool chain but you can easily decompose gifs, convert them in batch with the code and animate back the converted frames with UnFREEz (provided, not my code) for example.

This code is probably easy to convert to Python or another langage intercacing a webcam. It's up to you to deal with that.

## Acknowledgements
- [Andreas Hahn](https://github.com/HerrZatacke/dither-pattern-gen) for documenting the Game Boy Camera Bayer Dithering.
- [Brian Khuu](https://github.com/mofosyne) for the idea.
