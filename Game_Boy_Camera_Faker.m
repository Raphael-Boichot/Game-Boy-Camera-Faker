    % Raphael BOICHOT 25/11/2021 E-paper module for NeoGB printer
    % multi OS compatibility improved by Cristofer Cruz 2022/06/21
    % Compatible with Matlab and Octave
    % image must be 4 colors maximum, which is the native output format
    clear
    clc
    close all
    upscaling_factor=4;
    Dithering_patterns = [0x2A, 0x5E, 0x9B, 0x51, 0x8B, 0xCA, 0x33, 0x69, 0xA6, 0x5A, 0x97, 0xD6, 0x44, 0x7C, 0xBA, 0x37, 0x6D, 0xAA, 0x4D, 0x87, 0xC6, 0x40, 0x78, 0xB6, 0x30, 0x65, 0xA2, 0x57, 0x93, 0xD2, 0x2D, 0x61, 0x9E, 0x54, 0x8F, 0xCE, 0x4A, 0x84, 0xC2, 0x3D, 0x74, 0xB2, 0x47, 0x80, 0xBE, 0x3A, 0x71, 0xAE];
    alpha=0.5;
    intensity=3;
    verbose=1;
    %written somewhere november 2024
    disp('-----------------------------------------------------------')
    disp('|Beware, this code is for GNU Octave ONLY !!!             |')
    disp('-----------------------------------------------------------')

    pkg load image % for compatibility with Octave

    delay=1;
    mkdir Image_out
    imagefiles = dir('Image_in/*.png');% the default format is png, other are ignored
    nfiles = length(imagefiles);    % Number of files found

    disp('Getting palette from border')
    border=imread('Borders.png');
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
      end

      %color reduction to 256 grayscale levels
      if not(isempty(map));%dealing with indexed images
        disp('Indexed image, converting to grayscale');
        a=ind2gray(a,map);
      end

      if layers>1%dealing with color images
        disp('Color image, converting to grayscale');
        a=rgb2gray(a);
      end


      if verbose==1;
      imshow(a);
      pause(delay)
      end


      %cropping step
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
      end

      disp('Resizing image to 128x128');
      %Resizing to 128*128
      a=imresize(a,[128,128],"linear");

      if verbose==1;
      imshow(a);
      pause(delay)
      end

      %increasing contrast
      disp('Increasing contrast');
      a=imadjust (a);

      if verbose==1;
      imshow(a);
      pause(delay)
      end

      disp('Simulating CMOS artifacts');
      %creating mask
      intensity=3;
      %adding vertical streaks
      mask=repmat([+intensity*ones(128,1),-intensity*ones(128,1)],1,64);
      %adding noise
      mask=mask+intensity*round(randn(128,128));
      %adding amplification artifacts
      amp_artifact=floor(17*rand())
      band=[zeros(1,8*amp_artifact),ones(1,128-8*amp_artifact)]-1;
      band=repmat(band,128,1);
      if rand<0.5
        band=rot90(band);
      end
      mask=mask+8*intensity*band;
      a=a+mask;

      if verbose==1;
      imshow(a);
      pause(delay)
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
      end

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
      end

      disp('Cropping to 128x112');
      a=a(9:120,:);

      if verbose==1;
      imshow(a);
      pause(delay)
      end

      disp('Adding borders');
      border(17:17+111,17:17+127)=a;

      if verbose==1;
      imshow(border);
      pause(delay)
      end

      disp('Resizing for social media');
      final_image=imresize(border,upscaling_factor,"nearest");
      disp('Saving image');
      imwrite(final_image,['./Image_out/Faked_',currentfilename(1:end-4),'.gif']);
      close all
    end
    disp('Done!')

