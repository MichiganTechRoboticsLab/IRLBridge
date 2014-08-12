function [ out ] = manICP( orig, match )
%This function is a basic computation of icp

%calculate distances to all other points
for jj=1:size(orig,1)
    
    disp('next');
    
    samp = orig(jj,:);
    d2_orig = zeros(size(orig,1),1);
    for kk=1:size(orig,1)
        cur = orig(kk,:);
        d2_orig(kk) = (samp(1)-cur(1))^2 + (samp(2)-cur(2))^2;
    end
    
    
    
end

end

