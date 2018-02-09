function obj = supportSW(obj,sigma,threshold,background)
if nargin <4
    background = 1;
end
if nargin < 3
    threshold = 0.5;
end
% obj.field_bp is the back propagated field
support_ori = abs(obj.field_bp);
% support_ori = support_ori/max(support_ori(:));
% if background == 1
    support_ori = 1-support_ori;
% end

%% gaussian filtering
support_gauss = imgaussfilt(support_ori,sigma);
%% normalization
support_gauss = support_gauss/max(support_gauss(:));
% threshold = median(support_gauss(:));
idx = support_gauss>threshold;
support_th = zeros(size(support_gauss));
support_th(idx) = 1;
obj.support = support_th;

end