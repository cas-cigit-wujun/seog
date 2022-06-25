clear; clc;clf;

# load image package for Octave
pkg load image;

# sample folder
flir_dir = [pwd '\FLIR-samples\'];
ir_imgs = dir(flir_dir);

try
  # local random test, speed performance evaluation
  # img = randsample(ir_imgs(3:end), 1);
  #
  # or specific test
  img = ir_imgs(6);
  I = im2double(imread([flir_dir, img.name]));
  disp('Stylized Edge Extraction:')
  tic;
  r2 = 2;
  n = 16;
  seog = stylized_edge_og(I,r2,n);
  toc;
  imagesc([I seog]);
  axis image;
  colormap('gray');
catch
  disp('We have implemented this source code compatible with MATLAB and Octave, but before our paper is accepted, the Octave version cannot be tested, because the core functions are in the form of pcode, but Octave does not support it yet.');
end
