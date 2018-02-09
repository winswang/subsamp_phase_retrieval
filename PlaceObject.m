function output = PlaceObject(canvas,image,pos_x,pos_y,factor)
% this function places an object (image) on the canvas
% pos_x,pos_y: a ratio (on x, y) that designates the center of target
% position over the whole image
% factor: resize if specify
if nargin < 5
    factor = 1;
end
if size(image,3) == 3
    % image is rgb
    image = rgb2gray(image);
end
if ~isa(image, 'double')
    image = im2double(image);
end
if size(canvas,3) == 3
    % image is rgb
    canvas = rgb2gray(canvas);
end
if ~isa(canvas, 'double')
    canvas = im2double(canvas);
end

image = imresize(image,factor,'nearest');
[n1,n2] = size(image);

[ny,nx] = size(canvas);
p1 = round(ny*pos_y-n1/2);p2 = round(nx*pos_x-n2/2);

blank = zeros(ny,nx);
blank(1:n1,1:n2) = image;

blank = circshift(blank,[p1,p2]);

output = canvas + blank;
output = output/max(output(:));
end