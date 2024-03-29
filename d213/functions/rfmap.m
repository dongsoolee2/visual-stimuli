function rfmap(duration, boxSize, stimSize, seed, contrast)
% rfmap(duration, boxSize, stimSize, seed, contrast)
% rfmap displays checkerboard stimuli drawn from gaussian distribution.
%
% duration [sec] (default = 10)
% boxSize [pixel] is size of each checker
% stimSize [pixel] is size of the whole stimuli
% seed [int] for random number generator
% contrast [0, 1] contrast of each checker
%
% by Dongsoo Lee (edited 17-04-04; edited for mouse exp 19-05-16;
%                 edited 20-01-07; edited for linux 20-07-02)

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

% load configuration file.
config = loadjson('/home/dlee/Documents/MATLAB/visual-stimuli/d213/config.json');
ev = config{1};  % environment configuration
sc = config{2};  % screen configuration
pd = config{3};  % photodiode configuration
st = config{4};  % stimulus configuration
ti = config{5};  % pausetime configuration

try
    % check if the installed Psychtoolbox is based on OpenGL ('Screen()'),
    %       and provide a consistent mapping of key codes
    AssertOpenGL;
    KbName('UnifyKeyNames');                        %  = PsychDefaultSetup(1);

    %Screen('Preference', 'ScreenToHead', 1, 1, 0); % use this in a real experiment
    Screen('Preference', 'SkipSyncTests', 0);       % don't use ('SkipSyncTests', 1) in a real experiment
    
    % load KbCheck because it takes some time to read for the first time
    while KbCheck(); end
    
    ListenChar(2);                                  % suppress output of keypresses
    
    % get the screen numbers 
    myScreen = sc.idx;
    
    % open an on screen window
    if myScreen == 1
        [myWindow, windowRect] = Screen('OpenWindow', myScreen, 255/2 * sc.ch);
    else
        [myWindow, windowRect] = Screen('OpenWindow', myScreen, 255/2 * sc.ch, sc.debugsize);
    end
    Screen('ColorRange', myWindow, 1, [], 1);
    
    % set the maximum priority number
    Priority(MaxPriority(myWindow));
    
    % get index of black and white
    black = BlackIndex(myScreen);                   % 0
    white = WhiteIndex(myScreen);                   % 1
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
    PHOTODIODE(1, :) = round(pd.center(1) * xSize - pd.radius);
    PHOTODIODE(2, :) = round(pd.center(2) * ySize - pd.radius);
    PHOTODIODE(3, :) = round(pd.center(1) * xSize + pd.radius);
    PHOTODIODE(4, :) = round(pd.center(2) * ySize + pd.radius);
    
    % set stimulus area (for DLP setup, offset was added for "center")
    stimSize = ceil(stimSize/boxSize) * boxSize;
    numHBoxes = ceil(stimSize/boxSize/2) * 2;
    stimSize = numHBoxes * boxSize;
    xOffset = floor((xSize/2 - stimSize/2)/boxSize) * boxSize + st.offset(1);
    yOffset = floor((ySize/2 - stimSize/2)/boxSize) * boxSize + st.offset(2);
    numBoxes = numHBoxes^2;
    
    % calculate the coordinate of boxes
    X1 = mod(0:numBoxes - 1, numHBoxes) * boxSize + xOffset;
    X2 = X1 + boxSize;
    Y1 = floor((0:numBoxes - 1)/numHBoxes) * boxSize + yOffset;
    Y2 = Y1 + boxSize;
    boxes = [X1; Y1; X2; Y2];
    
    % set intensity of boxes & photodiode
    [~, numColumns] = size(boxes);
    boxColor = zeros(3, numColumns, totalFrame);
    pdColor = zeros(3, totalFrame);
    rng(seed);          % default = 0;
    for c = 1:totalFrame
        boxSequence = rand(1, numColumns);
        if st.binary == 1
            boxSequence = (boxSequence > 0.5);
        end
        boxSequenceIntensity = boxSequence * 2 * (meanIntensity * contrast) ...
            + meanIntensity * (1 - contrast);
        boxColor(1, :, c) = st.ch(1) * boxSequenceIntensity;
        boxColor(2, :, c) = st.ch(2) * boxSequenceIntensity;
        boxColor(3, :, c) = st.ch(3) * boxSequenceIntensity;
        pdColor(1, c) = pd.ch(1) * boxSequenceIntensity(1);
        pdColor(2, c) = pd.ch(2) * boxSequenceIntensity(1);
        pdColor(3, c) = pd.ch(3) * boxSequenceIntensity(1);
    end

    % prepare for the first screen
    Screen('FillOval', myWindow, black, PHOTODIODE);
    Screen('Flip', myWindow);
    HideCursor();

    % wait for keyboard input
    KbWait();
    KbEventFlush();
    KbQueueCreate();
    KbQueueStart();
    pause(ti.pausetimebefore);

    Screen('FillOval', myWindow, black, PHOTODIODE);
    vbl = Screen('Flip', myWindow);
  
    % draw checkerboards
    for i = 1:totalFrame + 1
        if i == 1
            Screen('FillRect', myWindow, boxColor(:, :, i), boxes);
            Screen('FillOval', myWindow, white * pd.ch, PHOTODIODE);
            vbl = Screen('Flip', myWindow, vbl + (flipFrame - 0.1) * ifi);
            if ti.pauseafter1frame == 1
                pause(ti.pausetimeafter1frame);
            end
        elseif i == totalFrame + 1
            %Screen('FillRect', myWindow, boxColor(:, :, i - 1), boxes);
            Screen('FillOval', myWindow, white * pd.ch, PHOTODIODE);
            vbl = Screen('Flip', myWindow, vbl + (flipFrame - 0.1) * ifi);
        else
            Screen('FillRect', myWindow, boxColor(:, :, i), boxes);
            Screen('FillOval', myWindow, 0.1 * pdColor(:, i), PHOTODIODE);
            vbl = Screen('Flip', myWindow, vbl + (flipFrame - 0.1) * ifi);
        end
    end
    Screen('FillOval', myWindow, black, PHOTODIODE);
    vbl = Screen('Flip', myWindow);
    
    pause(ti.pausetimeafter);
    
    totalFrame
    
    Priority(0);
    Screen('CloseAll');
    ShowCursor();
    ListenChar(0);
catch exception
    Priority(0);
    Screen('CloseAll');
    ShowCursor();
    ListenChar(0);
    exception.identifier();
end