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
% ana.expType = {'Control','Audience Effect','Altruis
%  
% m ','Envy','Competition','Co-action','test2touch'};%
ana.taskNam = 'test2touch';
M   = zeros(1,4);
% ana = 'cooperation';
[rM,tM] = inputDeviceManagement(ana.taskNam);




try
	sM = screenManager('backgroundColour', [0 0 0],'blend',true);
	sv = sM.open;	
	fCross = fixationCrossStimulus();
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
	reactiontime         = zeros(trialN,1);
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

					% 					fprintf('...front x=%.2f y=%.2f\n',front.X,front.Y)
				else
					evt_front		= tM.Fron.getEvent(sv.win);
					if  ~isempty(evt_front)
						front.X         = evt_front.MappedX;
						front.Y         = evt_front.MappedY;
						front.Pressed   = evt_front.Pressed;
					end
					front.InBox = checkBox(front.X, front.Y, mybox);
					% 					fprintf('...front x=%.2f y=%.2f\n',front.X,front.Y)
					evt_back              = tM.Back.getEvent(sv.win);
					if  ~isempty(evt_back)
						back.X			= evt_back.MappedX;
						back.Y			= evt_back.MappedY;
						back.Pressed    = evt_back.Pressed;
					end
					back.InBox = checkBox(back.X, back.Y, myboxback);
					% 					fprintf('...back x=%.2f y=%.2f\n',back.X,back.Y)
				end

				%
				if front.Pressed && front.InBox
					touched_front = 1;
					tM.Fron.stop;
					% 					draw(ms);

				end

				if back.Pressed && back.InBox%&&front.Pressed && front.InBox
					touched_back = 1;
					tM.Back.stop;

				end
				switch  ana.taskNam
					case {'Control','Audience Effect','Altruism','Envy','Competition'`}

						if touched_front == 1 || touched_back==1

							break;
						end
					case {'Co-action','test2touch'}
						if touched_front == 1 && touched_back==1
							break;
						end
				end
			end


			if touched_front == 1
				% 				rM.Fron.stepper(46); % in degree
				disp('front monkey get reward');
				corretTrialsFront = corretTrialsFront+1;
				tM.Fron.stop;

				break
			end
			if touched_back == 1%strcmpi(rewardType,'Altruism')||strcmpi(rewardType,'ComB')%|| reward_back
				% 				rM.Back.stepper(46); % in degree
				disp('back monkey get reward');
				corretTrialsFront = corretTrialsFront+1;
				tM.Fron.stop;
				break
			end
			%
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

function [rM,tM]=inputDeviceManagement(taskName)
         touchDevices = GetTouchDeviceIndices([], 1);
		 port         = serialportlist;
		 switch taskName
			case {'Control','Audience Effect'}
		    	rM.Fron = arduinoManager('ports',port(2));rM.Fron.openGUI = false;rM.Fron.open;rM.Fron.shield = 'old';
				tM.Fron = touchManager;    tM.Fron.devices = touchDevices(1);
				rM.Back = [];tM.Back=[];
			case {'Altruism'}
				tM.Fron = touchManager; tM.Fron.devices = touchDevices(1);
		    	rM.Back  = arduinoManager('ports',port(3));rM.Back.openGUI = false;rM.Back.open;rM.Back.shield = 'new';
				rM.Fron=[];tM.Back=[];
			case {'Envy','Competition','Co-action'}
		    	rM.Fron = arduinoManager('port',port(2));rM.Fron.openGUI = false;rM.Fron.open;rM.Fron.shield = 'old';
	        	rM.Back = arduinoManager('port',port(3));rM.Back.openGUI = false;rM.Back.open;rM.Back.shield = 'new';  
            	tM.Fron = touchManager; tM.Fron.devices = touchDevices(1);
	        	tM.Back = touchManager; tM.Back.devices = touchDevices(2);
			 case {'test2touch'}
				tM.Fron = touchManager; tM.Fron.devices = touchDevices(1);
	        	tM.Back = touchManager; tM.Back.devices = touchDevices(2);
				rM.Fron=[];   rM.Back=[];
		  end
end

function touched = checkBox(x, y, box)
	touched = 0;
	checkWin= 100;
	if x>box(1)-checkWin && x<box(3)+checkWin && y>box(2)-checkWin&&y<box(4)+checkWin
	   touched = 1;
	end
end


