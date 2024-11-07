   ## Raphael BOICHOT 03/11/2024
   clear
   clc
   close all
   upscaling_factor=4;  ##for image_output
   Dithering_patterns = [0x2A, 0x5E, 0x9B, 0x51,0x8B, 0xCA, 0x33, 0x69,0xA6, 0x5A, 0x97, 0xD6,0x44, 0x7C, 0xBA, 0x37,0x6D, 0xAA, 0x4D, 0x87,0xC6, 0x40, 0x78, 0xB6,0x30, 0x65, 0xA2, 0x57,0x93, 0xD2, 0x2D, 0x61,0x9E, 0x54, 0x8F, 0xCE,0x4A, 0x84, 0xC2, 0x3D,0x74, 0xB2, 0x47, 0x80,0xBE, 0x3A, 0x71, 0xAE];
   ##dithering pattern of the Game Boy Camera
   alpha=0.5;           ##2D enhancement ratio, same formula as 82FP datasheet
   intensity_streaks=3; ##old sensors, take 4 or more, new sensors, take 3 or less, 0 for 83FP
   intensity_noise=2;   ##should be about the same as previous, 0 for animated gifs
   intensity_shadow=16; ##around this value is OK for 82FP, 0 for animated gifs
   saturation=0.05;     ##constrast saturation to mimick the sensor poor dynamics
   verbose=1;           ##0 for fast mode
   delay=0.25;          ##display delay, may be 0
   dashboy_mode=0;      ##stops processing at the MAC_GBD step

   disp('-----------------------------------------------------------')
   disp('|Beware, this code is only compatible with GNU Octave !!! |')
   disp('-----------------------------------------------------------')

   pkg load image ## for compatibility with Octave

   mkdir Image_out
   mkdir Image_steps
   imagefiles = dir('Image_in/*.png');## the default format is png, other are ignored
   nfiles = length(imagefiles);    ## Number of files found

   disp('Getting palette from border')
   if dashboy_mode==0;
     border=imread('Borders.png');
   else
     border=imread('Dashboy.png');
   end

   border=border(:,:,1);
   palette=unique(border);

   for k=1:1:nfiles
     disp('############################################')
     currentfilename = imagefiles(k).name;
     disp(['Converting image ',currentfilename,' in progress...'])
     [a,map]=imread(['Image_in/',currentfilename]);
     [height, width, layers]=size(a);

     if verbose==1;
       imshow(a);
       pause(delay)
       saveas(gcf,'./Image_steps/step_00.gif');
     end

     ##color reduction to 256 grayscale levels
     if not(isempty(map));##dealing with indexed images
       disp('Indexed image, converting to grayscale');
       a=ind2gray(a,map);
     end

     if layers>1##dealing with color images
       disp('Color image, converting to grayscale');
       a=rgb2gray(a);
     end

     if verbose==1;
       imshow(a);
       pause(delay)
       saveas(gcf,'./Image_steps/step_01.gif');
     end

     ##cropping step
     disp('Cropping image');
     [height, width, layers]=size(a);
     if height>width
       max_dim=height;
       start=round((height-width)/2);
       a=a(start:start+width,:);
     else
       max_dim=width;
       start=round((width-height)/2);
       a=a(:,start:start+height);
     end

     if verbose==1;
       imshow(a);
       pause(delay)
       saveas(gcf,'./Image_steps/step_02.gif');
     end

     disp('Resizing image to 128x128');
     ##Resizing to 128*128
     a=imresize(a,[128,128],"linear");

     if verbose==1;
       imshow(a);
       pause(delay)
       saveas(gcf,'./Image_steps/step_03.gif');
     end

     ##increasing contrast
     disp('Increasing contrast');
     a=imadjust (a, stretchlim (a, saturation), [0; 1]);##autocontrast with 5% saturation at both spectrum end

     if verbose==1;
       imshow(a);
       pause(delay)
       saveas(gcf,'./Image_steps/step_04.gif');
     end

     disp('Simulating CMOS artifacts');
     ##adding vertical streaks
     mask=repmat([+intensity_streaks*ones(128,1),-intensity_streaks*ones(128,1)],1,64);
     a=a+mask;

     if verbose==1;
       imshow(a);
       pause(delay)
       saveas(gcf,'./Image_steps/step_05.gif');
     end

     ##adding Gaussian noise
     mask=intensity_noise*round(randn(128,128));
     a=a+mask;

     if verbose==1;
       imshow(a);
       pause(delay)
       saveas(gcf,'./Image_steps/step_07.gif');
     end

     ##adding amplification artifacts (shadows)
     shadow_position=floor(17*rand());
     band=[zeros(1,8*shadow_position),ones(1,128-8*shadow_position)]-1;
     band=repmat(band,128,1);
     if rand<0.5
       band=rot90(band);##this artifact is horizontal in high light, vertical in low light
     end
     mask=intensity_shadow*band;
     a=a+mask;

     if verbose==1;
       imshow(a);
       pause(delay)
       saveas(gcf,'./Image_steps/step_08.gif');
     end

     ##2D edge enhancement
     disp('Adding 2D enhancement 50%');
     edge=double(a);
     alpha=0.5;
     for (y = 2:1:128-1)
       for (x = 2:1:128-1)
         b(y,x)=(4*edge(y,x)-edge(y-1,x)-edge(y+1,x)-edge(y,x-1)-edge(y,x+1)).*alpha;
       end
     end
     a(1:127,1:127)=uint8(double(a(1:127,1:127))+b);

     if verbose==1;
       imshow(a);
       pause(delay)
       saveas(gcf,'./Image_steps/step_09.gif');
     end

     if dashboy_mode==0;
       ##Bayer dithering (what a Game Boy Camera does)
       disp('Appplying Bayer Dithering');
       Bayer_matDG_B=[];
       Bayer_matLG_DG=[];
       Bayer_matW_LG=[];

       counter = 1;
       for (y = 1:1:4)
         for (x = 1:1:4)
           Bayer_matDG_B(y,x) = Dithering_patterns(counter);
           counter = counter + 1;
           Bayer_matLG_DG(y,x) = Dithering_patterns(counter);
           counter = counter + 1;
           Bayer_matW_LG(y,x) = Dithering_patterns(counter);
           counter = counter + 1;
         end
       end

       for (y = 1:4:128)
         for (x = 1:4:128)
           Bayer_matDG_B_2D(y:y+3,x:x+3)=Bayer_matDG_B;
           Bayer_matLG_DG_2D(y:y+3,x:x+3)=Bayer_matLG_DG;
           Bayer_matW_LG_2D(y:y+3,x:x+3)=Bayer_matW_LG;
         end
       end

       for (y = 1:1:128)
         for (x = 1:1:128)
           pixel = a(y,x);
           if (pixel < Bayer_matDG_B_2D(y,x));
             pixel_out = palette(1);
           end
           if ((pixel >= Bayer_matDG_B_2D(y,x)) && (pixel < Bayer_matLG_DG_2D(y,x)));
             pixel_out = palette(2);
           end
           if ((pixel >= Bayer_matLG_DG_2D(y,x)) && (pixel < Bayer_matW_LG_2D(y,x)));
             pixel_out = palette(3);
           end
           if (pixel >= Bayer_matW_LG_2D(y,x));
             pixel_out = palette(4);
           end
           a(y,x) = pixel_out;
         end
       end

       if verbose==1;
         imshow(a);
         pause(delay)
         saveas(gcf,'./Image_steps/step_10.gif');
       end
     end
     disp('Cropping to 128x112');
     a=a(9:120,:);

     if verbose==1;
       imshow(a);
       pause(delay)
       saveas(gcf,'./Image_steps/step_11.gif');
     end

     disp('Adding borders');
     border(17:17+111,17:17+127)=a;

     if verbose==1;
       imshow(border);
       pause(delay)
       saveas(gcf,'./Image_steps/step_12.gif');
     end

     disp('Resizing for social media');
     final_image=imresize(border,upscaling_factor,"nearest");
     disp('Saving image');
     imwrite(final_image,['./Image_out/Faked_',currentfilename(1:end-4),'.gif']);
     close all
   end
   disp('Done!')

