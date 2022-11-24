clear;close;sca;

rM=arduinoManager('ports','/dev/ttyACM0');
rM.openGUI=false;
rM.open;
rM.shield='old'; % old or new, because the old one was sold out!

try
	%General setting
	sM = screenManager('backgroundColour', [0 0 0],'blend',true);
	sv = sM.open;
	myDisc = discStimulus('colour',[0 1 0],'size',2, 'sigma', 1);

	ms = metaStimulus;
	ms{1} = myDisc;
	%ms{2} = fCross;
	setup(ms,sM);

	% Subject's name input
	drawTextNow(sM,'Please enter your subject name...')
	subject= input ("Enter subject name:",'s');
	nameExp=[subject,'-',date,'.mat'];

	tfrontM=touchManager; % touch for front panel
	tfrontM.setup;

	KbReleaseWait;
	KbQueueRelease;
	%drawTextNow(sM,'Please touch the screen to release the queue...')

	% other setup
	drawTextNow(sM,'Please press ESCAPE to start experiment...')
	RestrictKeysForKbCheck(KbName('ESCAPE'));
	KbWait;
	tfrontM.Qcreate(sv.win);
	trialN			= 10;
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
		% 		front  = tEvent;

		%Audio Manager
		if ~exist('aM','var') || isempty(aM) || ~isa(aM,'audioManager')
			aM=audioManager;
		end
		aM.silentMode = false;
		if ~aM.isSetup;	aM.setup; end

		tfrontM.flush;
		tfrontM.start
		tStart = GetSecs;
		while GetSecs < (tStart + timeOut)
			draw(ms);
			vbl = flip(sM);
			temp  = tfrontM.eventAvail;
			while temp
				evt_front			= tfrontM.getEvent(sv.win);

				if  ~isempty(evt_front)
					front.X         = evt_front.MappedX;
					front.Y         = evt_front.MappedY;
					front.Pressed   = evt_front.Pressed;
				end
				front.InBox = checkBox(front.X, front.Y, mybox);
				fprintf('...front x=%.2f y=%.2f\n',front.X,front.Y)

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
				tfrontM.stop;
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

		WaitSecs(2);
	end

	%% Saving experiment information and results in a file called Socialtask_SubjectX.mat (X is subject number)
	results.subject = subject;
	results.trialN = trialN;
	results.corretTrials = corretTrials;
	results.reactiontime = reactiontime;
	%fout=sprintf('Socialtask_Subject%d.mat', subject);
	save(nameExp, 'results');

	%%========================================
	%  rM.stop;
	tfrontM.stop;
	sM.close;ms.reset;sca;
catch ME
	sM.close;sca;
	rethrow(ME)
end


function touched = checkBox(x, y, box)
touched = 0;
checkWin= 10;
if x>box(1)-checkWin && x<box(3)+checkWin && y>box(2)-checkWin&&y<box(4)+checkWin
	touched = 1;
end
end