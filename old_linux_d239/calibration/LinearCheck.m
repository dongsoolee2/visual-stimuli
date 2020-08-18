function LinearCheck(n)
% FUNCTION LinearCheck(n)
%
% Show a full screen of n linearly-space values.
%
% This stimulus is used to linearize and check the linearity of 
% a stimulus monitor. It presents `n` grey-scale, full-screen
% luminance values on the range [0, 255]. The measured luminace
% values can be used to generate either a single gamma-correction
% value, or a full normalized gamma table. The gamma value can
% be set directly by going to System Settings > Display and Monitor >
% Gamma, and setting the gamma value for screen **2**. A full gamma
% table can be loaded before a stimulus, by calling:
%
% 	Screen('LoadNormalizedGammaTable', table, 1);
%
% (C) ?-2016 The Baccus Lab

AssertOpenGL;
try
	ListenChar(2);
    myscreen=max(Screen('Screens'));
    [xsize ysize]=Screen('WindowSize', myscreen);
    black=BlackIndex(myscreen);
    white=WhiteIndex(myscreen);
    MeanIntensity=((black+white+1)/2)-1;
    mywindow=Screen('OpenWindow',myscreen,black);
    ifi=Screen('GetFlipInterval',mywindow);
    [vbl]=Screen('Flip',mywindow);
    
    Frames=20;
   
	if nargin == 0
		n = 20;
	end
    Intensities=linspace(0, 255, n);
    
	fprintf('\n\nLinear check required time: %0.4f', Frames * ifi * n * 2);
	fprintf('\nPress any key to start stimulus\n\n');
    
    photodiode=ones(4,1);
    photodiode(1,:)=xsize/10*8.75;
    photodiode(2,:)=ysize/10*.75;
    photodiode(3,:)=xsize/10*8.75+120;
    photodiode(4,:)=ysize/10*.75+120;
    
    Screen('FillRect', mywindow, black);
    Screen('Flip',mywindow);
    
    KbWait;
    
    HideCursor
    ListenChar(2);
    Priority(MaxPriority(mywindow));
    
    Screen('FillOval', mywindow, black, photodiode);
    vbl=Screen('Flip',mywindow, vbl+ifi+.001);
    
    Screen('FillOval', mywindow, white, photodiode);
    vbl=Screen('Flip',mywindow, vbl+(ifi*29)+.001);
   
    for m=1:n
        Intensity=Intensities(m);
        for l=1:Frames
            Screen('FillRect', mywindow, Intensity);
            vbl=Screen('Flip',mywindow, vbl+ifi+.001);
            if KbCheck
                break;
            end
        end
        if KbCheck
            break;
        end
    end
    Screen('CloseAll');
    
    Screen('CloseAll');
    ListenChar(0);
    ShowCursor;

catch exception
    Screen('CloseAll');
    ListenChar(0);
    ShowCursor;
    disp(exception)
end
