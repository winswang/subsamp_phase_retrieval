function output = subsample_periodic(nx,ny,factor)
% this function is to give a subsampled mask periodically every "factor"
% pixel
unit = zeros(factor,factor);
unit(1,1) = 1;
tmp = repmat(unit,ceil(nx/factor),ceil(ny/factor));
output = tmp(1:ny,1:nx);
end