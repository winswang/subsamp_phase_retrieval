function output = subsample_uni_rand(nx,ny,p,pixel)
% this function draws uniformly random mask according to the percentage of
% p on a canvas (nx*ny)
% pixel: specify the random procedure on pixel*pixel basis
if nargin < 4
    pixel = 1;
end
if p > 1
    error('percentage should be smaller than 1');
end
canvas = zeros(round(ny/pixel),round(nx/pixel));
randnum = rand(size(canvas));
idx = randnum <= p;
canvas(idx) = 1;
output = imresize(canvas,[ny,nx],'nearest');
end