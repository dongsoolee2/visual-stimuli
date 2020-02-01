function genmatfiles(duration, boxSize, stimSize, jitter, downsample)

% Number of arguments?
if nargin == 0
    duration = 10;
    boxSize = 8;
    stimSize = 32 * boxSize;
    jitter = ;
    downsample = 1;
elseif nargin == 1
    duration = 10;
    boxSize = 8;
    stimSize = 32 * boxSize;
    jitter = 0;
    downsample = 1;
elseif nargin == 2
    duration = 10;
    boxSize = 8;
    stimSize = 32 * boxSize;
    jitter = 0;
    downsample = 1;
elseif nargin == 3
    duration = 10;
    boxSize = 8;
    stimSize = 32 * boxSize;
    jitter = 0;
    downsample = 1;
elseif nargin == 4
    duration = 10;
    boxSize = 8;
    stimSize = 32 * boxSize;
    jitter = 0;
    downsample = 1;
elseif nargin == 5
    duration = 10;
    boxSize = 8;
    stimSize = 32 * boxSize;
    jitter = 0;
    downsample = 1;
end

%
mmrs = zeros(540, 60, 100, 100);

for t = 1:T
for x = 1:X
for y = 1:Y
mmrs(x+6*(y-1)+18*(t-1), :, :, :)=mm(60*(t-1)+1:60*t, 100*(x-1)+1:100*x, 100*(y-1)+1:100*y);
end
end
end


% jitter


% downsample





end
