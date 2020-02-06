% This script generates stimuli from matrix 

% Load natural movie file
load("/Users/dlee/visual-stimuli/database/movies/mov_f13028_intensity.mat"); 

% Parameters of mat file
TOTAL_FRAME = 13028;        % T
X1_LENGTH = 100;            % y (+ means upward direction)
X2_LENGTH = 100;            % x (+ means rightward direction)
X1_LENGTH_BUFFER = 240;
X2_LENGTH_BUFFER = 300;

% Total number of stimuli block to generate (360 blocks * 150 frames/block = 54000) 
N = 360;
DURATION = 150;             % frame (5 sec for 30 Hz)

% Load jitter sequence and transfomation parameters (in deg)
load("/Users/dlee/visual-stimuli/utils/jitter.mat", "jitter");  % (2, 54000)
RET_UM_PER_DEG = 30.0;      % mouse um / deg
DLP_PX_PER_UM = 0.1;        % dlp px / um
BOX_PER_DLP_PX = 1/8;       % box / dlp px
DOWNSAMPLE = 2;             % img px / box
jitter_coef = (RET_UM_PER_DEG * DLP_PX_PER_UM * BOX_PER_DLP_PX * DOWNSAMPLE);

% Generate random indexes to sample 
SEED = 6;
rng(SEED);                  % T
T_START_IDX = ceil((TOTAL_FRAME - DURATION - 2) * rand(1, N));
T_END_IDX = T_START_IDX + DURATION - 1;
rng(SEED + 1);              % y
X1_START_IDX = ceil((20 - 1) * rand(1, N));
X1_END_IDX = X1_START_IDX + X1_LENGTH + X1_LENGTH_BUFFER - 1;
rng(SEED + 2);              % x
X2_START_IDX = ceil((220 - 1) * rand(1, N));
X2_END_IDX = X2_START_IDX + X2_LENGTH + X2_LENGTH_BUFFER - 1;

% Sample videos
mov_sample = [];
j = 1;
for n = 1:N
    % Sample
    mov_sample_temp = double(mm_intensity(T_START_IDX(n):T_END_IDX(n), ...      % [0, 1]
        X1_START_IDX(n):X1_END_IDX(n), ...
        X2_START_IDX(n):X2_END_IDX(n)))/255;
    mov_sample_jitter_temp = zeros(DURATION, X1_LENGTH/2, X2_LENGTH/2);
    
    % Add jitter and downsample
    for d = 1:DURATION
        % jitter
        X1_jitter_temp = round(jitter_coef*jitter(2, j));               % y axis
        X2_jitter_temp = round(jitter_coef*jitter(1, j));               % x axis
        X1_start_jitter_temp = X1_LENGTH_BUFFER/2 + 1 - X1_jitter_temp; % (+) jitter means upward
        X1_end_jitter_temp = X1_start_jitter_temp + X1_LENGTH - 1; 
        X2_start_jitter_temp = X2_LENGTH_BUFFER/2 + 1 + X2_jitter_temp; % (+) jitter means rightward
        X2_end_jitter_temp = X2_start_jitter_temp + X2_LENGTH - 1;
        
        % rescaling (intensity) & donwsample of image
        mov_sample_jitter_temp_frame = squeeze(mov_sample_temp(d, ...
            X1_start_jitter_temp:X1_end_jitter_temp, ...
            X2_start_jitter_temp:X2_end_jitter_temp));
        mov_sample_jitter_temp_frame = imadjust(mov_sample_jitter_temp_frame);
        mov_sample_jitter_temp_frame = imresize(mov_sample_jitter_temp_frame, 0.5, 'bilinear', 'Antialiasing', true);
        mov_sample_jitter_temp(d, :, :) = mov_sample_jitter_temp_frame;
        j = j + 1;
    end
    
    mov_sample_jitter_temp = mov_sample_jitter_temp - mean(mov_sample_jitter_temp, [1, 2, 3]);
    mov_sample_jitter_temp = mov_sample_jitter_temp / max(abs(mov_sample_jitter_temp), [], [1, 2, 3]);
    mov_sample_jitter_temp = uint8(255 * (mov_sample_jitter_temp / 2 + 0.5));   % [0, 255]
    mov_sample = cat(1, mov_sample, mov_sample_jitter_temp);
end