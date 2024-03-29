clear;close;sca;
% a_front = arduinoManager('port','/dev/ttyACM0');a_front.open;a_front.shield = 'new';
% 
% a_back = arduinoManager('port','/dev/ttyACM2');a_back.open;a_back.shield = 'old';

% delete(instrfind({'Port'},{'COM8'}))
% a  = arduino('com8','uno','libraries','I2C');
% a.pinMode(8,'output');
% a.pinMode(9,'output');
% a.pinMode(12,'output');
% a.pinMode(13,'output');
% a.pinMode(3,'output');
% a.pinMode(11,'output');
% a.pinMode(5,'input');
% t=1;
% while t<20
% 	
% t=t+1;
% keyIsDown = KbCheck([dev(1)])
% pause(2)
% end

try 
Screen('Preference', 'SkipSyncTests', 0);
Screen('Preference', 'VisualDebugLevel', 3);
Screen('Preference', 'Verbosity', 10);
PsychDefaultSetup(2);
baseColor          = [1 1 1];
% PsychImaging('PrepareConfiguration');
% PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');
screenid            = max(Screen('Screens'));
[win, winRect]   = Screen('OpenWindow', screenid, baseColor);
% Query frame duration: We use it later on to time 'Flips' properly for an
% animation with constant framerate:
ifi                     = Screen('GetFlipInterval', win);

% Enable alpha-blending
Screen('BlendFunction', win, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
% the coordinats of the 2 dots
target_x_left   = winRect(3)/3;
target_y        = winRect(4)/2;
target_x_right  = winRect(3)*2/3;
showTime        = 10;

% initial the touchpanels
dev             = GetTouchDeviceIndices([], 1);
info_front      = GetTouchDeviceInfo(dev(1));
disp(info_front);
info_back       = GetTouchDeviceInfo(dev(2));
disp(info_back);
% RestrictKeysForKbCheck(KbName('ESCAPE'));
trialN          = 15;
taskType        ='competition';
taskType        ='cooperation';
%sca
%taskType        ='co-action';

TouchQueueCreate(win, dev(1));
% TouchQueueStart(dev(1));
TouchQueueCreate(win, dev(2));
% TouchQueueStart(dev(2));
text_left       = 'front side monkey touched the target';
text_right      = 'back side monkey touched the target';
text_both       = ' we two both get reward';
KbReleaseWait;
KbQueueRelease;
% drawTextNow(sM,'Please press ESCAPE to start experiment...')
RestrictKeysForKbCheck(KbName('ESCAPE'));
KbWait;

TouchQueueStart(dev(1)); % flush should be placed before the start
TouchQueueStart(dev(2));
for i=1:trialN
	fprintf('\n===>>> Running Trial %i\n',i);
	reward_front  = 0;
	reward_back   = 0;
	touched_front = 0;
	touched_back  = 0;
	timeOut       = 5;
% 	vbl           = Screen('Flip', win);
    tStart = GetSecs; % on the next frame
	TouchEventFlush(dev(1));TouchEventFlush(dev(2));
	while tStart < (tStart + timeOut)
    	Screen('DrawDots', win, [target_x_left,target_y],100,[255 0 0]);
    	Screen('DrawDots', win, [target_x_right,target_y],100,[0 255 0]);
    	Screen('Flip', win);
   
   
    % Wait for the go!
%     KbReleaseWait;
%   while ~KbCheck
   
   
      % Process all currently pending touch events:
	  q1=TouchEventAvail(dev(1));
	  q2=TouchEventAvail(dev(2));
	  while 1
             evt_front      = TouchEventGet(dev(1), win);
		  if  isempty(evt_front)
			  X_front       = 0;
			  Y_front       = 0;
			  front.Pressed = 0;
		  else
			  X_front       = evt_front.MappedX; % if the event=0, you can not pass the results to the evt_front obj
			  Y_front       = evt_front.MappedY;
			  front.Pressed = evt_front.Pressed;
		  end
		 
		  touched_front      = check_touch_position(X_front,Y_front,target_x_right,target_y);

		  evt_back           = TouchEventGet(dev(2), win);
		  if  isempty(evt_back)
			  X_back        = 0;
			  Y_back        = 0;
			  back.Pressed  = 0;
		  else
			  X_back        = evt_back.MappedX;
			  Y_back        = evt_back.MappedY;
			  back.Pressed  = evt_back.Pressed;
		  end
		  %[event, nremaining] = TouchEventGet(deviceIndex, windowHandle [, maxWaitTimeSecs=0]
		  touched_back       = check_touch_position(X_back,Y_back,1920-target_x_left ,target_y);
%           touched_back =1;
% 		  back.Pressed =1;
		switch taskType
			case {'competition'}
				if front.Pressed&&touched_front %
					%            driveMotor(a);
					reward_front    = 1;
					disp('front monkey touched')
				end
		
				if back.Pressed && touched_back
					%            driveMotor(a);
					reward_back    = 1;
					disp('back monkey touched')
					% 		   TouchQueueStop(dev(2));
					% 		   disp('good monkey on left')
				end
		
				if reward_front==1||reward_back==1
					% 			disp('both monkey touched')
					Screen('FillRect', win, baseColor);
					Screen('Flip', win);
					break;
				end
			case {'cooperation'}
				if front.Pressed&&touched_front %
					%            driveMotor(a);
					reward_front    = 1;
					disp('front monkey touched')
					Screen('DrawDots', win, [target_x_left,target_y],100,[255 0 0]);
					Screen('Flip', win);
					TouchQueueStart(dev(2))
					while 1
						evt_back           = TouchEventGet(dev(2), win);
						if  isempty(evt_back)
							X_back        = 0;
							Y_back        = 0;
							back.Pressed  = 0;
						else
							X_back        = evt_back.MappedX;
							Y_back        = evt_back.MappedY;
							back.Pressed  = evt_back.Pressed;
						end
						%[event, nremaining] = TouchEventGet(deviceIndex, windowHandle [, maxWaitTimeSecs=0]
						touched_back       = check_touch_position(X_back,Y_back,1920-target_x_left ,target_y);
						if back.Pressed==1&&touched_back==1
							reward_back=1;
							disp('back monkey touched')
                            break;
						end
					end
				elseif back.Pressed && touched_back
						reward_back    = 1;
						disp('back monkey touched')
						Screen('DrawDots', win, [target_x_right,target_y],100,[0 255 0]);
						Screen('Flip', win);
						TouchQueueStart(dev(1));
						while 1
							evt_front          = TouchEventGet(dev(1), win);
							if  isempty(evt_front)
								X_front       = 0;
								Y_front       = 0;
								front.Pressed = 0;
							else
								X_front       = evt_front.MappedX;   % if the event=0, you can not pass the results to the evt_front obj
								Y_front       = evt_front.MappedY;
								front.Pressed = evt_front.Pressed;
							end

							touched_front      = check_touch_position(X_front,Y_front,target_x_right,target_y);
							if front.Pressed&&touched_front %
								%            driveMotor(a);
								reward_front    = 1;
								disp('front monkey touched')
								break;
							end
						end
				end
				if reward_front==1&&reward_back==1
					% 			disp('both monkey touched')
					Screen('FillRect', win, baseColor);
					Screen('Flip', win);
					break;
				end
			case{'co-action'}
				if front.Pressed&&touched_front %
					reward_front    = 1;
					disp('front monkey touched')
					Screen('DrawDots', win, [target_x_left,target_y],100,[255 0 0]);
					Screen('DrawText',win,text_left,1920/2,target_y,[255 0 0]);
					Screen('Flip', win);
					TouchQueueStart(dev(2))
					while 1
						evt_back           = TouchEventGet(dev(2), win);
						if  isempty(evt_back)
							X_back        = 0;
							Y_back        = 0;
							back.Pressed  = 0;
						else
							X_back        = evt_back.MappedX;
							Y_back        = evt_back.MappedY;
							back.Pressed  = evt_back.Pressed;
						end
						%[event, nremaining] = TouchEventGet(deviceIndex, windowHandle [, maxWaitTimeSecs=0]
						touched_back       = check_touch_position(X_back,Y_back,1920-target_x_left ,target_y);
						if back.Pressed==1&&touched_back==1
							reward_back=1;
							disp('back monkey touched')
							Screen('DrawText',win,text_right,1950/2,target_y,[0 255 0]);
							Screen('Flip', win);
							break;
						end
					end
				elseif back.Pressed && touched_back
					reward_back    = 1;
					disp('back monkey touched')
					Screen('DrawDots', win, [target_x_right,target_y],100,[0 255 0]);
					Screen('DrawText',win,text_right,1950/2,target_y,[0 255 0]);
					Screen('Flip', win);
					TouchQueueStart(dev(1));
					while 1
						evt_front          = TouchEventGet(dev(1), win);
						if  isempty(evt_front)
							X_front       = 0;
							Y_front       = 0;
							front.Pressed = 0;
						else
							X_front       = evt_front.MappedX;   % if the event=0, you can not pass the results to the evt_front obj
							Y_front       = evt_front.MappedY;
							front.Pressed = evt_front.Pressed;
						end

						touched_front      = check_touch_position(X_front,Y_front,target_x_right,target_y);
						if front.Pressed&&touched_front %
							%            driveMotor(a);
							reward_front    = 1;
							disp('front monkey touched')
							Screen('DrawText',win,text_left,1920/2,target_y,[255 0 0]);
							Screen('Flip', win);
							break;
						end
					end
				end
		end
	  end
	  switch taskType
		  case {'competition'}
			  if reward_front
				  % 		   Screen('FillRect', win, baseColor);
				  Screen('DrawText',win,text_left,1920/2,target_y,[255 0 0]);
				  Screen('Flip', win);
				  WaitSecs(1)
% 				  TouchQueueStop(dev(1));
				  break;
			  end

			  if reward_back
				  % 		   Screen('FillRect', win, baseColor);
				  Screen('DrawText',win,text_right,1950/2,target_y,[0 255 0]);
				  Screen('Flip', win);
				  WaitSecs(1)
% 				  TouchQueueStop(dev(2));
				  break;
			  end
		  case {'cooperation'}
			  Screen('DrawText',win,text_both ,1920/2-100,target_y,[255 0 0]);
			  Screen('Flip', win);
			  WaitSecs(1)
% 			  TouchQueueStop(dev(1));
% 			  TouchQueueStop(dev(2));
			  break;
		  case{'co-action'}
			  Screen('FillRect', win, baseColor);
			  Screen('Flip', win);
	  end

	  % 	  if touched_front ||touched_back
	  % 			break;
	  % 	  end

	end
	fprintf('\n===>>> Trial %i took %.4f seconds\n',i, GetSecs-tStart);
end
clear;sca;
catch ME
	getReport(ME);
  % ---------- Error Handling ---------- 
  % If there is an error in our code, we will end up here.

  % The try-catch block ensures that Screen will restore the display and return us
  % to the MATLAB prompt even if there is an error in our code.  Without this try-catch
  % block, Screen could still have control of the display when MATLAB throws an error, in
  % which case the user will not see the MATLAB prompt.
  Screen('Close',win);
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
    window=100;%pixle
	touched=0;
    if touch_x>target_x-window&&touch_x<target_x+window&&touch_y>target_y-window&&touch_y<target_y+window
	   touched=1;
	end
end


