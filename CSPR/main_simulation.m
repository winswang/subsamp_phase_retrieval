clear all;close all
%% image
img_amp = im2double(rgb2gray(imread('peppers.png')));img_amp = img_amp(1:256,1:256);
img_phase = im2double(rgb2gray(imread('peppers.png')));img_phase = img_phase(1:256,1:256);img_phase = img_phase';
complex = img_amp.*exp(1i*img_phase);
% check image
figure(1);
subplot(121);imagesc(abs(complex));axis equal;axis off;title('Original amplitude');
subplot(122);imagesc(angle(complex));axis equal;axis off;title('Original phase');

%% forward and backward
[ny,nx] = size(complex);
X = nx*2;Y = ny*2;
lambda = 532e-3;
z = 2e3;    % multiple depths, define as a string
nz = length(z);

% construct kernels
Kphase = getPhase3D(X, Y, nx, ny, z, lambda);
Kref = getRef3D(X,Y,nx,ny,z,lambda);

% get mask
% mask_type: 1--uniformly random
% mask_type: 0--periodic
mask_type = 0;
percentage = 0.5;
if mask_type == 1
    mask = subsample_uni_rand(nx,ny,percentage);
elseif mask_type == 0
    mask = subsample_periodic(nx,ny,round(1/percentage));
end

complex_vector = MyC2V(complex(:));
holo_vector = Forward3D(complex_vector,Kref,nx,ny,nz,Kphase,mask);
holo = MyV2C(holo_vector);holo = reshape(holo,ny,nx);
holo_amp = abs(holo);

% subsample
holo_sub = holo_amp.*mask;
% upsample
holo_up = upsampleHolo(holo_sub,mask);
holo_up_vector = MyC2V(holo_up(:));
figure(2);
subplot(221);imagesc(holo_amp);axis equal;axis off;title('hologram');
subplot(222);imagesc(holo_sub);axis equal;axis off;title('subsampled hologram');
subplot(223);imagesc(holo_up);axis equal;axis off;title('upsampled hologram');
subplot(224);imagesc(holo_up - holo_sub);axis equal;axis off;title('error');

% backward
back_field_vector = Backward3D(holo_up_vector,Kref,nx,ny,nz,Kphase);
back_field_vector = MyV2C(back_field_vector);
back_field = reshape(back_field_vector,ny,nx,nz);
back_field_amp = abs(back_field);
back_field_phase = angle(back_field);
figure(3);
subplot(121);imagesc(back_field_amp);axis equal;axis off;title('back propagation (amplitude)');
subplot(122);imagesc(back_field_phase);axis equal;axis off;title('back propagation (phase)');

%% use TwIST
% function handlers
A = @(f_twist) Forward3D(f_twist,Kref,nx,ny,nz,Kphase,mask,holo_up);  % forward propagation operator
AT = @(g) Backward3D(g,Kref,nx,ny,nz,Kphase);  % backward propagation operator
% twist parameters
tau_string = 10.^(-linspace(1,4,8)); 
para_string = 10.^(-linspace(1,4,8));
para_space = zeros(length(tau_string),length(para_string));
best_tau = tau_string(1);
best_para = para_string(1);
best_psnr = 0;

piter = 4;
tolA = 1e-6;

N1 = nx; N2 = ny*nz*2; N3 = 1;

% init: 0--all zeros; 1--random; 2--A'y
iterations = 20;
g = holo_up_vector;
for i = 1:length(tau_string)
    for j = 1:length(para_string)
        tau = tau_string(i);
        para = para_string(j);
        Psi = @(f,th) MyTVpsi(f,th,para,piter,N1,N2,N3);
        Phi = @(f) MyTVphi(f,N1,N2,N3);
        
        rec_comp= ...
            TwIST(g,A,tau,...
            'AT', AT, ...
            'Psi', Psi, ...
            'Phi',Phi, ...
            'Initialization',2,...
            'Monotone',1,...
            'StopCriterion',1,...
            'MaxIterA',iterations,...
            'MinIterA',iterations,...
            'ToleranceA',tolA,...
            'Verbose', 1);

        rec_comp = reshape(MyV2C(rec_comp), nx, ny, nz);
        psnr_rec = psnr(abs(rec_comp),abs(complex));
        para_space(i,j) = psnr_rec;
        if psnr_rec > best_psnr
            best_psnr = psnr_rec;
            best_tau = tau;
            best_para = para;
            
        end
    end
end

tau = best_tau;
para = best_para;
Psi = @(f,th) MyTVpsi(f,th,para,piter,N1,N2,N3);
Phi = @(f) MyTVphi(f,N1,N2,N3);

iterations = 1000;

rec_comp=TwIST(g,A,tau,...
    'AT', AT, ...
    'Psi', Psi, ...
    'Phi',Phi, ...
    'Initialization',2,...
    'Monotone',1,...
    'StopCriterion',1,...
    'MaxIterA',iterations,...
    'MinIterA',iterations,...
    'ToleranceA',tolA,...
    'Verbose', 1);
rec_comp = reshape(MyV2C(rec_comp), nx, ny, nz);
rec_amp = abs(rec_comp);
rec_phase = angle(rec_comp);

psnr_rec_amp = psnr(rec_amp,abs(complex));
psnr_rec_phase = psnr(rec_phase,angle(complex));

figure(4);
subplot(121);imagesc(rec_amp);axis equal;axis off;title('recovered amplitude');
subplot(122);imagesc(rec_phase);axis equal;axis off;title('recovered phase');





























