function m = loadmatfiles(s)

% Load parameters from s
SEED = s.seed;
NUM_BOXES = round(s.stimSize/s.boxSize);

% Load movie file with seed
filedir = "/Users/dlee/visual-stimuli/matrix/naturalmovie/";
fileseed = num2str(SEED);
fileformat = "*.mat";
filesearch = dir(append(filedir, fileseed, "/", fileformat));
filename = filesearch(1).name;
mov = load(append(filedir, fileseed, "/", filename));

% Sub-sample, permute, reshape
[T, X1, X2] = size(mov.mov_sample);
X1_START = round((X1 - NUM_BOXES)/2) + 1;
X1_END = X1_START + NUM_BOXES - 1;
X2_START = round((X2 - NUM_BOXES)/2) + 1;
X2_END = X2_START + NUM_BOXES - 1;
mov_p = permute(mov.mov_sample(:, X1_START:X1_END, X2_START:X2_END), [3, 2, 1]);
mov_rs = reshape(mov_p, [NUM_BOXES * NUM_BOXES, T]);

% return
m = mov_rs; 
end