

function twoTouchPanels()

% a_front = arduinoManager('port','/dev/ttyACM1'); a_front.open;
% a_back  = arduinoManager('port','/dev/ttyACM0'); a_back.open;

%Audio Manager
if ~exist('aM','var') || isempty(aM) || ~isa(aM,'audioManager')
	aM=audioManager;
end
aM.silentMode = false;
if ~aM.isSetup;	aM.setup; end

stims			= {'stimFron', 'stimBack'};%, 'other', 'both'};
trialN          = 5 ;
choiceTouch     = [1 2];

debug			= false;
dummy			= false;
timeOut			= 5;
nObjects		= length(stims);
stimSize		= 20;
circleRadius	= 12;
degsPerStep		= 360 / nObjects;
pxPerCm			= 16;
distance		= 20;
centerY			= 0;
centerX			= -100;
colourFron		= [0.8 0.5 0.3];
colourBack		= [0.3 0.5 0.8];
% colourBoth		= [0.8 0.3 0.5];
% colourNone		= [0.8 0.5 0.8];
randomise		= true;
taskType        = 'com';
try
	%==============================================CREATE SCREEN
	s = screenManager('blend', true,'antiAlias', 8,'backgroundColour', [0 0 0],...
		'pixelsPerCm', pxPerCm,'distance', distance,...
		'screenXOffset', centerX,'screenYOffset', centerY);
	open(s);
	%==============================================CREATE STIMULI
	stimFron = imageStimulus('size', stimSize, 'colour', colourFron,...
		'fileName',[s.paths.root '/stimuli/star.png']);
	stimBack = imageStimulus('size', stimSize, 'colour', colourBack,...
		'fileName',[s.paths.root '/stimuli/triangle.png']);
% 	both = imageStimulus('size', stimSize, 'colour', colourBoth,...
% 		'fileName',[s.paths.root '/stimuli/heptagon.png']);
% 	none = imageStimulus('size', stimSize, 'colour', colourNone,...
% 		'fileName',[s.paths.root '/stimuli/circle.png']);
	setup(stimFron, s);
	setup(stimBack, s);
% 	setup(both, s);
% 	setup(none, s);

	%==============================================INITIATE THE TOUCHPANELS
	tMFron = touchManager('device',choiceTouch(1),'isDummy',dummy);
	tMBack = touchManager('device',choiceTouch(2),'isDummy',dummy);
	setup(tMFron, s);
    setup(tMBack, s);
	%==============================================GET SUBJECT NAME
	subject= input ("Enter subject name:",'s');
	nameExp=[subject,'-',date,'.mat'];
	
	%==============================================
	text='Please press ESCAPE to start experiment...';
	drawTextNow(s,text);    
	RestrictKeysForKbCheck(KbName('ESCAPE'));
	KbWait;  


	correctTrials.Fron	= 0;
% 	correctTrialsFron.other	= 0;
% 	correctTrialsFron.both	= 0;
% 	correctTrialsFron.none	= 0;

    correctTrials.Back	= 0;
% 	correctTrialsBack.other	= 0;
% 	correctTrialsBack.both	= 0;
% 	correctTrialsBack.none	= 0;

	reactionTimeFron.init	= GetSecs;
	reactionTimeFron.self	= zeros(trialN, 1);
	reactionTimeFron.other	= zeros(trialN, 1);
	reactionTimeFron.both	= zeros(trialN, 1); 
	reactionTimeFron.none	= zeros(trialN, 1); 


	reactionTimeBack.init	= GetSecs;
	reactionTimeBack.self	= zeros(trialN, 1);
	reactionTimeBack.other	= zeros(trialN, 1);
	reactionTimeBack.both	= zeros(trialN, 1); 
	reactionTimeBack.none	= zeros(trialN, 1); 
	
	%==============================================START TOUCH QUEUE
	try Priority(1); end
	createQueue(tMFron,choiceTouch(1));
	createQueue(tMBack,choiceTouch(2));
	
	start(tMFron,choiceTouch(1));
	text='Please touch the screen...';
	drawTextNow(s,text);
	start(tMBack,choiceTouch(2));


	%==============================================MAIN TRIAL LOOP
	for iTrial=1:trialN
		fprintf('\n===>>> Running Trial %i\n',iTrial);

		% ----- set the positions for this trial
		randOffset = round(rand * 360);
		for jObj = 1 : nObjects
			theta = deg2rad((degsPerStep * jObj) + randOffset);
			[x,y] = pol2cart(theta, circleRadius);
			eval([stims{jObj} '.xPositionOut = ' num2str(x) ';']);
			eval([stims{jObj} '.yPositionOut = ' num2str(y) ';']);
		end
		% ----- randomise
		if randomise
			stimFron.colourOut		= [lim(rand) lim(rand) lim(rand)];
			stimBack.colourOut		= [lim(rand) lim(rand) lim(rand)];
% 			both.colourOut		= [lim(rand) lim(rand) lim(rand)];
% 			none.colourOut		= [lim(rand) lim(rand) lim(rand)];
			stimFron.angleOut		= rand * 360;
			stimBack.angleOut		= rand * 360;
% 			both.angleOut		= rand * 360;
% 			none.angleOut		= rand * 360;
		end
		% ----- update stimuli with new values
		update(stimFron); update(stimBack); %update(both); update(none);
 
		% ====================================SHOW STIMULI
		
		rewardFron = false; rewardBack = false; %bothReward = false; noneReward = false;
		touchFron = false; touchBack=false;cWins = [];
		x = []; y = []; txt = ''; textMonkey = ''; 
		flush(tMFron,choiceTouch(1));
		flush(tMBack,choiceTouch(2));

		vbl = flip(s); tStart = vbl;
		while vbl <= (tStart + timeOut) && touchFron == false && touchBack==false
			for jObj = 1 : nObjects
				% we use eval as our object names are stored in an array
				eval(['draw(' stims{jObj} ');']);
				eval(['cWins(jObj,:) = toDegrees(s, ' stims{jObj} '.mvRect, ''rect'');']);
			end
			if debug; drawScreenCenter(s); drawGrid(s); drawText(s, txt); end %#ok<*UNRCH> 
			vbl = flip(s);

			[resultsFron, xFron, yFron] = checkTouchWindows(tMFron, cWins,choiceTouch(1));
			[resultsBack, xBack, yBack] = checkTouchWindows(tMBack, cWins,choiceTouch(2));
			if ~any([resultsFron resultsBack]); continue; end

			switch taskType
				case {'competition','com'}
					if any(resultsFron)
						disp('front monkey win');
						touchFron=true;
					elseif any(resultsBack)
						disp('back monkey win');
						touchBack=true;
					end
					if any(resultsFron)||any(resultsBack)
						flip(s);
						break;
					end
				case{'cooperation','coo'}
					if any(resultsFron)
						disp('front monkey touch first');
						draw(stimBack);
						flip(s)
						resultsBack = checkTouchWindows(tMBack, cWins,choiceTouch(2));
						if ~any(resultsBack); continue; end
						if any(resultsBack)
							flip(s)
							break
						end
					elseif any(resultsBack)
						disp('back monkey touch first')
						draw(stimFron);
						flip(s)
						resultsFron = checkTouchWindows(tMFron, cWins,choiceTouch(1));
						if ~any(resultsFron); continue; end
						if any(resultsFron)
							flip(s)
							break
						end
					end
			end
			if debug && ~isempty(xFron); txt = sprintf('x = %.2f Y = %.2f',xFron(1),yFron(1)); end
		end % END WHILE
		
		
		
		% =============================REWARDS
		if debug; drawTextNow(s,textMonkey); end

		if touchFron
			aM.beep(2000,0.1,0.1);
% 			a_front.stepper(46);
		elseif touchBack
			aM.beep(2000,0.1,0.1);
% 			a_back.stepper(46);
% 			WaitSecs(2)
		end

		WaitSecs(1);

	end

	reactionTimeFron.end   = GetSecs;
	reactionTimeFron.total = reactionTimeFron.end - reactionTimeFron.init;

	a_front.close;a_back.close;

	% =====================================SAVE DATA
	results = struct();
	results.stims = stims;
	results.correctTrials = correctTrialsFron;
	results.reactionTime = reactionTimeFron;
	results.subject = subject;
	results.trialN = trialN;
	results.TotalTime = reactionTimeFron.total;
	cd(s.paths.savedData);
	save(nameExp, 'results');

	% ====================================CLEAN UP
    close(s);
	close(tMFron,choiceTouch);
	close(tMBack,choiceTouch)
	reset(stimFron); reset(stimBack); reset(both); reset(none);
	Priority(0); ShowCursor; sca;

catch E

	try close(s); end %#ok<*TRYNC> 
	try close(tM,choiceTouch); end
% 	reset(stimFron); reset(stimBack); reset(both); reset(none);
	Priority(0); ShowCursor; sca;
	rethrow(E);

end

function out = lim(in)
	l = 0.4; h = 0.8;
	out = (in * (h - l))+l;
end

end % END FUNCTION`
 % END FUNCTION