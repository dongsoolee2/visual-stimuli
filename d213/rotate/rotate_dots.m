function dots = rotate_dots(raw_dots, offset1, offset2)
% dots = rotate_dots(raw_dots, offset1, offset2)
% When offset1 & offset2 = 0, the dots are centered on LightCrafter4500.
% This function is for LightCrafter4500 pattern mode.
% (offset1 in the direction of row, offset2 in the direction of column)
% offset1 should be an even number (or, will be changed to even number).
%
% by Dongsoo Lee (20-07-15)

dots = zeros(size(raw_dots));
offset1_ = floor(offset1/2) * 2;    		% offset1_ should be an even number
offset2_ = floor(offset2/2) * 2;   		% this is just in case
x1_0 = 1140/2;					% x1_0 = 570;
x2_0 = (912 - sqrt(size(raw_dots, 2)))/2;	% x2_0 = 328 (when stimulus size 256X256);
						% Before (wrong):
						%     x1_0 = 571 = (1140/2) + 1; x2_0 = 328 = (912 - 256)/2;
    						%  571 changed to 570 (20-07-18); this is important and
    						% depends on the first start (row) index of DMD arrays.
    						% This should be located in one of the outermost pixels.
    						% If the parity of this number is changed,
    						% the visual stimulation is not pixel-accurate.
						%  328 changed to a number dependent on the stimulus size.  
    						% This is based on the manual of DLPC350 chip by Texas Instruments,
    						% and the actual projection was validated by monitoring with a camera.
for i = 1:size(raw_dots, 2)
    [x1_, x2_] = rotate_(raw_dots(1, i), raw_dots(2, i), x1_0, x2_0, offset1_, offset2_);
    dots(2, i) = x1_;               		% Psychtoolbox Screen('DrawDots') receives input as (x, y)
    dots(1, i) = x2_; 				% so the order was switched.
end

end

function [x1_, x2_] = rotate_(x1, x2, x1_0, x2_0, offset1_, offset2_)
x1_ = x1_0 - x1 + x2 + offset1_;
x2_ = x2_0 + floor((x1 + x2) / 2) + offset2_;
end
