function linearcheck(n)
% FUNCTION linearcheck(n)
%
% Show a full screen of n linearly-space values.
%
% This stimulus is used to linearize and check the linearity of 
% a stimulus monitor. It presents `n` grey-scale, full-screen
% luminance values on the range [0, 255]. The measured luminace
% values can be used to generate either a single gamma-correction
% value, or a full normalized gamma table. A full gamma
% table can be loaded before a stimulus, by calling:
%
% 	Screen('LoadNormalizedGammaTable', table, 1);
%
% Edited by Dongsoo Lee on 08/18/2020 (based on LinearCheck.m)


% number of arguments?
if nargin == 0
    n = 17;

% parameters
% -----------------------------------------------------------
REPEAT = 5;
PAUSETIME = 0.5;  
% -----------------------------------------------------------

try
    % check if the installed Psychtoolbox is based on OpenGL ('Screen()'),
    %       and provide a  consistent mapping of key codes
    AssertOpenGL;
    KbName('UnifyKeyNames');                        %  = PsychDefaultSetup(1);
    
    % load KbCheck because it takes some time to read for the first time
    while KbCheck(); end
    
    ListenChar(2);                                  % suppress output of keypresses
    
    % get the screen numbers & draw to the external screen if available
    myScreen = max(Screen('Screens'));
    
    % open an on screen window
    [myWindow, windowRect] = Screen('OpenWindow', myScreen, 255/2);
    Screen('ColorRange', myWindow, 255, [], 0);
    % set the maximum priority number
    Priority(MaxPriority(myWindow));
    
    % get index of black and white
    black = BlackIndex(myScreen);                   % 0
    white = WhiteIndex(myScreen);                   % 255
    meanIntensity = ((black + white + 1)/2) - 1;    % 127
    
    % get inter-flip interval (inverse of frame rate) & calculate fliptime
    ifi = Screen('GetFlipInterval', myWindow);
    flipFrame = round(0.03/ifi);
    flipTime = flipFrame * ifi;
    
    % get the size of the on screen window
    [xSize, ySize] = Screen('WindowSize', myWindow);
    
    % set intensity
    intensity = [0:256/(n-1):256];  % CalibrateMonitorPhotometer.m
    
    % prepare for the first screen
    Screen('FillRect', myWindow, black);
    Screen('Flip', myWindow);
    HideCursor();
    KbWait();
    % wait for keyboard input
    KbEventFlush();
    KbQueueCreate();
    KbQueueStart();
    pause(PAUSETIME);
        
    % to start recording computer	
    Screen('FillRect', myWindow, white);
    vbl = Screen('Flip', myWindow);
    
    % draw intensities
    for i = 1:n
    	for r = 1:REPEAT
    	    Screen('FillRect', myWindow, intensity(i));
    	    vbl = Screen('Flip', myWindow, vbl + (flipFrame - 0.5) * ifi);
    	end
    end
    
    Screen('FillRect', myWindow, black);
    vbl = Screen('Flip', myWindow, vbl + (flipFrame - 0.5) * ifi);
    
    pause(10);
    
    Screen('CloseAll');
    ShowCursor();
    ListenChar(0);
catch exception
    Screen('CloseAll');
    ShowCursor();
    ListenChar(0);
    exception.identifier();
end
