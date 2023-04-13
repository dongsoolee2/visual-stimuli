% This script generates 'naturalmovie' or 'natualscene' stimuli from matrix 

% parameters ------------------------------
% choose seed
SEED = 101;                 % start from 101
rng(SEED);
% Total number of stimuli block to generate 
DURATION = 150;             % frame (5 sec for 30 Hz) * used 150 (movie), 60 (scene)
N = 78000/DURATION;         % e.g.) 360 blocks * 150 frames/block = 54000
% Movie or scene?
MOVIE0_SCENE1 = 0;
if MOVIE0_SCENE1
    FRAME_FOR_SCENE = 1;
end
% -----------------------------------------

% Load natural movie file
load("/Users/dlee/Documents/MATLAB/visual-stimuli/database/movies/mov_f13028_intensity.mat"); 

% cut 
mm_intensity_cut = zeros(6, 13028, 180, 180, 'uint8');
mm_intensity_cut(1, :, :, :) = mm_intensity(:, 1:180, 51:230);
mm_intensity_cut(2, :, :, :) = mm_intensity(:, 1:180, 231:410);
mm_intensity_cut(3, :, :, :) = mm_intensity(:, 1:180, 411:590);
mm_intensity_cut(4, :, :, :) = mm_intensity(:, 181:360, 51:230);
mm_intensity_cut(5, :, :, :) = mm_intensity(:, 181:360, 231:410);
mm_intensity_cut(6, :, :, :) = mm_intensity(:, 181:360, 411:590);

% reshape and shuffle matrix 
mm_intensity_cut_rs = reshape(permute(mm_intensity_cut, [2, 1, 3, 4]), 6*13028, 180, 180);                       % [6*13028, 180, 180]
mm_intensity_cut_rs2 = permute(reshape(mm_intensity_cut_rs(1:78000, :, :), 150, 520, 180, 180), [2, 1, 3, 4]);   % [520, 150, 180, 180]
mm_intensity_suf = mm_intensity_cut_rs2(randperm(size(mm_intensity_cut_rs2, 1)), :, :, :);                       % [520, 150, 180, 180]
clear mm_intensity;
clear mm_intensity_cut;
clear mm_intensity_cut_rs; 
clear mm_intensity_cut_rs2;

% rotate (random), flip (random), and adjust intensity to remove orientation bias in motion
mm_intensity_suf_rot = zeros(520, 150, 180, 180, 'uint8');
rot_deg = round(360 * rand(1, 520));
flip_bool = round(rand(1, 520));
for b = 1:520
    block_rescale = reshape(imadjust(reshape(squeeze(mm_intensity_suf(b, :, :, :)), 150*180, 180)), 150, 180, 180);
    for t = 1:150
        temp = imrotate(squeeze(block_rescale(t, :, :)), rot_deg(b), 'bilinear', 'crop');
        if flip_bool(b)
            mm_intensity_suf_rot(b, t, :, :) = flip(temp, 2);
        else
            mm_intensity_suf_rot(b, t, :, :) = temp;
        end
    end
end
clear mm_intensity_suf;
mm_intensity_suf_full = reshape(permute(mm_intensity_suf_rot, [2, 1, 3, 4]), 150*520, 180, 180);                 % [78000, 180, 180]
clear mm_intensity_suf_rot;

% Load jitter sequence and transfomation parameters (in deg)
load("/Users/dlee/Documents/MATLAB/visual-stimuli/utils/jitter.mat", "jitter");     % (2, 108000)
RET_UM_PER_DEG = 30.0;      % mouse um / deg
DLP_PX_PER_UM = 0.1;        % dlp px / um
BOX_PER_DLP_PX = 1/8;       % box / dlp px
DOWNSAMPLE = 2;             % img px / box
jitter_coef = (RET_UM_PER_DEG * DLP_PX_PER_UM * BOX_PER_DLP_PX * DOWNSAMPLE);

% add jitter & downsample
T = 78000;
X1_jitter_temp = max(-38, min(round(jitter_coef * jitter(2, 1:T)), 38));
X2_jitter_temp = max(-38, min(round(jitter_coef * jitter(1, 1:T)), 38));
X1_start = 40 + X1_jitter_temp;
X1_end = X1_start + 100 - 1;
X2_start = 40 + X2_jitter_temp;
X2_end = X2_start + 100 - 1;
mm_intensity_jit = zeros(78000, 50, 50, 'uint8');
for t = 1:T
    mm_intensity_jit(t, :, :) = imresize(squeeze(mm_intensity_suf_full(t, X1_start(t):X1_end(t), X2_start(t):X2_end(t))), ...
                                        0.5, 'bilinear', 'Antialiasing', true);
end

mov_sample_train = mm_intensity_jit(1:72000, :, :);
mov_sample_test = mm_intensity_jit(72001:78000, :, :);
