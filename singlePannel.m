% clear 
% delete(instrfind({'Port'},{'COM8'}))
% a  = arduino('com8','uno','libraries','I2C');
% a.pinMode(8,'output');
% a.pinMode(9,'output');
% a.pinMode(12,'output');
% a.pinMode(13,'output');
% a.pinMode(3,'output');
% a.pinMode(11,'output');
% a.pinMode(5,'input');
% clear;close;sca;
a=arduinoManager();a.openGUI=false;a.open;


try 
Screen('Preference', 'SkipSyncTests', 0);
PsychDefaultSetup(2);
baseColor      = [128 128 128];
% PsychImaging('PrepareConfiguration');
% PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');
screenid       = max(Screen('Screens'));
[win, winRect] = Screen('OpenWindow', screenid, baseColor);
% Query frame duration: We use it later on to time 'Flips' properly for an
% animation with constant framerate:
ifi = Screen('GetFlipInterval', win);

% Enable alpha-blending
Screen('BlendFunction', win, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
% the coordinats of the 2 dots
target_x_left    = winRect(3)/3;
target_y         = winRect(4)/2;
target_x_right   = winRect(3)*2/3;
showTime         = 10;

% initial the touchpanels
dev               = GetTouchDeviceIndices([], 1);
info_front        = GetTouchDeviceInfo(dev);
disp(info_front);
% info_back      = GetTouchDeviceInfo(dev(2));
% disp(info_back);
RestrictKeysForKbCheck(KbName('ESCAPE'));
trialN          = 20;
TouchQueueCreate(win, dev);
% TouchQueueStart(dev);
for i=1:trialN
	vbl         = Screen('Flip', win);
    tstart      = vbl + ifi; %start is on the next frame
	reward      = 0;
	showTime    = i*10;
	TouchEventFlush(dev);
	TouchQueueStart(dev);
	while vbl < tstart + showTime
		Screen('DrawDots', win, [target_x_left,target_y],100,[255 0 0]);
		Screen('DrawDots', win, [target_x_right,target_y],100,[0 255 0]);
		vbl        = Screen('Flip', win, vbl + 0.5 * ifi);


    % Wait for the go!
		KbReleaseWait;
		touch_times=0;
		q_num=TouchEventAvail(dev);
      % Process all currently pending touch events:
		while ~KbCheck&&q_num>1
        % Process next touch event 'evt':
			[evt,nremaining] = TouchEventGet(dev, win,5); %[event, nremaining] = TouchEventGet(deviceIndex, windowHandle [, maxWaitTimeSecs=0]
			X                = evt.MappedX;
			Y                = evt.MappedY;
			touched          = check_touch_position(X,Y,target_x_left,target_y);
% 			evt
% 			nremaining
			if evt.Pressed && touched&&evt.Type==2
				reward = 1;
				disp('good monkey')
				break;
% 		else
% 			disp('hello,human')
			end
		end
	   if reward
		   Screen('FillRect', win, baseColor)
		   vbl    = Screen('Flip', win);
		   tstart = vbl + ifi; 
		   touch_times=touch_times+1;
		   driveMotor(a);
           clear evt
		   q_num=0;

		   TouchQueueStop(dev);
		   pause(1)
		  break;
	  end
	end
end
sca
catch
  % ---------- Error Handling ---------- 
  % If there is an error in our code, we will end up here.

  % The try-catch block ensures that Screen will restore the display and return us
  % to the MATLAB prompt even if there is an error in our code.  Without this try-catch
  % block, Screen could still have control of the display when MATLAB throws an error, in
  % which case the user will not see the MATLAB prompt.
%     Screen('Close',win);
  sca;
  % stop the motor
%   stop_motor(a);
  % Restores the mouse cursor.

%   ShowCursor;

  % Restore preferences
%   Screen('Preference', 'VisualDebugLevel', oldVisualDebugLevel);
%   Screen('Preference', 'SuppressAllWarnings', oldSupressAllWarnings);

  % We throw the error again so the user sees the error description.
  psychrethrow(psychlasterror);
end


function touched=check_touch_position(touch_x,touch_y,target_x,target_y)
    window  = 200;%pixle
	touched = 0;
    if touch_x>target_x-window&&touch_x<target_x+window&&touch_y>target_y-window&&touch_y<target_y+window
	   touched=1;
	end
end
function driveMotor(a)
 delaylength = 0.01;
 nbstep      = 8;
 for       i = 1:nbstep
%   check_sensor(a);
  a.digitalWrite(9, 0);   %//ENABLE CH A
  a.digitalWrite(8, 1);   %//DISABLE CH B
  a.digitalWrite(12,1);   %//Sets direction of CH A
  a.digitalWrite(3, 1);    %//Moves CH A
  pause(delaylength);
   
%   check_sensor(a);
  a.digitalWrite(9, 1);   %//DISABLE CH A
  a.digitalWrite(8, 0);   %//ENABLE CH B
  a.digitalWrite(13,0);  %//Sets direction of CH B
  a.digitalWrite(11,1);   %//Moves CH B
  pause(delaylength);
  
%   check_sensor(a);
  a.digitalWrite(9, 0); %//ENABLE CH A
  a.digitalWrite(8, 1); %//DISABLE CH B
  a.digitalWrite(12,0); %//Sets direction of CH A
  a.digitalWrite(3, 1);  %//Moves CH A
  pause(delaylength);
  
%   check_sensor(a);
  a.digitalWrite(9, 1);   %//DISABLE CH A
  a.digitalWrite(8, 0);   %//ENABLE CH B
  a.digitalWrite(13,1);  %//Sets direction of CH B
  a.digitalWrite(11,1);        %//Moves CH B
  pause(delaylength);
 end
  stop_motor(a);
end
%   clear(a);
function stop_motor(a)
    delaylength    = 0.01;% in seconds
    a.digitalWrite(9,1);  %//DISABLE CH A
    a.digitalWrite(3, 0); %//stop Move CH A
    a.digitalWrite(8,1);  %//DISABLE CH B
    a.digitalWrite(11,0); %//stop Move CH B 
    pause(delaylength);
end

function check_sensor(a)
  sensor    = digitalReas(5);
  if sensor ==0
     stop_motor(a);
  end
end
