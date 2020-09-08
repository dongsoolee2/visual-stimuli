function DL_stepflash(duration, frequency, boxSize, stimSize)
% DL_stepflash(duration, frequency, boxSize, stimSize)
% DL_STEPFLASH displays step flash stimuli.
%
% duration [sec] (default = 10)
% frequency [Hz] (default = 0.5; alternating light and dark for 1sec each)
% boxSize and stimSize are the parameters of DL_rfmap (for consistency)
%
% by Dongsoo Lee (edited 17-04-04)

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

% parameters
% -----------------------------------------------------------
PAUSETIME = 0.5;                            % [sec]
% -----------------------------------------------------------

try
    % check if the installed Psychtoolbox is based on OpenGL ('Screen()'),
    %       and provide a  consistent mapping of key codes
    AssertOpenGL;
    KbName('UnifyKeyNames');                        %  = PsychDefaultSetup(1);
    
    %Screen('Preference', 'ScreenToHead', 1, 1, 0);  % use this in a real experiment
    %Screen('Preference', 'SkipSyncTests', 1);      % don't use this in a real experiment
    
    % load KbCheck because it takes some time to read for the first time
    while KbCheck(); end
    
    ListenChar(2);                                  % suppress output of keypresses
    
    % get the screen numbers & draw to the external screen if available
    myScreen = max(Screen('Screens'));
    
    % open an on screen window
    [myWindow, windowRect] = Screen('OpenWindow', myScreen, 255/2);
    %[myWindow, windowRect] = Screen('OpenWindow', myScreen, 0);
    Screen('ColorRange', myWindow, 1, [], 1);
    % set the maximum priority number
    Priority(MaxPriority(myWindow));
    
    % get index of black and white
    black = BlackIndex(myScreen);                   % 0
    white = WhiteIndex(myScreen);                   % 1
    %meanIntensity = ((black + white + 1)/2) - 1;    % 127
    meanIntensity = (black + white)/2;              % 0.5
    
    % get inter-flip interval (inverse of frame rate)
    ifi = Screen('GetFlipInterval', myWindow);
    
    % get the size of the on screen window
    [xSize, ySize] = Screen('WindowSize', myWindow);
    
    % set photodiode
    PHOTODIODE = ones(4, 1);
    PHOTODIODE(1, :) = round(xSize/10 * 9.0 - 65);
    PHOTODIODE(2, :) = round(ySize/10 * 1.6 - 65);
    PHOTODIODE(3, :) = round(xSize/10 * 9.0 + 65);
    PHOTODIODE(4, :) = round(ySize/10 * 1.6 + 65);
    
    % set moving bar frame (to be consistent with [DL_rfmap] function)
    stimSize = ceil(stimSize/boxSize) * boxSize;
    numHBoxes = ceil(stimSize/boxSize/2) * 2;
    stimSize = numHBoxes * boxSize;
    xOffset = floor((xSize/2 - stimSize/2)/boxSize) * boxSize;
    yOffset = floor((ySize/2 - stimSize/2)/boxSize) * boxSize;
    flashBox = [xOffset yOffset xOffset + stimSize yOffset + stimSize];
    
    % parameters
    stepIndicator = 1;
    waitFrame = ceil((1/frequency/2)/ifi);
    totalFlip = ceil(duration/(waitFrame * ifi));
    
    % prepare for the first screen
    Screen('FillOval', myWindow, black, PHOTODIODE);
    Screen('Flip', myWindow);
    HideCursor();
    KbWait();
    % wait for keyboard input
    KbEventFlush();
    KbQueueCreate();
    KbQueueStart();
    pause(PAUSETIME);
    
    % to start recording computer (one frame earlier)
    Screen('FillOval', myWindow, 0.5 * white, PHOTODIODE);
    vbl = Screen('Flip', myWindow);
    
    % draw step flashes
    for ind = 1:totalFlip + 1
        stepIntensity = stepIndicator * white;
        Screen('FillRect', myWindow, stepIntensity, flashBox);       
        if ind == 1
            Screen('FillOval', myWindow, white, PHOTODIODE);
            vbl = Screen('Flip', myWindow, vbl + 0.5 * ifi);
            Screen('FillRect', myWindow, stepIntensity, flashBox);
            Screen('FillOval', myWindow, 0.5 * stepIntensity, PHOTODIODE);
            vbl = Screen('Flip', myWindow, vbl + 0.5 * ifi);
        else
            Screen('FillOval', myWindow, 0.7 * white, PHOTODIODE);
            vbl = Screen('Flip', myWindow, vbl + 0.5 * ifi);
            Screen('FillRect', myWindow, stepIntensity, flashBox);
            Screen('FillOval', myWindow, 0.5 * stepIntensity, PHOTODIODE);
            vbl = Screen('Flip', myWindow, vbl + 0.5 * ifi);
        end
        Screen('FillRect', myWindow, stepIntensity, flashBox);
        Screen('FillOval', myWindow, 0.5 * stepIntensity, PHOTODIODE);
        vbl = Screen('Flip', myWindow, vbl + (waitFrame - 2 - 0.5) * ifi);
        stepIndicator = ~stepIndicator;
        % keyboard check
        if KbQueueCheck(-1);
            break;
        end
    end
    
    Screen('FillOval', myWindow, black, PHOTODIODE);
    vbl = Screen('Flip', myWindow);
    pause(30);
    
    Screen('CloseAll');
    ShowCursor();
    ListenChar(0);
catch exception
    Screen('CloseAll');
    ShowCursor();
    ListenChar(0);
    exception.identifier();
end
