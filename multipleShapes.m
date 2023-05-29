
function multipleShapes()


a_front = arduinoManager('port','/dev/ttyACM1'); a_front.open;
a_back  = arduinoManager('port','/dev/ttyACM0'); a_back.open;

%Audio Manager
if ~exist('aM','var') || isempty(aM) || ~isa(aM,'audioManager')
	aM=audioManager;
end
aM.silentMode = false;
if ~aM.isSetup;	aM.setup; end

stims			= { 'none', 'both', 'self', 'other'};
trialN          = 20;
choiceTouch     = 1;
debug			= false;
dummy			= false;
timeOut			= 3;
nObjects		= length(stims);
stimSize		= 9;
circleRadius	= 11;
degsPerStep		= 360 / nObjects;
pxPerCm			= 16;
distance		= 20;
centerY			= +40;
centerX			= -35;
colourSelf		= [0.8 0.5 0.3];
colourOther		= [0.3 0.5 0.8];
colourBoth		= [0.8 0.3 0.5];
colourNone		= [0.8 0.5 0.8];
randomise		= true;

try
	%==============================================CREATE SCREEN
	s = screenManager('blend', true,'antiAlias', 8,'backgroundColour', [0 0 0],...
		'pixelsPerCm', pxPerCm,'distance', distance,...
		'screenXOffset', centerX,'screenYOffset', centerY);
	open(s);
	fixationRemapper(s);
	%==============================================CREATE STIMULI
	self = imageStimulus('size', stimSize, 'colour', colourSelf,...
		'fileName',[s.paths.root '/stimuli/star.png']);
	other = imageStimulus('size', stimSize, 'colour', colourOther,...
		'fileName',[s.paths.root '/stimuli/triangle.png']);
	both = imageStimulus('size', stimSize, 'colour', colourBoth,...
		'fileName',[s.paths.root '/stimuli/heptagon.png']);
	none = imageStimulus('size', stimSize, 'colour', colourNone,...
		'fileName',[s.paths.root '/stimuli/circle.png']);
	setup(self, s);
	setup(other, s);
	setup(both, s);
	setup(none, s);

	%==============================================INITIATE THE TOUCHPANELS
	tM = touchManager('device',choiceTouch);
	setup(tM, s);
    for i=1:length(choiceTouch)
    	tM(i) = touchManager('device',choiceTouch(i),'isDummy',dummy);
    	setup(tM(i), s);
        createQueue(tM(i),choiceTouch(i));
    	start(tM(i),choiceTouch(i));
	end

	%==============================================GET SUBJECT NAME
	subject= input ("Enter subject name:",'s');
	nameExp=[subject,'-',date,'.mat'];
	
	%==============================================
	text='Please press ESCAPE to start experiment...';
	drawTextNow(s,text);
	RestrictKeysForKbCheck(KbName('ESCAPE'));
	KbWait;

	correctTrials.self	= 0;
	correctTrials.other	= 0;
	correctTrials.both	= 0;
	correctTrials.none	= 0;
	reactionTime.init	= GetSecs;
	reactionTime.self	= zeros(trialN, 1);
	reactionTime.other	= zeros(trialN, 1);
	reactionTime.both	= zeros(trialN, 1); 
	reactionTime.none	= zeros(trialN, 1); 
	
	%==============================================START TOUCH QUEUE
	try Priority(1); end

	
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
			self.colourOut		= [lim(rand) lim(rand) lim(rand)];
			other.colourOut		= [lim(rand) lim(rand) lim(rand)];
			both.colourOut		= [lim(rand) lim(rand) lim(rand)];
			none.colourOut		= [lim(rand) lim(rand) lim(rand)];
			self.angleOut		= rand * 360;
			other.angleOut		= rand * 360;
			both.angleOut		= rand * 360;
			none.angleOut		= rand * 360;
		end
		% ----- update stimuli with new values
		update(self); update(other); update(both); update(none);
 
		% ====================================SHOW STIMULI
		textMonkey = 'no touch'; %%
		selfReward = false; otherReward = false; bothReward = false; noneReward = false;
		x = []; y = []; txt = ''; textMonkey = ''; anyTouch = false; cWins = [];

        for j=1:length(choiceTouch)
    		flush(tM(j),choiceTouch(j));
        end

		vbl = flip(s); tStart = vbl;
		while vbl <= (tStart + timeOut) && anyTouch == false
			for jObj = 1 : nObjects
				% we use eval as our object names are stored in an array
				eval(['draw(' stims{jObj} ');']);
				eval(['cWins(jObj,:) = toDegrees(s, ' stims{jObj} '.mvRect, ''rect'');']);
		%	eval(['cWins(j,:) = toDegrees(s, ' stims{jObj} '.mvRect, ''rect'');']);
			end
			if debug; drawScreenCenter(s); drawGrid(s); drawText(s, txt); end %#ok<*UNRCH> 
			vbl = flip(s);
            
			[results, x, y] = checkTouchWindows(tM, cWins,choiceTouch);

			if debug && ~isempty(x); txt = sprintf('x = %.2f Y = %.2f',x(1),y(1)); end
			
			if ~any(results); continue; end

			for jObj = 1: nObjects
				if results(jObj) == true
					textMonkey = ['Touched: ' upper(stims{jObj})];
					eval([stims{jObj} 'Reward = true;'])
					correctTrials.(stims{jObj}) = correctTrials.(stims{jObj})+1;
					reactionTime.(stims{jObj})(iTrial,1) = GetSecs-tStart;
					disp(textMonkey);
					anyTouch = true;
					break
				end
			end
		end % END WHILE
		flip(s);
		
		% =============================REWARDS
		if debug; drawTextNow(s,textMonkey); end
		if selfReward
			aM.beep(2000,0.1,0.1);
			a_front.stepper(46);
		elseif otherReward
			aM.beep(2000,0.1,0.1);
			a_back.stepper(46);
					WaitSecs(2);
		elseif bothReward
			aM.beep(2000,0.1,0.1);
			a_back.stepper(46);
%			WaitSecs(1);50
			a_front.stepper(46);
		elseif noneReward
			aM.beep(2000,0.1,0.1);
	 			WaitSecs(2);

		end
		WaitSecs(3);

	end

	reactionTime.end = GetSecs;
	reactionTime.total = reactionTime.end - reactionTime.init;

	a_front.close;a_back.close;

	% =====================================SAVE DATA
	results = struct();
	results.stims = stims;
	results.correctTrials = correctTrials;
	results.reactionTime = reactionTime;
	results.subject = subject;
	results.trialN = trialN;
	results.TotalTime = reactionTime.total;
	cd(s.paths.savedData);
	save(nameExp, 'results');

	% ====================================CLEAN UP
    close(s);
	close(tM,choiceTouch);
	reset(self); reset(other); reset(both); reset(none);
	Priority(0); ShowCursor; sca;

catch E

	try close(s); end %#ok<*TRYNC> 
	try close(tM,choiceTouch); end
	reset(self); reset(other); reset(both); reset(none);
	Priority(0); ShowCursor; sca;
	rethrow(E);

end

function out = lim(in)
	l = 0.4; h = 0.8;
	out = (in * (h - l))+l;
end

end % END FUNCTION`