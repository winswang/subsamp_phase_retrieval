function obj = updateAmplitude(obj)
% input obj is an object contains
% obj.holo_complex: complex field at the sensing plane
% obj.mask: 1--to be replaced with known amplitude; 0--do nothing
% obj.hologram: known intensity
idx = obj.mask == 1;
obj.holo_amp(idx) = obj.hologram_amp(idx);
obj.holo_complex = obj.holo_amp.*exp(1i*obj.holo_phase);
end