function [raw_dots, dotColor] = boxColor2dotColor(boxColor, boxSize)
% [raw_dots, dotColor] = boxColor2dotColor(boxColor, boxSize)
%
% by Dongsoo Lee (20-07-15)

% boxColor index: (0, 0) -> (0, 1) -> ...

[~, numBoxes, T] = size(boxColor);                  % (3, 1024, T)
numHBoxes = sqrt(numBoxes);                         % 32                      
boxSize = boxSize;                                  % 8
numHDots = numHBoxes * boxSize;                     % 256
numDots = numHDots^2;                               % 65536

raw_dots = zeros(2, numDots);                       % (2, 65536)
b = 1;
for i = 0:numHBoxes - 1                             % order is important (i: row, j: column)
    for j = 0:numHBoxes - 1
        raw_dots(:, (b - 1) * boxSize^2 + 1:b * boxSize^2) = box2dot(boxSize, i, j);
        b = b + 1;
    end
end

%dotColor = uint8(upsample_s(boxColor, boxSize^2, 2));      % (3, 65536, T); by upsampling from boxColor
dotColor = uint8(repelem(boxColor, 1, boxSize^2, 1));       % this is much faster

end

function dotIndex = box2dot(boxSize, offset1, offset2)      % offset1 is row, offset2 is column order
[idx1, idx2] = ndgrid(0:boxSize - 1, 0:boxSize - 1);
dotIndex = [idx1(:)' + offset1 * boxSize; idx2(:)' + offset2 * boxSize];
end