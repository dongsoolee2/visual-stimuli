function stepflash(duration, frequency, boxSize, stimSize)
% stepflash(duration, frequency, boxSize, stimSize)
% STEPFLASH displays step flash stimuli.
%
% duration [sec] (default = 10)
% frequency [Hz] (default = 0.5; alternating light and dark for 1sec each)
% boxSize and stimSize are the parameters of DL_rfmap (for consistency)
%
% by Dongsoo Lee (edited 17-04-04; edited for mouse exp 19-05-20;
%                 edited 20-01-08)

% number of arguments?
if nargin == 0
    duration = 10;
    frequency = 0.5;
    boxSize = 8;
    stimSize = 32 * boxSize;
elseif nargin == 1
    %duration = 10;
    frequency = 0.5;
    boxSize = 8;
    stimSize = 32 * boxSize;
elseif nargin == 2
    %duration = 10;
    %frequency = 0.5;
    boxSize = 8;
    stimSize = 32 * boxSize;
elseif nargin == 3
    %duration = 10;
    %frequency = 0.5;
    %boxSize = 8;
    stimSize = 32 * boxSize;
elseif nargin == 4
    %duration = 10;
    %frequency = 0.5;
    %boxSize = 8;
    %stimSize = 32 * boxSize;
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
    %       and provide a  consistent mapping of key codes
    AssertOpenGL;
    KbName('UnifyKeyNames');                        %  = PsychDefaultSetup(1);
    
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
    %flipFrame = round(0.03/ifi);
    %flipTime = flipFrame * ifi;
    %totalFrame = floor((duration/flipTime)/10) * 10;
    waitFrame = ceil((1/frequency/2)/ifi);
    totalFlip = ceil(duration/(waitFrame * ifi));
    
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
    %numBoxes = numHBoxes^2;
    
    % calculate the coordinate of flashbox
    flashBox = [xOffset yOffset xOffset + stimSize yOffset + stimSize];
    
    % stepindicator
    stepIndicator = 1;
    
    % prepare for the first screen
    Screen('FillOval', myWindow, black, PHOTODIODE);
    Screen('Flip', myWindow);

    % wait for keyboard input
    KbWait();
    pause(ti.pausetimebefore);

    Screen('FillOval', myWindow, black, PHOTODIODE);
    vbl = Screen('Flip', myWindow);
    
    % draw step flashes
    for ind = 1:totalFlip + 1
        stepIntensity = stepIndicator * white;
        Screen('FillRect', myWindow, stepIntensity * st.ch, flashBox);       
        if ind == 1
            Screen('FillOval', myWindow, white * pd.ch, PHOTODIODE);
            vbl = Screen('Flip', myWindow, vbl + 0.5 * ifi);
            Screen('FillRect', myWindow, stepIntensity * st.ch, flashBox);      
            Screen('FillOval', myWindow, 0.3 * stepIntensity * pd.ch, PHOTODIODE);
            vbl = Screen('Flip', myWindow, vbl + 0.5 * ifi);
        else
            Screen('FillOval', myWindow, white * pd.ch, PHOTODIODE);
            vbl = Screen('Flip', myWindow, vbl + 0.5 * ifi);
            Screen('FillRect', myWindow, stepIntensity * st.ch, flashBox);
            Screen('FillOval', myWindow, 0.3 * stepIntensity * pd.ch, PHOTODIODE);
            vbl = Screen('Flip', myWindow, vbl + 0.5 * ifi);
        end
        Screen('FillRect', myWindow, stepIntensity * st.ch, flashBox);
        Screen('FillOval', myWindow, 0.3 * stepIntensity * pd.ch, PHOTODIODE);
        vbl = Screen('Flip', myWindow, vbl + (waitFrame - 2 - 0.1) * ifi);
        stepIndicator = ~stepIndicator;
    end
    Screen('FillOval', myWindow, black, PHOTODIODE);
    vbl = Screen('Flip', myWindow);
    
    pause(ti.pausetimeafter);
    
    waitFrame
    totalFlip
    
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
