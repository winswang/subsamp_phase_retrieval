function Ref = getRef3D(X0, Y0, col, row, z, lambda)
E = ones(row, col);
nz = length(z);
Ref = zeros(row, col, nz);
phase3D = getPhase3D(X0, Y0, col, row, z, lambda);
for i=1:nz
    cE0=fftshift(fft2(E));

    cE=cE0.*conj(phase3D(:,:,i));

    Ref(:,:,i)=ifft2(ifftshift(cE));
end
end