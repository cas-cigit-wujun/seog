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