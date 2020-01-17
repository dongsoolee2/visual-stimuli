function DL_stimdraw(stim)
% DL_stimdraw(stim)
% DL_stimdraw displays a list of stimuli in configuration file (config.json).
%
% by Dongsoo Lee (edited 20-01-16)

% load configuration file.
config = loadjson('/Users/Administrator/Documents/MATLAB/visual-stimuli/d213/config/config.json');
ev = config{1};             % environment configuration
sc = config{2};             % screen configuration
pd = config{3};             % photodiode configuration
st = config{4};             % stimulus configuration
ti = config{5};             % pausetime configuration
sl = config{6}.list;        % stimuli list
                                % duration [sec]
                                % boxSize [pixel] is size of each checker
                                % stimSize [pixel] is size of the whole stimuli
                                % seed [int] for random number generator
                                % contrast [0, 1] contrast of each checker
                                % framerate [Hz] frame per second
stimnum = size(sl, 2);          % the total number of stimuli
                                
try
    % check if the installed Psychtoolbox is based on OpenGL ('Screen()'),
    %       and provide a consistent mapping of key codes
    AssertOpenGL;
    KbName('UnifyKeyNames');                        %  = PsychDefaultSetup(1);
    
    Screen('Preference', 'SkipSyncTests', 0);       % don't use ('SkipSyncTests', 1) in a real experiment
    
    % load KbCheck because it takes some time to read for the first time
    while KbCheck(); end
    
    ListenChar(2);                                  % suppress output of keypresses
    
    % get the screen numbers 
    myScreen = sc.idx;
    
    % open an on screen window
    if myScreen == 2
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
    %flipFrame = round(0.03/ifi);    % will be defined for each stimulus
    %flipTime = flipFrame * ifi;
    %totalFrame = floor((duration/flipTime)/10) * 10;
    
    % get the size of the on screen window
    [xSize, ySize] = Screen('WindowSize', myWindow);
    
    % set photodiode
    PHOTODIODE = ones(4, 1);
    PHOTODIODE(1, :) = round(pd.center(1) * xSize - pd.radius);
    PHOTODIODE(2, :) = round(pd.center(2) * ySize - pd.radius);
    PHOTODIODE(3, :) = round(pd.center(1) * xSize + pd.radius);
    PHOTODIODE(4, :) = round(pd.center(2) * ySize + pd.radius);
    
    for s = 1:stimnum
        % calculate fliptime
        sl{s}.flipFrame = round((1/sl{s}.framerate)/ifi);
        sl{s}.flipTime = sl{s}.flipFrame * ifi;
        sl{s}.totalFrame = floor((sl{s}.duration/sl{s}.flipTime)/10) * 10;
        
        % set stimulus area (for DLP setup, offset was added for "center")
        sl{s}.stimSize = ceil(sl{s}.stimSize/sl{s}.boxSize) * sl{s}.boxSize;
        sl{s}.numHBoxes = ceil(sl{s}.stimSize/sl{s}.boxSize/2) * 2;
        sl{s}.stimSize = sl{s}.numHBoxes * sl{s}.boxSize;
        sl{s}.xOffset = floor((xSize/2 - sl{s}.stimSize/2)/sl{s}.boxSize) * sl{s}.boxSize + st.offset(1);
        sl{s}.yOffset = floor((ySize/2 - sl{s}.stimSize/2)/sl{s}.boxSize) * sl{s}.boxSize + st.offset(2);
        sl{s}.numBoxes = sl{s}.numHBoxes^2;
    
        % calculate the coordinate of boxes
        sl{s}.X1 = mod(0:sl{s}.numBoxes - 1, sl{s}.numHBoxes) * sl{s}.boxSize + sl{s}.xOffset;
        sl{s}.X2 = sl{s}.X1 + sl{s}.boxSize;
        sl{s}.Y1 = floor((0:sl{s}.numBoxes - 1)/sl{s}.numHBoxes) * sl{s}.boxSize + sl{s}.yOffset;
        sl{s}.Y2 = sl{s}.Y1 + sl{s}.boxSize;
        sl{s}.boxes = [sl{s}.X1; sl{s}.Y1; sl{s}.X2; sl{s}.Y2];
   
        % set intensity of boxes & photodiode
        [~, sl{s}.numColumns] = size(sl{s}.boxes);
        sl{s}.boxColor = zeros(3, sl{s}.numColumns, sl{s}.totalFrame);
        sl{s}.pdColor = zeros(3, sl{s}.totalFrame);
        rng(sl{s}.seed);          % default = 0;
        
        %%%%%% work HERE
        %%%%%% $%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % construct boxes and photodiodes
        for c = 1:sl{s}.totalFrame
            sl{s}.boxSequence = rand(1, sl{s}.numColumns);
            if sl{s}.binary == 1
                sl{s}.boxSequence = (sl{s}.boxSequence > 0.5);
            end
            sl{s}.boxSequenceIntensity = sl{s}.boxSequence * 2 * (meanIntensity * sl{s}.contrast) ...
                + meanIntensity * (1 - sl{s}.contrast);
            sl{s}.boxColor(1, :, c) = st.ch(1) * sl{s}.boxSequenceIntensity;
            sl{s}.boxColor(2, :, c) = st.ch(2) * sl{s}.boxSequenceIntensity;
            sl{s}.boxColor(3, :, c) = st.ch(3) * sl{s}.boxSequenceIntensity;
            sl{s}.pdColor(1, c) = pd.ch(1) * sl{s}.boxSequenceIntensity(1);
            sl{s}.pdColor(2, c) = pd.ch(2) * sl{s}.boxSequenceIntensity(1);
            sl{s}.pdColor(3, c) = pd.ch(3) * sl{s}.boxSequenceIntensity(1);
        end

    
    
    end
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    % prepare for the first screen
    Screen('FillOval', myWindow, black, PHOTODIODE);
    Screen('Flip', myWindow);

    % wait for keyboard input
    KbWait();
    pause(ti.pausetime);

    Screen('FillOval', myWindow, black, PHOTODIODE);
    vbl = Screen('Flip', myWindow);
  
    % draw checkerboards
    for i = 1:totalFrame + 1
        if i == 1
            Screen('FillRect', myWindow, boxColor(:, :, i), boxes);
            Screen('FillOval', myWindow, white * pd.ch, PHOTODIODE);
            vbl = Screen('Flip', myWindow, vbl + (flipFrame - 0.1) * ifi);
            if ti.pauseafter1 == 1
                pause(ti.pausetimeafter1);
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
    
    pause(ti.pausetime2);
    
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