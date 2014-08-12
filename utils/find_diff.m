function [X,a_new,b_new] = find_diff(base,tomatch,d)
%This function takes two point clouds (whose points line up) and computes
%their rotation/ translation difference.  It returns the data as a vector
%of the following format: X = [cos(theta) sin(theta) Tx Ty]'

%the 'd' is the divisor to split the data-set.  if there are one hundred
%points, it will divide it into a set ~1/3 the size

if(size(base,1) ~= size(tomatch,1))
    
    if(size(base,1)<size(tomatch,1))
        tomatch = tomatch(1:size(base,1),:);
    else
        base = base(1:size(tomatch,1),:);
    end
    
end

if d > 1
    base = base(1:d:end,:);
    tomatch = tomatch(1:d:end,:);
    a_new = base;
    b_new = tomatch;
else
    a_new = base;
    b_new = tomatch;
end
%setup coefficient matrix
M=zeros(2*size(base,1),4);
%define coefficient matrix

for kk=1:2:size(base,1)*2
    
    ind = round(kk/2);
    
    M(kk,:)   = [base(ind,1) base(ind,2)  1 0];
    M(kk+1,:) = [base(ind,2) -base(ind,1) 0 1];
    
    N(kk)   = tomatch(ind,1);
    N(kk+1)   = tomatch(ind,2);
    
end

%Computer least squares of data
X=M\N';

end