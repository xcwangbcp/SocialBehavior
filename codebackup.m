clear;close;sca;

rM=arduinoManager('ports','/dev/ttyACM0');
rM.openGUI=false;
rM.open;
rM.shield ='old'; % old or new!
touchSide = questdlg('which side touch pannel are you using?', ...
	'Choose Touchpanel', ...
	'Front', 'Back','Back');
if strcmpi(touchSide,'Back')
	whichDevice = 1; % to choose the back side
else
	whichDevice = 2; % to choose the front side
end
if ~exist('aM','var') || isempty(aM) || ~isa(aM,'audioManager')
	aM=audioManager;
end
aM.silentMode = false;
if ~aM.isSetup;	aM.setup; end
try
	%General setting
	tic
	sM = screenManager('backgroundColour', [0 0 0],'blend',true);
	sv = sM.open;
	myDisc = discStimulus('colour',[0 1 0],'size',2, 'sigma', 1);

	ms = metaStimulus;
	ms{1} = myDisc;
	%ms{2} = fCross;
	setup(ms,sM);

	% Subject's name input
	drawTextNow(sM,'Please enter your subject name...')
	% 	subject= input ("Enter subject name:",'s');
	subject='tset';
	nameExp=[subject,'-',date,'.mat'];

% 	whichDevice = 1;
	tFront=touchManager('device',whichDevice,'name','Front Screen'); % touch for front panel
	setup(tFront, sM);

	KbReleaseWait;
	KbQueueRelease;
	%drawTextNow(sM,'Please touch the screen to release the queue...')

	% other setup
	drawTextNow(sM,'Please press ESCAPE to start experiment...')
	RestrictKeysForKbCheck(KbName('ESCAPE'));
	KbWait;
	createQueue(tFront,whichDevice);
	checkWin		= 50;
	trialN			= 5;
	timeOut			= 5;
	corretTrials    = 0;
	reactiontime    = zeros(trialN,1);
	for i=1:trialN
		fprintf('\n===>>> Running Trial %i\n',i);
		reward_front  = 0;
		myDisc.xPositionOut = randi([-1 1]);
		myDisc.yPositionOut = randi([-1 1]);
		myDisc.update;
		mybox     = myDisc.mvRect;
        
		fprintf('--->>> Stim Box: %i %i %i %i\n',mybox);
		tEvent = struct('X', -inf,'Y', -inf,'Pressed', 0,'InBox', 0);
		% 		front  = tEvent;rM

		%Audio Manager

		if strcmpi(touchSide,'Back')
			mybox = [1920-mybox(1) mybox(2) 1920-mybox(3) mybox(4)];
		end
		flush(tFront,whichDevice);
		start(tFront,whichDevice);
		tStart = GetSecs;
		while GetSecs < (tStart + timeOut)
			draw(ms);
			vbl = flip(sM);
			temp  = eventAvail(tFront,whichDevice);
			while temp
				evt_front			= getEvent(tFront,whichDevice);
				if iscell(evt_front); evt_front = evt_front{1}; end
				if  ~isempty(evt_front)
					front.X         = evt_front.MappedX;
					front.Y         = evt_front.MappedY;
					front.Pressed   = evt_front.Pressed;
				end
				front.InBox = checkBox(front.X, front.Y, mybox,checkWin);
% 				fprintf('...front x=%.2f y=%.2f\n',front.X,front.Y)

				if front.Pressed && front.InBox
				    
					reward_front = 1;
					corretTrials = corretTrials+1;
					% disp('good monkey front');
					sM.drawBackground;
					sM.flip
					break
				end
			end
			if reward_front
				disp('good monkey front'); 
				aM.beep(2000,0.1,0.1);
				rM.stepper(46); 
% 				stop(tFront,whichDevice);
				break
			end
		end

		if reward_front==0
			sM.drawBackground;
			sM.flip
			aM.beep(1000,0.1,0.1);
			WaitSecs(2);
		else
			fprintf('\n===>>> Trial %i took %.4f seconds\n',i, GetSecs-tStart);
			reactiontime(i,1) = GetSecs-tStart;
			if reward_front
				drawTextNow(sM,'FRONT CORRECT!')
			end
		end

		WaitSecs(5);
	end
toc
	%% Saving experiment information and results in a file called Socialtask_SubjectX.mat (X is subject number)
	results.subject = subject;
	results.trialN = trialN;
	results.corretTrials = corretTrials;
	results.reactiontime = reactiontime;
	results.TotalTime = toc/60;

	%fout=sprintf('Socialtask_Subject%d.mat', subject);
	save(nameExp, 'results');

	%%========================================
	%  rM.stop;
	stop(tFront);
	close(sM);reset(ms);sca;
catch ME
	close(sM);
	sca;
	rethrow(ME)
end


function touched = checkBox(x, y, box, checkWin)
	touched = 0;
	if x>box(1)-checkWin && x<box(3)+checkWin && y>box(2)-checkWin&&y<box(4)+checkWin
		touched = 1;
	end
end