clear;close;sca;
a=arduinoManager();a.openGUI=false;a.open;a.shield='old';

try
	s = screenManager('backgroundColour', [0 0 0],'blend',true);
	sv = s.open;
	fCross = fixationCrossStimulus();
	myDisc = discStimulus('colour',[0 1 0],'size',4, 'sigma', 1); 

	ms = metaStimulus;
	ms{1} = myDisc;
	%ms{2} = fCross;
	setup(ms,s);

	% initiate the touchpanels
% 	[dev, names, info] = GetTouchDeviceIndices([], 1);
% 	if length(dev) ~= 2; error('Need TWO touch panels!'); end
% 	q1				= dev(1);
% 	q2				= dev(2);
% 	info_front      = GetTouchDeviceInfo(q1);
% 	info_back       = GetTouchDeviceInfo(q2);
% 	
% 	disp('=================FRONT')
% 	disp(info_front);
% 	disp('=================BACK')
% 	disp(info_back);

	disp('Lets Create the queue')
    tfrontM=touchManager; % touch for front panel
	tfrontM.setup(sv.win);
	tfrontM.open(sv.win)
	KbReleaseWait;
	KbQueueRelease;
	drawTextNow(s,'Please touch the screen to release the queue...')

	% other setup
	drawTextNow(s,'Please press ESCAPE to start experiment...')
	RestrictKeysForKbCheck(KbName('ESCAPE'));
	KbWait;

	trialN			= 20;
	timeOut			= 5;

	for i=1:trialN
		fprintf('\n===>>> Running Trial %i\n',i);
		reward_front  = 0;
% 		reward_back   = 0;
		touched_front = 0;
% 		touched_back  = 0;

		myDisc.xPositionOut = randi([-5 5]);
		myDisc.yPositionOut = randi([0 10]);
		myDisc.update;

		mybox = myDisc.mvRect;
		myboxback = mybox;
		fprintf('--->>> Stim Box: %i %i %i %i\n',mybox);
		tEvent = struct('X', -inf,'Y', -inf,'Pressed', 0,'InBox', 0);
% 		front  = tEvent; %back = tEvent;

        tfrontM.flush;
		tStart = GetSecs;
		while GetSecs < (tStart + timeOut)
			draw(ms);
			animate(ms);
			vbl = flip(s);

			front = tEvent; %back = tEvent;
			temp  = tfrontM.eventAvail;
			while temp
				evt_front			= tfrontM.getEvent(sv.win);
% 				TouchEventGet(q1, sv.win);
				if  ~isempty(evt_front)
					front.X         = evt_front.MappedX;
					front.Y         = evt_front.MappedY;
					front.Pressed   = evt_front.Pressed;
				end
				front.InBox = checkBox(front.X, front.Y, mybox);
% 				fprintf('...front x=%.2f y=%.2f\n',front.X,front.Y)
% 				evt_back			= TouchEventGet(q2, sv.win);
% 				if  ~isempty(evt_back)
% 					back.X			= evt_back.MappedX;
% 					back.Y			= evt_back.MappedY;
% 					back.Pressed    = evt_back.Pressed;
% 					myboxback(1)    = sv.width - mybox(3);
% 					myboxback(3)    = sv.width - mybox(1);
% 				end
% 				back.InBox = checkBox(back.X, back.Y, myboxback);
% 				fprintf('...back x=%.2f y=%.2f\n',back.X,back.Y)
				if front.Pressed && front.InBox
					draw(ms);
					reward_front = 1;
% 					disp('good monkey front');
					break;
				end
% 				if back.Pressed && back.InBox
% 					draw(ms);
% 					reward_back    = 1;
% 					disp('good monkey back');
% 					break;
% 				end
			end

			if reward_front %|| reward_back
				a.stepper(46); % in degree
				tfrontM.stop;
				break
			end
		end

		fprintf('\n===>>> Trial %i took %.4f seconds\n',i, GetSecs-tStart);
		s.drawBackground;
		if reward_front
		   drawTextNow(s,'FRONT CORRECT!')
		end
% 		if reward_back
% 			drawTextNow(s,'BACK CORRECT!')
% 		end
		WaitSecs(1);
	end

	s.close;ms.reset;	sca;
catch ME
	s.close;
	sca
	rethrow(ME)
end


function touched = checkBox(x, y, box)
	touched = 0;
	checkWin= 50;
	if x>box(1)-checkWin && x<box(3)+checkWin && y>box(2)-checkWin&&y<box(4)+checkWin
		touched = 1;
	end
end


