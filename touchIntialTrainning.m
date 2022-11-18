clear;close;sca;
% setup the arduino

%~~~~~~~~~~~~~~~~~~~~~~~~~
subject = '09';
nameExp = [subject,'-',date,'.mat'];
% setup the touch panels

comment ='';
% if   isempty(touchDevices)
% 	 comment = 'No Touch Screen are available, please check the usb end';
% 	 fprintf('---> %s\n',comment);
% end
% ana.expType = {'initiaTrainning','competition','envy','cooperation'};%
ana = 'initiaTrainning';
switch ana
	case {'initiaTrainning','envy'}
		 rM=1; tM=1;
		 [rMFron,tMFron,rMBack,tMBack] = inputDeviceManagement(rM,tM);
	case {'cooperation'}
		 rM=2;tM=1;
		 [rMFron,tMFron,rMBack,tMBack] = inputDeviceManagement(rM,tM);
	case 'competition'
		 rM=2;tM=2;
		 [rMFron,tMFron,rMBack,tMBack] = inputDeviceManagement(rM,tM);
end




try
	sM = screenManager('backgroundColour', [0 0 0],'blend',true);
	sv = sM.open;	fCross = fixationCrossStimulus();
	myDisc = discStimulus('colour',[0 1 0],'size',2, 'sigma', 1); 
	ms = metaStimulus;
	ms{1} = myDisc;
	%ms{2} = fCross;
	setup(ms,sM);%hhhhhhhhh

	disp('Lets Create the queue')
	if tM==1
	   tMFron.setup;
	else 
	   tMFron.setup;tMBack.setup;
	end
	

	KbReleaseWait;
	KbQueueRelease;
	drawTextNow(sM,'Please touch the screen to release the queue...')

	% other setup
	drawTextNow(sM,'Please press ESCAPE to start experiment...')
	RestrictKeysForKbCheck(KbName('ESCAPE'));
	KbWait;
	if  tM == 1
		tMFron.Qcreate(sv.win);
	else
		tMFron.Qcreate(sv.win);tMBack.Qcreate(sv.win);
	end
	trialN			= 5;
	timeOut			= 5;
    corretTrials    = 0;
	reactiontime    = zeros(trialN,1);
	for i=1:trialN
		fprintf('\n===>>> Running Trial %i\n',i);
		reward_front  = 0;
		reward_back   = 0;
		touched_front = 0;
		touched_back  = 0;

		myDisc.xPositionOut = randi([-3 3]);
		myDisc.yPositionOut = randi([-1 4]);
		myDisc.update;

		mybox     = myDisc.mvRect;
		myboxback = mybox;
		fprintf('--->>> Stim Box: %i %i %i %i\n',mybox);
		tEvent = struct('X', -inf,'Y', -inf,'Pressed', 0,'InBox', 0);
		front  = tEvent; back = tEvent;
		if tM==1
			tMFron.flush;tMFron.start;
		else
			tMFron.flush;tMFron.start;tMBack.flush;tMBack.start;
		end
		tStart = GetSecs;
		while GetSecs < (tStart + timeOut)
			draw(ms);
			animate(ms);
			vbl = flip(sM);

% 			front = tEvent; %back = tEvent;
			temp  = tMFron.eventAvail;
			while temp
				evt_front			= tMFron.getEvent(sv.win);
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
% 					draw(ms);
					reward_front = 1;
					corretTrials = corretTrials+1;
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
				rMFron.stepper(46); % in degree
				disp('good monkey front');
				tMFron.stop;
				break
			end
		end

		fprintf('\n===>>> Trial %i took %.4f seconds\n',i, GetSecs-tStart);
		reactiontime(i,1) = GetSecs-tStart;
		sM.drawBackground;
		if reward_front
		   drawTextNow(sM,'FRONT CORRECT!')
		end
% 		if reward_back
% 			drawTextNow(s,'BACK CORRECT!')
% 		end
		WaitSecs(1);
	end
	data.reactiontime = reactiontime;
	data.tiralNum     = trialN;
	data.correctTrs   = corretTrials;
    save(nameExp,'-struct','data')
    rMFron.stop;
	tfrontM.stop;
	sM.close;ms.reset;sca;
catch ME
	sM.close;sca;
	rethrow(ME)
end

function [rMFron,tMFron,rMBack,tMBack]=inputDeviceManagement(r,t)
         touchDevices = GetTouchDeviceIndices([], 1);
         if     r==1&&t==1
			rMFron = arduinoManager('ports','/dev/ttyACM0');rMFron.openGUI = false;rMFron.open;rMFron.shield = 'old';
			tMFron = touchManager;    tMFron.devices = touchDevices(1);
			rMBack = [];tMBack=[];
		 elseif r==2&&t==1
		   rMFron = arduinoManager('ports','/dev/ttyACM0');rMFron.openGUI = false;rMFron.open;rMFron.shield = 'old';
	       rMBack = arduinoManager('ports','/dev/ttyACM0');rMBack.openGUI = false;rMBack.open;rMback.shield = 'new';  
           tMFron = touchManager; tMFron.devices = touchDevices(1);tMBack=[];
		 elseif r==2&&t==2
		   rMFron = arduinoManager('ports','/dev/ttyACM0');rMFron.openGUI = false;rMFron.open;rMFron.shield = 'old';
	       rMBack = arduinoManager('ports','/dev/ttyACM0');rMBack.openGUI = false;rMBack.open;rMback.shield = 'new';  
           tMFron = touchManager; tMFron.devices = touchDevices(1);
	       tMBack = touchManager; tMBack.devices = touchDevices(2);
		end
end
function touched = checkBox(x, y, box)
	touched = 0;
	checkWin= 100;
	if x>box(1)-checkWin && x<box(3)+checkWin && y>box(2)-checkWin&&y<box(4)+checkWin
	   touched = 1;
	end
end


