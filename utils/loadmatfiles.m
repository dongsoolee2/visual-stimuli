function m = loadmatfiles(s)

% Load parameters from s
SEED = s.seed;
CATEGORY = s.name;
NUM_BOXES = round(s.stimSize/s.boxSize);

% Load movie file with seed

% This is for d213 Windows 7 machine
%if CATEGORY == "naturalmovie"
%    filedir = '/Users/Administrator/Documents/MATLAB/visual-stimuli/matrix/naturalmovie/';
%elseif CATEGORY == "naturalscene"
%    filedir = '/Users/Administrator/Documents/MATLAB/visual-stimuli/matrix/naturalscene/';
%end

% This is for d213 new linux machien
if CATEGORY == "naturalmovie"
    filedir = '/home/dlee/Documents/MATLAB/visual-stimuli/matrix/naturalmovie/';
elseif CATEGORY == "naturalscene"
    filedir = '/home/dlee/Documents/MATLAB/visual-stimuli/matrix/naturalscene/';
end

fileseed = num2str(SEED);
fileformat = '*.mat';
filesearch = dir(join([filedir, fileseed, '/', fileformat], ''));
filename = filesearch(end).name;
mov = load(join([filedir, fileseed, '/', filename], ''));

% Sub-sample, permute, reshape
[T, X1, X2] = size(mov.mov_sample);
X1_START = round((X1 - NUM_BOXES)/2) + 1;
X1_END = X1_START + NUM_BOXES - 1;
X2_START = round((X2 - NUM_BOXES)/2) + 1;
X2_END = X2_START + NUM_BOXES - 1;
mov_p = permute(mov.mov_sample(:, X1_START:X1_END, X2_START:X2_END), [3, 2, 1]);
mov_rs = reshape(mov_p, [NUM_BOXES * NUM_BOXES, T]);

% Display
%x = sprintf('seed:%d mat files loaded', SEED);
%disp(x);

% return
m = mov_rs; 
end
