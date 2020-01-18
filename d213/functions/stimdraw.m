function ex = stimdraw(expmode)
% stimdraw(stim)
% stimdraw displays a list of stimuli in configuration file (config.json).
%
% by Dongsoo Lee (edited 20-01-16)

% load configuration file.
config = loadjson('/Users/Administrator/Documents/MATLAB/visual-stimuli/d213/config/config.json');
ev = config{1};             % environment configuration
sc = config{2};             % screen configuration
pd = config{3};             % photodiode configuration
st = config{4};             % stimulus configuration
ti = config{5};             % pausetime configuration
slist = config{6};          % stimuli list
sl = slist.list;            % 'sl' for save, 'so' for without save
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
        [myWindow, ~] = Screen('OpenWindow', myScreen, 255/2 * sc.ch);
    else
        [myWindow, ~] = Screen('OpenWindow', myScreen, 255/2 * sc.ch, sc.debugsize);
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
        so{s}.X1 = mod(0:sl{s}.numBoxes - 1, sl{s}.numHBoxes) * sl{s}.boxSize + sl{s}.xOffset;
        so{s}.X2 = so{s}.X1 + sl{s}.boxSize;
        so{s}.Y1 = floor((0:sl{s}.numBoxes - 1)/sl{s}.numHBoxes) * sl{s}.boxSize + sl{s}.yOffset;
        so{s}.Y2 = so{s}.Y1 + sl{s}.boxSize;
        so{s}.boxes = [so{s}.X1; so{s}.Y1; so{s}.X2; so{s}.Y2];
        
        % set intensity of boxes & photodiode
        [~, sl{s}.numColumns] = size(so{s}.boxes);
        so{s}.boxColor = zeros(3, sl{s}.numColumns, sl{s}.totalFrame);
        so{s}.pdColor = zeros(3, sl{s}.totalFrame);
        
        rng(sl{s}.seed);          % default = 0;
        % prepare for drawing
        if sl{s}.name == "naturalmovie"
            a = 0; %%%%%%% will be added
        else
            % construct boxes and photodiodes
            for c = 1:sl{s}.totalFrame
                boxSequence = rand(1, sl{s}.numColumns);
                if sl{s}.binary == 1
                    boxSequence = (boxSequence > 0.5);
                end
                boxSequenceIntensity = boxSequence * 2 * (meanIntensity * sl{s}.contrast) ...
                    + meanIntensity * (1 - sl{s}.contrast);
                so{s}.boxColor(1, :, c) = st.ch(1) * boxSequenceIntensity;
                so{s}.boxColor(2, :, c) = st.ch(2) * boxSequenceIntensity;
                so{s}.boxColor(3, :, c) = st.ch(3) * boxSequenceIntensity;
                so{s}.pdColor(1, c) = pd.ch(1) * boxSequenceIntensity(1);
                so{s}.pdColor(2, c) = pd.ch(2) * boxSequenceIntensity(1);
                so{s}.pdColor(3, c) = pd.ch(3) * boxSequenceIntensity(1);
            end
        end
    end
    
    % prepare for the first screen
    Screen('FillOval', myWindow, black, PHOTODIODE);
    Screen('Flip', myWindow);
    
    % wait for keyboard input
    KbWait();
    pause(ti.pausetimebefore);
    
    Screen('FillOval', myWindow, black, PHOTODIODE);
    vbl = Screen('Flip', myWindow);
    
    % draw the list of stimuli
    for s = 1:stimnum
        for i = 1:sl{s}.totalFrame + 1
            if i == 1
                Screen('FillRect', myWindow, so{s}.boxColor(:, :, i), so{s}.boxes);
                Screen('FillOval', myWindow, white * pd.ch, PHOTODIODE);
                vbl = Screen('Flip', myWindow, vbl + (sl{s}.flipFrame - 0.1) * ifi);
                if ti.pauseafter1frame == 1
                    pause(ti.pausetimeafter1frame);
                end
            elseif i == sl{s}.totalFrame + 1
                Screen('FillOval', myWindow, white * pd.ch, PHOTODIODE);
                vbl = Screen('Flip', myWindow, vbl + (sl{s}.flipFrame - 0.1) * ifi);
            else
                Screen('FillRect', myWindow, so{s}.boxColor(:, :, i), so{s}.boxes);
                Screen('FillOval', myWindow, 0.1 * so{s}.pdColor(:, i), PHOTODIODE);
                vbl = Screen('Flip', myWindow, vbl + (sl{s}.flipFrame - 0.1) * ifi);
            end
        end
        Screen('FillOval', myWindow, black, PHOTODIODE);
        vbl = Screen('Flip', myWindow, vbl + (sl{s}.flipFrame - 0.1) * ifi);
        
        if s < stimnum
            pause(ti.pausetimebetween);
            
            Screen('FillOval', myWindow, black, PHOTODIODE);
            vbl = Screen('Flip', myWindow);
        end
    end
    pause(ti.pausetimeafter);
    
    Priority(0);
    Screen('CloseAll');
    ShowCursor();
    ListenChar(0);
    
    % save experiment configuration as .json file
    ex{1} = ev;
    ex{2} = sc;
    ex{3} = pd;
    ex{4} = st;
    ex{5} = ti;
    slist.list = sl;
    ex{6} = slist;
    if expmode == 1
        dt = datetime('now', 'Format', 'yy-MM-dd''_T''HHmmss');
        savejson('obj', ex, 'filename', '/Users/Administrator/Documents/MATLAB/visual-stimuli/d213/archive/' + string(dt) + '.json');
    end
catch exception
    Priority(0);
    Screen('CloseAll');
    ShowCursor();
    ListenChar(0);
    exception.identifier();
end
