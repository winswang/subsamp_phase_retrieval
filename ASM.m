function obj = ASM(obj)
% Angular spectrum method
% the function receives an object field E0 at wavelength lambda
% and returns the magnitude I (E*conj(E)) after distance z
% dx, dy are spatial resolution
k = 2*pi/obj.wavelength;
[row, col] = size(obj.field);

dx = obj.X/col; dy = obj.Y/row; % spatial frequency
Kx = 2*pi/dx; Ky = 2*pi/dy;
kx = linspace((-Kx/2), (Kx/2), col);
ky = linspace((-Ky/2), (Ky/2), row);

[kxgrid, kygrid] = meshgrid(kx, ky);

% construct the circle function
circ = sqrt(kxgrid.^2 + kygrid.^2)/k;
circ(circ>1) = 0;
circ(circ<=1) = 1;

F = fftshift(fft2(ifftshift(obj.field)));
factor = exp(1i*obj.distance*sqrt(k^2 - kxgrid.^2 - kygrid.^2));
E = fftshift(ifft2(ifftshift(F.*factor.*circ)));

obj.holo_complex = E;
obj.holo_amp = abs(E);
obj.holo_phase = angle(E);
end