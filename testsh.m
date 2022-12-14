clear;close;sca;

rM=arduinoManager('ports','/dev/ttyACM0');
rM.openGUI=false;
rM.open;
rM.shield='old';% old or new, because the old one was sold out

try
	sM = screenManager('backgroundColour', [0 0 0],'blend',true);
	sv = sM.open;	
	%fCross = fixationCrossStimulus();
	myDisc = discStimulus('colour',[0 1 0],'size',2, 'sigma', 1); 

	ms = metaStimulus;
	ms{1} = myDisc;
	%ms{2} = fCross;
	setup(ms,sM);

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
drawTextNow(sM,'Please enter your subject name...')
subject= input ("Enter subject name:",'s')
nameExp=[subject,'-',date,'.mat'];

	%disp('Lets Create the queue')
    tfrontM=touchManager; % touch for front panel
	tfrontM.setup;

	KbReleaseWait;
	KbQueueRelease;
	drawTextNow(sM,'Please touch the screen to release the queue...')

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
% 		reward_back   = 0;
% 		touched_front = 0;
% 		touched_back  = 0;

		myDisc.xPositionOut = randi([-3 3]);
		myDisc.yPositionOut = randi([-1 4]);
		myDisc.update;

		mybox     = myDisc.mvRect;
		%myboxback = mybox;
		fprintf('--->>> Stim Box: %i %i %i %i\n',mybox);
		tEvent = struct('X', -inf,'Y', -inf,'Pressed', 0,'InBox', 0);
% 		front  = tEvent; %back = tEvent;%
% touched_front
        tfrontM.flush;
		tfrontM.start
		tStart = GetSecs;
		while GetSecs < (tStart + timeOut)
			draw(ms);
			%animate(ms);
			vbl = flip(sM);

% 			front = tEvent; %back = tEvent;
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
% 					draw(ms);
					reward_front = 1;
					corretTrials = corretTrials+1;
% 					disp('good monkey front');
					break;
% 
				end


% 				if back.Pressed && back.InBox
% 					draw(ms);
% 					reward_back    = 1;
% 					disp('good monkey back');
% 					break;
% 				end
			end

			if reward_front	%|| reward_back
				rM.stepper(46); % in degree
				disp('good monkey front');
				if ~exist('aM','var') || isempty(aM) || ~isa(aM,'audioManager')
				aM=audioManager;
			    end
			    aM.silentMode = false;
			   if ~aM.isSetup;	aM.setup; end
			    aM.beep(2000,0.1,0.1);
				tfrontM.stop;
				break
			
			
			end
		end
		if reward_front==0
		   sM.drawBackground;
		   sM.flip
		   WaitSecs(3);
		else
			fprintf('\n===>>> Trial %i took %.4f seconds\n',i, GetSecs-tStart);
			reactiontime(i,1) = GetSecs-tStart;
			sM.drawBackground;
			if reward_front
				drawTextNow(sM,'FRONT CORRECT!')
			end
		end
%%===   Audio ===

% 			else 
% 				if ~aM.isSetup;	aM.setup; end
% 				aM.beep(200,0.5,1);
% 				WaitSecs (3);
% 				break;
% 				----------------------
%if the subject is correct (small reward)
% correctEntry = { 
% 	@()beep(aM,2000); % correct beep
% 	%incorrect entry
% incEntry = { 
% 	@()beep(aM,200,0.5,1);
% 
% %break entry
% breakEntry = {
% 	@()beep(aM, 400, 0.5, 1);
% 
% 	exclEntry = {
% 	@()beep(aM, 400, 0.5, 1);
%%===
		
% 		if reward_back
% 			drawTextNow(s,'BACK CORRECT!')
% 		end
		WaitSecs(2);
	end
	%%========================================
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
	checkWin= 20;
	if x>box(1)-checkWin && x<box(3)+checkWin && y>box(2)-checkWin&&y<box(4)+checkWin
	   touched = 1;
	end
end


