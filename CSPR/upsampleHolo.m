function holo_upsamp = upsampleHolo(hologram_amp,mask)
% obj.mask is the subsample pattern
% obj.subsamp_type: subsample type 0--periodic; 1--random;
% obj.hologram_amp: used for upsampling
[n1,n2] = size(mask);
canvas = zeros(size(hologram_amp));
percentage = nnz(mask)/n1/n2;
idx = mask == 1;
canvas(idx) = hologram_amp(idx);
holo_upsamp = zeros(size(hologram_amp));

subsamp_type = 0;
if subsamp_type == 0
    step = round(1/sqrt(percentage));
    for i = 1:n1
        for j = 1:n2
            if (i+step) <= n1
                up = max(1,i-step+1);
                down = up + step-1;
            else
                down = n2;
                up = down-step+1;
            end
            if (j+step) <= n2
                left = max(1,j-step+1);
                right = left + step-1;
            else
                right = n2;
                left = right-step+1;
            end
                
            patch = canvas(up:down,left:right);
            holo_upsamp(i,j) = sum(patch(:));    
            
        end
    end
    
elseif subsamp_type == 1
    
end

end