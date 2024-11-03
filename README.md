# The Game Boy Camera Faker

## Why?
Because it has to be done, this [GNU Octave code](https://octave.org/) allows to convert any image in Game Boy Camera style. GNU Octave scripts can be interpreted within their dedicated interface (Octave GUI) or in command line (Octave CLI). There is no dependencies at all, once installed, Octave is able to run all codes out of the box.

## How ?
Just drop images in png format in ./Image_in folder and run the code. Converted images will appear in the ./Image_out folder. There are options you can play with but the default parameters are the closest as possible to what gives a Game Boy Camera.

## Anything else ?
The repo comes with a similar code allowing faking a Game Boy Printer. Same principle, but it mimicks paper strips coming out a Game Boy Printer. You can choose the paper color, it is optimized for publishing on social media. It is also implemented in the [Game Boy Camera Android manager](https://github.com/Mraulio/GBCamera-Android-Manager).

## Showcase
![](Pulp.gif)

## Acknowledgements
- [Andreas Hahn](https://github.com/HerrZatacke/dither-pattern-gen) for documenting the Game Boy Camera Bayer Dithering.
- [Brian Khuu](https://github.com/mofosyne) for the idea.
