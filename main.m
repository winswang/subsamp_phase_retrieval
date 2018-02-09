clear all; close all;
%% define canvas size
nx = 256;ny = 256;  % x: horizontal; y: vertical
X = nx*2; Y = ny*2; % in um

%% construct an object (1)
% amplitude:0--phantom
% amplitude:1--peranema
% no phase right now
% binary:1-- make the object binary
amplitude = 1;
binary = 0;
if amplitude == 1
    imread = 256 - rgb2gray(imread('peranema.png'));
    if binary == 1
        imread(imread<128) = 0;
        imread(imread>=128) = 255;
    end
    im = zeros(ny,nx);
    img = PlaceObject(im,imread,0.5,0.5,ny/size(imread,1)*0.7);
    img = 1 - img;
elseif amplitude == 0
    imread = phantom('Modified Shepp-Logan',min(nx,ny));
    im = zeros(ny,nx);
    img = PlaceObject(im,imread,0.5,0.5);
end
img_amp = abs(img);
img_phase = angle(img);

clear imread im binary amplitude
figure(1);
subplot(121);
imagesc(img_amp);axis equal;axis off;title('Original image (Amplitude)');
subplot(122);
imagesc(img_phase);axis equal;axis off;title('Original image (Phase)');

%% generate subsampling mask 
% mask_type: 1--uniformly random
% mask_type: 0--periodic
mask_type = 0;
percentage = 0.2;
if mask_type == 1
    mask = subsample_uni_rand(nx,ny,percentage);
elseif mask_type == 0
    mask = subsample_periodic(nx,ny,round(1/percentage));
end

%% propagation (2)
Propagation.wavelength = 530e-3;
Propagation.distance = 2e3;
Propagation.X = X;Propagation.nx = nx;
Propagation.Y = Y;Propagation.ny = ny;
Propagation.mask = ones(Propagation.ny,Propagation.nx);
if exist('mask','var')
    Propagation.mask = mask;
end
Propagation.field_ori = img;
Propagation.field_ori_amp = abs(Propagation.field_ori);
Propagation.field_ori_phase = angle(Propagation.field_ori);
Propagation.field = Propagation.field_ori;
Propagation = ASM(Propagation);
Propagation.subsamp_type = mask_type;
% generate hologram
% after propagation, Propagation.holo_complex is the field
% Propagation.hologram is the intensity
Propagation.hologram = Propagation.holo_complex.*conj(Propagation.holo_complex);
Propagation.hologram_amp = Propagation.holo_amp;
% display the subsampled hologram
Propagation = upsampleHolo(Propagation);
figure(2)
subplot(221);
imagesc(Propagation.hologram);axis equal;axis off;title('Hologram');
subplot(222)
imagesc(Propagation.hologram.*Propagation.mask);axis equal;axis off;title('Subsampled hologram');
subplot(223);
imagesc(Propagation.holo_upsamp);axis equal;axis off;title('Upsample');
subplot(224);
imagesc(Propagation.holo_upsamp - Propagation.hologram.*Propagation.mask);axis equal;axis off;title('Error');

%% back propagation estimate support
% use Propagation.holo_complex as the field for back propagation
Propagation.holo_complex = Propagation.holo_upsamp;
% back propagation
Propagation = bpASM(Propagation);
% calculate mse
psnr_obj_amp = psnr(abs(Propagation.field_bp),Propagation.field_ori_amp);
psnr_obj_phase = psnr(angle(Propagation.field_bp),Propagation.field_ori_phase);
sigma = 3;
Th = 0.15;
Propagation = supportSW(Propagation,sigma,Th);
figure(3);
subplot(121);
imagesc(abs(Propagation.field_bp));axis equal;axis off;title('back propagation');
subplot(122);
imagesc(Propagation.support);axis equal;axis off;title('estimate support 1st');

%% estimate reference 
Reference = Propagation;
% Reference.field = ones(ny,nx);
% Reference = ASM(Reference);
Reference.holo_complex = ones(ny,nx);
Reference = bpASM(Reference);
%% iterative reconstruction (5)
iter = 200;
support_iter = 20;
a = 0.8; % a factor
b = 0.9;

for i = 1:iter
    % back propagation
    Propagation = bpASM(Propagation);
    psnr_obj_amp(i) = psnr(abs(Propagation.field_bp),Propagation.field_ori_amp);
    psnr_obj_phase(i) = psnr(angle(Propagation.field_bp),Propagation.field_ori_phase);
    % every 20 steps, update support
    if mod(i,support_iter) == 0
        Propagation = supportSW(Propagation,sigma*a,Th*b,1);
        j = i/support_iter;
        row = ceil(iter/support_iter/4);
        figure(4);
        subplot(row,4,j);
        imagesc(Propagation.support);axis equal;axis off;title(num2str(j));
    end
    % apply support constraint
    Propagation.field_bp = Propagation.field_bp.*Propagation.support + (1 - Propagation.support).*Reference.field_bp;
    % forward propagation
    Propagation.field = Propagation.field_bp;
    Propagation = ASM(Propagation);
    % update hologram amplitude
    Propagation = updateAmplitude(Propagation);
    
end
% show recovered
figure(5);
subplot(221);
imagesc(abs(Propagation.field_bp));axis equal;axis off;title('Recovered amplitude');
subplot(222);
Propagation.amp_res = abs(Propagation.field_bp) - abs(Propagation.field_ori);
imagesc(Propagation.amp_res);axis equal;axis off;title('Residual (amplitude)');
subplot(223);
imagesc(angle(Propagation.field_bp));axis equal;axis off;title('Recovered phase');
subplot(224);
Propagation.phase_res = angle(Propagation.field_bp) - angle(Propagation.field_ori);
imagesc(Propagation.phase_res);axis equal;axis off;title('Residual (phase)');
% show psnr
figure(7);
plot(psnr_obj_amp);hold on
plot(psnr_obj_phase);xlabel('Iterations');ylabel('PSNR');
legend('amplitude','phase');























