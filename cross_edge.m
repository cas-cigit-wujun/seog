function [ec, ef]=cross_edge(Gr, lth)
% Find the cross edges in intensity image.
%
% OUTPUTS:
% - ec: cross edge
% - ef: full possibility edge
    arguments
        Gr (:,:) double                     % Magnitude of OG
        lth (1,1) double = eps        %  Lower threshold
        % default value `eps` is the minimal float relative accuracy
    end
    [h, w] = size(Gr);
    rr = 2:h-1;
    cc = 2:w-1;
    zz = (Gr(rr,cc-1)<=Gr(rr,cc) & Gr(rr,cc)>Gr(rr,cc+1)) ...
         | (Gr(rr-1,cc)<Gr(rr,cc) & Gr(rr,cc)>=Gr(rr+1,cc));

    ec = false(h,w);
    ec(rr,cc)=zz;
    ef = Gr>=lth;
    ec = ec & ef;
end