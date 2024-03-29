# Omnidirectional Gradient and Its Application in Stylized Edge Extraction of Infrared Image

> **After the article is officially published, all source code will be published.**

# Abstract

​	Gradient computing is a low-level technology widely used in image processing. For large gradient magnitude, the pixel value in the field changes a lot, and for small gradient magnitude the pixel in the domain changes little. This is the basis of classical edge extraction algorithms, but it is often necessary to manually set thresholds to differentiate. This paper innovatively brings out the concept of omnidirectional gradient, which uses flexible convolution kernel radius and special law to calculate, and omnidirectional gradient pays more attention to gradient direction and analyzes the relationship and change of the gradient direction with different kernel radius. We present here an algorithm for stylized edge extraction based on omnidirectional gradient, overcoming the drawback of classical edge extraction algorithms that require manual thresholding. Experimental results show that the proposed method outperforms the classical edge extraction methods in terms of adaptive, consistent, and visually friendlier features for infrared imaging. In addition, the algorithm is fast and efficient, its result can be used as real-time input for subsequent applications.

## Keywords

`omnidirectional gradient`, `stylized edge extraction`, `infrared image`



# What is Omnidirectional Gradient(OG)?

OG is calculated with flexible kernel radius $r$ and specific law of some function $f(i,j)$.

![image-20220625123913312](README/image-20220625123913312.png)

# Why OG?

OG is calculated with flexible radius $r$ and specific law of some function $f(i,j)$. Therefore, OG has following benefit features:

- Fully compatible with traditional gradient calculation, e.g. if set the kernel radius $r=1$ and  $f(i,j) \in [\sqrt2,2,\sqrt2;2,0,2;\sqrt2,2,\sqrt2]$, it is equal to Sobel as shown in Fig. 2 (a).
- Noise insensitive with larger radius or specific law, but noise sensitive with smaller radius.
- Performing multiple OG calculations with different kernel radius on the same input image is equivalent to human vision observing oil paintings at different distances, their difference can help to determine the edge regions and the flat regions.

# Algorithm characteristics and effects

- Compute fast with $O(2MN)$ time complexity;
- The edge threshold is calculated adaptively, and it has good performance for infrared images with different signal strengths;
- The stylized edge is no longer a binary image. It is a grayscale image, which can reflect the signal intensity contrast, is more friendly to human vision, and retains more detailed information.

## Sample result of `seog` (this repo):

![image-20220625124210741](README/image-20220625124210741.png)

Compared to [Canny](https://en.wikipedia.org/wiki/Canny_edge_detector)：

![image-20220625124542050](README/image-20220625124542050.png)

# Key function

1) ## Calculate the OG operator

   `specialn` function (MATLAB version) of onion structure change law:

   ```matlab
   function [fx, fy] = fspecialn(r, fn)
   % Calculate the Omnidirectional Gradient operator at X/Y axises.
   % this is a simple special case of f(i,j), fn is changed related to n, n = max(|i|,|j|).
       arguments
           r int16                  % radius
           fn (1,:)  double         % decay function
       end
       % assert fn    
       assert(r>=1 && length(fn)==r);
       
       % calculate fx, fy without decay.    
       [x, y] = meshgrid(double(-r:r), double(-r:r));
       y = flipud(y); 
       fx = -x./(sqrt(x.^2+y.^2));
       fx(x==0 & y==0)=0;    
   
       fy = -y./(sqrt(x.^2+y.^2));
       fy(x==0 & y==0)=0;
       
       % apply decay factor according to fn and radius.
       if r>=1
           mf = zeros(2*r+1);
           for n = 1:r
               mf(max(abs(x), abs(y))==n)=fn(n);
           end
           fx = fx.*mf;
           fy = fy.*mf;
       end
   end
   ```

   another more flexible type `fspecialxy` (MATLAB version):

   ```matlab
   function [fx, fy] = fspecialxy(r, fxy)
   % calculate the Omnidirectional Gradient operator at X/Y axises,
   % `fxy` is the decay factor mask matrix, with the size of (2*r+1)x(2*r+1).
       arguments
           r int16                      % radius
           fxy (:,:)  double         % decay function
       end
       % assert fxy
       [h, w] = size(fxy);
       assert(r>=1 && h==w && h==(2*r+1));
       
       % calculate fx, fy without decay.    
       [x, y] = meshgrid(double(-r:r), double(-r:r));
       y = flipud(y); 
       fx = -x./(sqrt(x.^2+y.^2));
       fx(x==0 & y==0)=0;    
   
       fy = -y./(sqrt(x.^2+y.^2));
       fy(x==0 & y==0)=0;
       
       % apply decay factor mask matrix according to fxy.
       fx = fx.*fxy;
       fy = fy.*fxy;
   end
   ```

   

2) ## Evaluate the lower threshold adaptively

   `estimate_lower_threshold` function declaration (MATLAB version):

   > The source code will be published after the article is accepted.

   ```matlab
   function [lth, ep, low] = estimate_lower_threshold(Gr1, Gt1, Gt2, r, n)
   % Estimate the most reasonable lower threshold of `Gr1`.
   %
   % OUTPUTS:
   % - lth: Lower threshold value.
   % - ep: Edges percent
   % - low: Low noise image
       arguments
           Gr1  (:,:) double               % Magnitude of OG1
           Gt1  (:,:) double               % Angle of OG1, r=1.
           Gt2  (:,:) double               % Angle of OG2, r>=2
           r (1,1) double = 2            % radius of OG2, default is 2.
           n (1,1) double = 8           % Points smaller than n pixels are not considered
       end
   ```

   

3) ## Extract the stylized edge

   `stylized_edge_og` function declaration (MATLAB version):

   > The source code will be published after the article is accepted.

   ```matlab
   function [seog, lth]  = stylized_edge_og(I, r, n)
   % Stylized edge extraction based on Omnidirectional Gradient .
   %
   % OUTPUTS:
   % - seog : The Stylized edge output based on OG
   % - lth : The lower threshold of Gr1
       arguments
           I (:,:)  double       % Orignal image
           r (1,1) double        % radius `r` according to Gt2
           n (1,1) double  = 16  % Minimum search step, default is 16
       end
   ```



# Test environment

- **System**: `Windows 10 64-bit`
- **CPU**: `i7-7500U @ 2.70 GHz`
- **Memory**: `32.0 GB`
- **Software**: [`MATLAB R2020b Trial version`](https://www.mathworks.com/products/new_products/release2020b.html) or [`GNU Octave v7.1.0`](https://octave.org/download#ms-windows)
- **Dataset**: [(Berkeley Segmentation Dataset and Benchmark) BSDS500](http://www.eecs.berkeley.edu/Research/Projects/CS/vision/grouping/BSR/BSR_bsds500.tgz) is used to evaluate the stylized edge extraction effect of RGB color images, and the [FLIR thermal dataset ](https://www.flir.asia/oem/adas/adas-dataset-form/)is used to evaluate the stylized edge extraction effect of infrared images.



## How to run?

- For [`MATLAB R2020b Trial version`](https://www.mathworks.com/products/new_products/release2020b.html),  start MATLAB and open the test script file `test_seog_on_MATLAB.mlx`;
- For [`GNU Octave v7.1.0`](https://octave.org/download#ms-windows), start Octave and run the test script `test_seog_on_Octave.m`;

> **Note:**
>
> We have implemented this source code compatible with MATLAB and Octave, but before our paper is accepted, the Octave version cannot be tested, because the core functions are in the form of [`pcode`](https://ww2.mathworks.cn/help/matlab/ref/pcode.html?lang=en), but Octave does not support it yet.



   