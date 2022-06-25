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