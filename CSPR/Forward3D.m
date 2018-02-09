function E = Forward3D(obj, ref, nx, ny, nz, phase, mask, known_amp)
obj = reshape(MyV2C(obj), ny, nx, nz);
e = obj.*ref;
ef = zeros(ny,nx,nz);

for i=1:nz
    ef(:,:,i)=fftshift(fft2(ifftshift(e(:,:,i))));
end

cEsp=sum(ef.*phase,3);

E=fftshift((ifft2(ifftshift(cEsp))));
E_amp = abs(E);
E_phase = angle(E);
if nargin < 8
    known_amp = E_amp;
end

if nargin < 7
    mask = ones(ny,nx);
end
idx = mask == 1;
E_amp(idx) = known_amp(idx);
E = E_amp.*exp(1i*E_phase);
E = MyC2V(E(:));
end