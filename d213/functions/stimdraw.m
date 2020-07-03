function ex = stimdraw(expmode)
% stimdraw(stim)
% stimdraw displays a list of stimuli in configuration file (config.json).
%
% by Dongsoo Lee (edited 20-01-16; edited for linux 20-07-02)

% load configuration file.
config = loadjson('/home/dlee/Documents/MATLAB/visual-stimuli/d213/config.json');
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

framebuffer = 0.5;

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
        [myWindow, ~] = Screen('OpenWindow', myScreen, uint8(255/2* sc.ch));
    else
        [myWindow, ~] = Screen('OpenWindow', myScreen, uint8(255/2 * sc.ch), sc.debugsize);
    end
    Screen('ColorRange', myWindow, 255, [], 0);
    
    % set the maximum priority number
    Priority(MaxPriority(myWindow));
    
    % get index of black and white
    black = BlackIndex(myScreen);                   % 0
    white = WhiteIndex(myScreen);                   % 255
    meanIntensity = (black + white)/2;              % 127.5
    
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
        sl{s}.totalFrame60 = sl{s}.flipFrame * sl{s}.totalFrame;
        
        % set stimulus area (for DLP setup, offset was added for "center")
        sl{s}.stimSize = ceil(sl{s}.stimSize/sl{s}.boxSize) * sl{s}.boxSize;
        sl{s}.numHBoxes = ceil(sl{s}.stimSize/sl{s}.boxSize/2) * 2;
        sl{s}.stimSize = sl{s}.numHBoxes * sl{s}.boxSize;
        sl{s}.xOffset = floor((xSize/2 - sl{s}.stimSize/2)/sl{s}.boxSize) * sl{s}.boxSize + st.offset(1);
        sl{s}.yOffset = floor((ySize/2 - sl{s}.stimSize)/sl{s}.boxSize) * sl{s}.boxSize + st.offset(2);
        sl{s}.numBoxes = sl{s}.numHBoxes^2;
        
        % calculate the coordinate of boxes
        so{s}.X1 = mod(0:sl{s}.numBoxes - 1, sl{s}.numHBoxes) * sl{s}.boxSize + sl{s}.xOffset;
        so{s}.X2 = so{s}.X1 + sl{s}.boxSize;
        so{s}.Y1 = floor((0:sl{s}.numBoxes - 1)/sl{s}.numHBoxes) * 2 * sl{s}.boxSize + sl{s}.yOffset;
        so{s}.Y2 = so{s}.Y1 + 2 * sl{s}.boxSize;
        so{s}.boxes = [so{s}.X1; so{s}.Y1; so{s}.X2; so{s}.Y2];
        
        % initialize boxes & photodiode
        [~, sl{s}.numColumns] = size(so{s}.boxes);
        so{s}.boxColor = zeros(3, sl{s}.numColumns, sl{s}.totalFrame);      
        so{s}.pdColor = zeros(3, sl{s}.totalFrame);                         
        
        % prepare for drawing
        if sl{s}.name == "naturalmovie" || sl{s}.name == "naturalscene"
            m = loadmatfiles(sl{s});            % [X1 * X2, T];
            m = m(:, 1:sl{s}.totalFrame);
            so{s}.boxColor(1, :, :) = st.ch(1) * m(:, :);  
            so{s}.boxColor(2, :, :) = st.ch(2) * m(:, :);
            so{s}.boxColor(3, :, :) = st.ch(3) * m(:, :);
            so{s}.pdColor(1, :) = pd.ch(1) * m(1, :);
            so{s}.pdColor(2, :) = pd.ch(2) * m(1, :);
            so{s}.pdColor(3, :) = pd.ch(3) * m(1, :);
        else
            rng(sl{s}.seed);                    % default = 0;
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
        so{s}.boxColor = uint8(upsample_s(so{s}.boxColor, 2, 3));                                 
        so{s}.pdColor = uint8(upsample_s(0.05 * so{s}.pdColor, 2, 2));
        % first frame pd
        so{s}.pdColor(:, 1) = uint8(white * pd.ch);
    end
    
    % prepare for the first screen
    Screen('FillOval', myWindow, uint8(black), PHOTODIODE);
    Screen('Flip', myWindow);
    HideCursor();
    
    % wait for keyboard input
    KbWait();
    KbEventFlush();
    KbQueueCreate();
    KbQueueStart();
    if ti.pausetimebefore > 0
        pause(ti.pausetimebefore);
    end
    Screen('FillOval', myWindow, uint8(black), PHOTODIODE);
    Screen('Flip', myWindow);
    
    % draw the list of stimuli
    for s = 1:stimnum
        boxes = so{s}.boxes;
        boxColor = so{s}.boxColor;
        pdColor = so{s}.pdColor;
        whiteframe = uint8(white * pd.ch);
        blackframe = uint8(black);
        
        % initialize flipmiss count
        flipmiss_temp = zeros(100, 2);
        ms = 1;
        
        % prepare
        Screen('FillOval', myWindow, blackframe, PHOTODIODE);
        vbl = Screen('Flip', myWindow);
               
        % i = 1:sl{s}.totalFrame60 (from 1st frame to last frame)
        for i = 1:sl{s}.totalFrame60
            Screen('FillRect', myWindow, boxColor(:, :, i), boxes);
            Screen('FillOval', myWindow, pdColor(:, i), PHOTODIODE);
            [vbl, ~, ~, mbp] = Screen('Flip', myWindow, vbl + (1 - framebuffer) * ifi);
            if mbp > 0
                i
                mbp
                flipmiss_temp(ms, :) = [i, mbp];
                ms = ms + 1;
            end
        end

        % i = sl{s}.totalFrame60 + 1 (after original frame, 'white pd')
        Screen('FillOval', myWindow, whiteframe, PHOTODIODE);
        [vbl, ~, ~, mbp] = Screen('Flip', myWindow, vbl + (1 - framebuffer) * ifi);
        
        % after
        Screen('FillOval', myWindow, blackframe, PHOTODIODE);
        [vbl, ~, ~, mbp] = Screen('Flip', myWindow, vbl + (1 - framebuffer) * ifi);
        if s < stimnum
            for p = 1:ceil(60*ti.pausetimebetween)
                Screen('FillOval', myWindow, blackframe, PHOTODIODE);
                vbl = Screen('Flip', myWindow, vbl + (1 - framebuffer) * ifi);
            end
        end
        
        % delete if there are less than 100 flipmiss
        sl{s}.flipmiss = reshape(nonzeros(flipmiss_temp), [], 2);       
    end
    
    for p = 1:ceil(60*ti.pausetimeafter)
        Screen('FillOval', myWindow, uint8(black), PHOTODIODE);
        vbl = Screen('Flip', myWindow, vbl + (1 - framebuffer) * ifi);
    end
    
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
        savejson('obj', ex, 'filename', '/home/dlee/Documents/MATLAB/visual-stimuli/d213/archive/' + string(dt) + '.json');
    end
catch exception
    Priority(0);
    Screen('CloseAll');
    ShowCursor();
    ListenChar(0);
    exception.identifier();
end
