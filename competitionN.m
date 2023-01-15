clear;close;sca;
a_front = arduinoManager('port','/dev/ttyACM0');a_front.open;a_front.shield = 'old';
a_back = arduinoManager('port','/dev/ttyACM1');a_back.open;a_back.shield = 'new';

trialN          = 3;
tic

try
	Screen('Preference', 'SkipSyncTests', 0);
	PsychDefaultSetup(2);
	baseColor        = [1 1 1];
	screenid         = max(Screen('Screens'));
	[win, winRect]   = Screen('OpenWindow', screenid, baseColor);
	ifi              = Screen('GetFlipInterval', win);
%-------------------

	% Subject's name input
	%drawTextNow(sM,'Please enter your subject name...')
	%Screen('DrawText',win,"Enter subject name:",20, 50,[0 255 0]);
	subject= input ("Enter subject name:",'s');
	nameExp=[subject,'-',date,'.mat'];

	% Enable alpha-blending
	Screen('BlendFunction', win, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
	% the coordinats of the 2 dots
	target_x_left   = winRect(3)/3;
	target_y        = winRect(4)/2;
	target_x_right  = winRect(3)*2/3;
	%%showTime        = 5;
%-----------------
	% initial the touchpanels
	dev             = GetTouchDeviceIndices([], 1);
	info_front      = GetTouchDeviceInfo(dev(1));
	% disp(info_front);
	info_back       = GetTouchDeviceInfo(dev(2));
	% disp(info_back);
	% RestrictKeysForKbCheck(KbName('ESCAPE'));

	taskType        ='competition';
	TouchQueueCreate(win, dev(2));
	% TouchQueueStart(dev(1));
	TouchQueueCreate(win, dev(1));
	% TouchQueueStart(dev(2));
	text_left       = 'front-side was touched';
	text_right      = 'back-side was touched';
	text_both       = 'we two both get reward';
	KbReleaseWait;
	KbQueueRelease;
	
	text='Please press ESCAPE to start experiment...';
	Screen('DrawText',win,text,20, 50,[0 255 0]);
	Screen('Flip', win);
	RestrictKeysForKbCheck(KbName('ESCAPE'));
	KbWait;
	corretTrials.front = 0;
	corretTrials.back  = 0 ;
	reactiontime.front = zeros(trialN,1);
	reactiontime.back  = zeros(trialN,1);

	for i=1:trialN
		fprintf('\n===>>> Running Trial %i\n',i);
		reward_front  = 0;
		reward_back   = 0;
		touched_front = 0;
		touched_back  = 0;
		timeOut       = 5;
		
% 		
		% 	vbl           = Screen('Flip', win);
		tStart = GetSecs; % on the next frame
		while tStart < (tStart + timeOut)
			Screen('DrawDots', win, [target_x_left,target_y],100,[255 0 0]);
			Screen('DrawDots', win, [target_x_right,target_y],100,[0 255 0]);
			Screen('Flip', win);

	%Audio Manager
			if ~exist('aM','var') || isempty(aM) || ~isa(aM,'audioManager')
				aM=audioManager;
			end
			aM.silentMode = false;
			if ~aM.isSetup;	aM.setup; end

%tStart
			TouchEventFlush(dev(1));TouchEventFlush(dev(2));
			TouchQueueStart(dev(1));TouchQueueStart(dev(2)); % flush should be placed before the start
			% Process all currently pending touch events:
			q1=TouchEventAvail(dev(1));
			q2=TouchEventAvail(dev(2));
			while q1||q2
	% Event Front:
				evt_front      = TouchEventGet(dev(2), win);
				if  isempty(evt_front)
					X_front       = 0;
					Y_front       = 0;
					front.Pressed = 0;
				else
					X_front       = evt_front.MappedX; % if the event=0, you can not pass the results to the evt_front obj
					Y_front       = evt_front.MappedY;
					front.Pressed = evt_front.Pressed;
				end
				touched_front      = check_touch_position(X_front,Y_front,target_x_left,target_y);
	% Event Back:
				evt_back           = TouchEventGet(dev(1), win);
				if  isempty(evt_back)
					X_back        = 0;
					Y_back        = 0;
					back.Pressed  = 0;
				else
					X_back        = evt_back.MappedX;
					Y_back        = evt_back.MappedY;
					back.Pressed  = evt_back.Pressed;
				end
				touched_back       = check_touch_position(X_back,Y_back,1920-target_x_right ,target_y);
%Front or back press:
             
				switch taskType
					case {'competition'}
						if front.Pressed&&touched_front %
							%            driveMotor(a);
							reward_front    = 1;
							disp('front monkey touched')
							corretTrials.front = corretTrials.front+1;
							tf=GetSecs-tStart;
						end

						if back.Pressed && touched_back
							reward_back    = 1;
							disp('back monkey touched')
							corretTrials.back = corretTrials.back+1;
							tb=GetSecs-tStart;
						end
%Reward:
						if reward_front==1||reward_back==1
							Screen('FillRect', win, baseColor);
							Screen('Flip', win);
							break;
						end
					case {'cooperation'}

						if reward_front==1&&reward_back==1
							% disp('both monkey touched')
							Screen('FillRect', win, baseColor);
							Screen('Flip', win);
							break;
						end
				end
			if GetSecs-tStart>5
				break;
			end
			end
			switch taskType
				case {'competition'}
					if reward_front
						% 						GetSecs ;
						% 						tf= GetSecs;
						% 		   Screen('FillRect', win, baseColor);
						Screen('DrawText',win,text_left,1920/2,target_y,[255 0 0]);
						aM.beep(2000,0.1,0.1);
						a_front.stepper(46);
						Screen('Flip', win);
						WaitSecs(3)
						TouchQueueStop(dev(1));
						break;
					end

					if reward_back
						% 						GetSecs ;
						% 						tb= GetSecs;
						% 		   Screen('FillRect', win, baseColor);
						Screen('DrawText',win,text_right,1950/2,target_y,[0 255 0]);
						aM.beep(1000,0.1,0.1);
						a_back.stepper(46);
						Screen('Flip', win);
						WaitSecs(3)
						TouchQueueStop(dev(2));
						break;
					end
				case {'cooperation'}
					Screen('DrawText',win,text_both ,1920/2-100,target_y,[255 0 0]);
					Screen('Flip', win);
					WaitSecs(1)
					TouchQueueStop(dev(1));
					TouchQueueStop(dev(2));
					break;
			end

			% 	  if touched_front ||touched_back
			% 			break;
			% 	  end

		end
		fprintf('\n===>>> Trial %i took %.4f seconds\n',i, GetSecs-tStart);
		toc
		%% Saving experiment information and results in a file called Socialtask_SubjectX.mat (X is subject number)
		if  reward_front
			reactiontime.front(i,1) = tf;
			results.corretTrials.front = corretTrials.front;
			results.reactiontime.front = reactiontime.front;
		end
		if reward_back
			reactiontime.back(i,1) = tb;
			results.corretTrials.back = corretTrials.back;
			results.reactiontime.back = reactiontime.back;
		end
		results.subject = subject;
		results.trialN = trialN;

		results.reactiontime = reactiontime;
		results.TotalTime = toc/60;
		%fout=sprintf('Socialtask_Subject%d.mat', subject);
		save(nameExp, 'results');
        
		%%========================================
	end
	sca;
	KbReleaseWait;
catch
	
	sca;
	psychrethrow(psychlasterror);
end


function touched=check_touch_position(touch_x,touch_y,target_x,target_y)
window=50;%pixle
touched=0;
if touch_x>target_x-window&&touch_x<target_x+window&&touch_y>target_y-window&&touch_y<target_y+window
	touched=1;
end
end


