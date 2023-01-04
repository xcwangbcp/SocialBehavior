clear;close;sca;
% setup the arduino

%~~~~~~~~~~~~~~~~~~~~~~~~~
subject = '09';
nameExp = [subject,'-',date,'.mat'];
% setup the touch panels

comment ='';
% if   isempty(toucbbbhDevices)
% 	 comment = 'No Touch Screen are available, please check the usb end';
% 	 fprintf('---> %s\n',comment);
% end
ana.expType = {'Control','Audience Effect','Altruism ','Envy','Competition','Cooperation','test2touch'};%
ana.taskName = ana.expType{4};
rewardFront = 0; rewardBack = 0;
touchFront  = 1; rouchBcak  = 0;
deviceUsed  = [rewardFront touchFront rewardBack rewardBack];

% [rM,tM]     = inputDeviceManagement(ana.taskNam);
[rM,tM]     = inputDeviceManagement(deviceUsed);
if ~exist('aM','var') || isempty(aM) || ~isa(aM,'audioManager')
	aM=audioManager;
end
aM.silentMode = false;
if ~aM.isSetup;	aM.setup; end


try
	sM = screenManager('backgroundColour', [0 0 0],'blend',true);
	sv = sM.open;	Cross = fixationCrossStimulus();
	myDisc = discStimulus('colour',[0 1 0],'size',2, 'sigma', 1); 
	ms = metaStimulus;
	ms{1} = myDisc;
	%ms{2} = fCross;
	setup(ms,sM);%hhhhhhhhh

	disp('Lets Create the queue')

	if isempty(tM.Back)
	   tM.Fron.setup;
	else 
	   tM.Fron.setup;tM.Back.setup;
	end
% % % 	
	KbReleaseWait;
	KbQueueRelease;
	drawTextNow(sM,'Please touch the screen to release the queue...')

% 	other setup
	drawTextNow(sM,'Please press ESCAPE to start experiment...')
	RestrictKeysForKbCheck(KbName('ESCAPE'));
	KbWait;
	if  isempty(tM.Back)
		tM.Fron.Qcreate(sv.win);
	else
		tM.Fron.Qcreate(sv.win);tM.Back.Qcreate(sv.win);
	end
	trialN			     = 10;
	timeOut			     = 5;
    corretTrialsFront    = 0;
	reactiontimeFront    = zeros(trialN,1);
	corretTrialsBack     = 0;
    reactiontimeBack     = zeros(trialN,1);
	for i=1:trialN
		fprintf('\n===>>> Running Trial %i\n',i);
		reward_front  = 0; touched_front = 0;
		reward_back   = 0; touched_back  = 0;
	    rewardType    ='';

% 		myDisc.xPositionOut = randi([-3 3]);
% 		myDisc.yPositionOut = randi([-1 4]);
		myDisc.xPositionOut = 0;
		myDisc.yPositionOut = 0;
		myDisc.update;

		mybox     = myDisc.mvRect;
		myboxback = mybox;
		fprintf('--->>> Stim Box: %i %i %i %i\n',mybox);
		tEvent = struct('X', -inf,'Y', -inf,'Pressed', 0,'InBox', 0);
		front  = tEvent; back = tEvent;
		if isempty(tM.Back)
			tM.Fron.flush;tM.Fron.start;
		else
			tM.Fron.flush;tM.Fron.start;
			tM.Back.flush;tM.Back.start;
		end

		tStart = GetSecs;
		while GetSecs < (tStart + timeOut)
			draw(ms);
			animate(ms);
			flip(sM);

			if isempty(tM.Back)
				fronEventAvail  = tM.Fron.eventAvail;
				EventAvail      = fronEventAvail;
			else
				fronEventAvail  = tM.Fron.eventAvail;
				backEventAvail  = tM.Back.eventAvail;
				EventAvail      = fronEventAvail||backEventAvail;
			end

			while EventAvail%&&~KbCheck
				if	isempty(tM.Back)
					evt_front			  = tM.Fron.getEvent(sv.win);
					if  ~isempty(evt_front)
						front.X         = evt_front.MappedX;
						front.Y         = evt_front.MappedY;%
						front.Pressed   = evt_front.Pressed;
					end
					front.InBox = checkBox(front.X, front.Y, mybox);
					fprintf('...front x=%.2f y=%.2f\n',front.X,front.Y);
					if front.Pressed && front.InBox
						touched_front = 1;
						tM.Fron.stop;
						% 					draw(ms);
					end
				else
					evt_front		= tM.Fron.getEvent(sv.win);
					if  ~isempty(evt_front)
						front.X         = evt_front.MappedX;
						front.Y         = evt_front.MappedY;
						front.Pressed   = evt_front.Pressed;
					end
					front.InBox = checkBox(front.X, front.Y, mybox);
					fprintf('...front x=%.2f y=%.2f\n',front.X,front.Y)
					evt_back              = tM.Back.getEvent(sv.win);
					if  ~isempty(evt_back)
						back.X			= evt_back.MappedX;
						back.Y			= evt_back.MappedY;
						back.Pressed    = evt_back.Pressed;
					end
					back.InBox = checkBox(back.X, back.Y, myboxback);
					fprintf('...back x=%.2f y=%.2f\n',back.X,back.Y)
					if front.Pressed && front.InBox
						touched_front = 1;
						tM.Fron.stop;
						% 					draw(ms);
					end
					if back.Pressed && back.InBox%&&front.Pressed && front.InBox
						touched_back = 1;
						tM.Back.stop;
					end

				end
				switch  ana.taskNam
					case {'Control','Audience Effect','Altruism','Envy','Competition'}
						if touched_front == 1 || touched_back==1
% 							corretTrialsFront = corretTrialsFront+1;
							sM.drawBackground;
							sM.flip
							break;
						end
					case {'Co-action','test2touch','Cooperation'}
						if touched_front == 1 && touched_back==1
							corretTrialsBack = corretTrialsBack+1;
							sM.drawBackground;
							sM.flip
							break;
						end
				end
			end
			switch  ana.taskNam
				case {'Control','Audience Effect'}
					if touched_front == 1 
                        disp('reward frontside monkey')
						break;
					end
				case {'Envy'}
					if touched_front == 1 
                        disp('reward backside monkey')
						WaitSecs(10)
						disp('reward frontside monkey')
						break;
					end
				case {'Altruism'}
					if touched_front == 1
						disp('reward backside monkey')
						break;
					end
				case {'Competition'}
					if touched_front == 1
						disp('reward frontside monkey')
						break;
					elseif touched_back==1
						disp('reward backside monkey')
						break;
					end
				case {'Co-action','test2touch','Cooperation'}
					if touched_front == 1 && touched_back==1
						corretTrialsBack = corretTrialsBack+1;
						sM.drawBackground;
						sM.flip
						break;
					end
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
	data.correctTrs   = corretTrialsFront;
    save(nameExp,'-struct','data')
%     rM.Fron.stopStepper;
	tM.Fron.stop;
	sM.close;ms.reset;sca;
catch ME
	disp('errors happen just now')
	sM.close;sca;
	rethrow(ME)
end

function [rM,tM]=inputDeviceManagement(d) %taskName
         touchDevices = GetTouchDeviceIndices([], 1);
		 port         = serialportlist;
		 taskName ='s';
		 switch taskName
			case {'Control','Audience Effect'}
		    	rM.Fron = arduinoManager('ports',port(2));rM.Fron.openGUI = false;rM.Fron.open;rM.Fron.shield = 'old';
				tM.Fron = testTouchManager;    tM.Fron.devices = touchDevices(1);
				rM.Back = [];tM.Back=[];
			case {'Altruism'}
				tM.Fron = testTouchManager; tM.Fron.devices = touchDevices(1);
		    	rM.Back  = arduinoManager('ports',port(3));rM.Back.openGUI = false;rM.Back.open;rM.Back.shield = 'new';
				rM.Fron=[];tM.Back=[];
			 case {'Envy','Competition','Co-action','Cooperation'}
		    	rM.Fron = arduinoManager('port',port(2));rM.Fron.openGUI = false;rM.Fron.open;rM.Fron.shield = 'old';
	        	rM.Back = arduinoManager('port',port(3));rM.Back.openGUI = false;rM.Back.open;rM.Back.shield = 'new';  
            	tM.Fron = testTouchManager; tM.Fron.devices = touchDevices(1);
	        	tM.Back = testTouchManager; tM.Back.devices = touchDevices(2);
			 case {'test2touch'}
				tM.Fron = testTouchManager; tM.Fron.devices = touchDevices(1);
	        	tM.Back = testTouchManager; tM.Back.devices = touchDevices(2);
				rM.Fron=[];   rM.Back=[];
		 end
		 if d(1)==1&&length(port)>=2
			 rM.Fron = arduinoManager('ports',port(2));rM.Fron.openGUI = false;rM.Fron.open;rM.Fron.shield = 'old';
			 if d(3)==1&&length(port)>=3
				 rM.Back = arduinoManager('port',port(3));rM.Back.openGUI = false;rM.Back.open;rM.Back.shield = 'new';
			 elseif d(3)==0
				 rM.Back=[];
			 end
		 elseif d(1)==0
			 rM=[];
		 end
		 if d(2)==1&&length(touchDevices)>=1
			 tM.Fron = testTouchManager; tM.Fron.devices = touchDevices(1);
			 if d(4)==1&&length(touchDevices)>=2
				 tM.Back = testTouchManager; tM.Back.devices = touchDevices(2);
			 elseif d(4)==0
				 tM.Back=[];
			 end
		 end
		 
		 
end

function touched = checkBox(x, y, box)
	touched = 0;
	checkWin= 100;
	if x>box(1)-checkWin && x<box(3)+checkWin && y>box(2)-checkWin&&y<box(4)+checkWin
	   touched = 1;
	end
end


