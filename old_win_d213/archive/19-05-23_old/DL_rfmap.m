function DL_rfmap(duration, boxSize, stimSize, seed, contrast)
% DL_rfmap(duration, boxSize, stimSize, seed, contrast)
% DL_rfmap displays checkerboard stimuli drawn from gaussian distribution.
%
% duration [sec] (default = 10)
% boxSize [pixel] is size of each checker
% stimSize [pixel] is size of the whole stimuli
% seed [int] for random number generator
% contrast [0, 1] contrast of each checker
%
% by Dongsoo Lee (edited 17-04-04; edited for mouse exp 19-05-16)

% number of arguments?
if nargin == 0
    duration = 10;
    boxSize = 8;
    stimSize = 32 * boxSize;
    seed = 0;
    contrast = 1;
elseif nargin == 1
    %duration = 10;
    boxSize = 8;
    stimSize = 32 * boxSize;
    seed = 0;
    contrast = 1;
elseif nargin == 2
    %duration = 10;
    %boxSize = 8;
    stimSize = 32 * boxSize;
    seed = 0;
    contrast = 1;
elseif nargin == 3
    %duration = 10;
    %boxSize = 8;
    %stimSize = 32 * boxSize;
    seed = 0;
    contrast = 1;
elseif nargin == 4
    %duration = 10;
    %boxSize = 8;
    %stimSize = 32 * boxSize;
    %seed = 0;
    contrast = 1;
elseif nargin == 5
    %duration = 10;
    %boxSize = 8;
    %stimSize = 32 * boxSize;
    %seed = 0;
    %contrast = 1;
end

% parameters
% -----------------------------------------------------------
PAUSETIME = 0.5;                            % [sec]
% -----------------------------------------------------------

try
    % check if the installed Psychtoolbox is based on OpenGL ('Screen()'),
    %       and provide a  consistent mapping of key codes
    AssertOpenGL;
    KbName('UnifyKeyNames');                        %  = PsychDefaultSetup(1);
    
    Screen('Preference', 'ScreenToHead', 1, 1, 0); % use this in a real experiment
    Screen('Preference', 'SkipSyncTests', 0);       % don't use this (1) in a real experiment
    
    % load KbCheck because it takes some time to read for the first time
    while KbCheck(); end
    
    ListenChar(2);                                  % suppress output of keypresses
    
    % get the screen numbers & draw to the external screen if available
    myScreen = max(Screen('Screens'));
    %myScreen=0;
    
    % open an on screen window
    [myWindow, windowRect] = Screen('OpenWindow', myScreen, [0 255/2 255/2]);
    Screen('ColorRange', myWindow, 1, [], 1);
    % set the maximum priority number
    Priority(MaxPriority(myWindow));
    
    % get index of black and white
    black = BlackIndex(myScreen);                   % 0
    white = WhiteIndex(myScreen);                   % 1
    %meanIntensity = ((black + white + 1)/2) - 1;    % 127
    meanIntensity = (black + white)/2;              % 0.5
    
    % get inter-flip interval (inverse of frame rate) & calculate fliptime
    ifi = Screen('GetFlipInterval', myWindow);
    flipFrame = round(0.03/ifi);
    flipTime = flipFrame * ifi;
    totalFrame = floor((duration/flipTime)/10) * 10;
    
    % get the size of the on screen window
    [xSize, ySize] = Screen('WindowSize', myWindow);
    
    % set photodiode
    PHOTODIODE = ones(4, 1);
    %PHOTODIODE(1, :) = round(xSize/10 * 9.0 - 65);
    %PHOTODIODE(2, :) = round(ySize/10 * 1.6 - 65);
    %PHOTODIODE(3, :) = round(xSize/10 * 9.0 + 65);
    %PHOTODIODE(4, :) = round(ySize/10 * 1.6 + 65);
    PHOTODIODE(1, :) = round(xSize/10 * 5.90 - 39);
    PHOTODIODE(2, :) = round(ySize/10 * 6.40 - 39);
    PHOTODIODE(3, :) = round(xSize/10 * 5.90 + 39);
    PHOTODIODE(4, :) = round(ySize/10 * 6.40 + 39);
    
    % set stimulus area (for DLP setup, +73 and -8 were added for "center")
    stimSize = ceil(stimSize/boxSize) * boxSize;
    numHBoxes = ceil(stimSize/boxSize/2) * 2;
    stimSize = numHBoxes * boxSize;
    xOffset = floor((xSize/2 - stimSize/2)/boxSize) * boxSize + 73;  
    %xOffset = floor((xSize/2 - stimSize/2)/boxSize) * boxSize;
    yOffset = floor((ySize/2 - stimSize/2)/boxSize) * boxSize - 8;
    %yOffset = floor((ySize/2 - stimSize/2)/boxSize) * boxSize;
    numBoxes = numHBoxes^2;
    
    % calculate the coordinate of boxes
    X1 = mod(0:numBoxes - 1, numHBoxes) * boxSize + xOffset;
    X2 = X1 + boxSize;
    Y1 = floor((0:numBoxes - 1)/numHBoxes) * boxSize + yOffset;
    Y2 = Y1 + boxSize;
    boxes = [X1; Y1; X2; Y2];
    
    % set intensity of boxes
    [~, numColumns] = size(boxes);
    boxColor = zeros(3, numColumns, totalFrame);
    %s1 = RandStream.create('mrg32k3a', 'Numstreams', 1, 'Seed', seed);
    rng(seed);          % default = 0;
    for c = 1:totalFrame
        boxColor(1, :, c) = 0;
        boxColor(2, :, c) = (rand(1, numColumns) > 0.9) * 2 * (meanIntensity * contrast) ...
            + meanIntensity * (1 - contrast);      % binary
        %boxColor(2, :, c) = (rand(1, numColumns)) * 2 * (meanIntensity * contrast) ...
        %    + meanIntensity * (1 - contrast);     % white noise
        %boxColor(1, :, c) = (rand(s1, 1, numColumns) > 0.5) * 2 * (meanIntensity * contrast) ...
        %    + MeanIntensity * (1 - contrast);
        boxColor(3, :, c) = boxColor(2, :, c);
        %boxColor(1, :, c) = boxColor(2, :, c);
    end
    pdColor = zeros(3, totalFrame);
    pdColor(1, :) = boxColor(2, 1, :);     % red channel is for pd
    
    % prepare for the first screen
    Screen('FillOval', myWindow, black, PHOTODIODE);
    Screen('Flip', myWindow);
    %HideCursor();
    KbWait();
    % wait for keyboard input
    %KbEventFlush();
    %KbQueueCreate();
    %KbQueueStart();
    pause(PAUSETIME);

    % to start recording computer (one frame earlier)
    %Screen('FillOval', myWindow, 0.5 * white, PHOTODIODE);
    Screen('FillOval', myWindow, black, PHOTODIODE);
    vbl = Screen('Flip', myWindow);
  
    % draw checkboards
    for i = 1:totalFrame + 1
        if i == 1
            Screen('FillRect', myWindow, boxColor(:, :, i), boxes);
            Screen('FillOval', myWindow, [white 0 0], PHOTODIODE);
            vbl = Screen('Flip', myWindow, vbl + (flipFrame - 0.1) * ifi);
            %pause(30);
        elseif i == totalFrame + 1
            Screen('FillRect', myWindow, boxColor(:, :, i - 1), boxes);
            Screen('FillOval', myWindow, [white 0 0], PHOTODIODE);
            vbl = Screen('Flip', myWindow, vbl + (flipFrame - 0.1) * ifi);
        else
            Screen('FillRect', myWindow, boxColor(:, :, i), boxes);
            Screen('FillOval', myWindow, 0.46 * pdColor(:, i), PHOTODIODE);
            %Screen('FillOval', myWindow, 0.6 * boxColor(2, 1, i), PHOTODIODE);
            vbl = Screen('Flip', myWindow, vbl + (flipFrame - 0.1) * ifi);
        end
        % keyboard check
        %if KbQueueCheck(-1);
        %    break;
        %end
    end
    totalFrame
    
    Screen('FillOval', myWindow, black, PHOTODIODE);
    vbl = Screen('Flip', myWindow);
    %pause(15);
    
    Screen('CloseAll');
    ShowCursor();
    ListenChar(0);
catch exception
    Screen('CloseAll');
    ShowCursor();
    ListenChar(0);
    exception.identifier();
end