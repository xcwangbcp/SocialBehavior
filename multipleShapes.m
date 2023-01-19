function multipleShapes()

a_front = arduinoManager('port','/dev/ttyACM0');a_front.open;a_front.shield = 'old';
a_back  = arduinoManager('port','/dev/ttyACM1');a_back.open; a_back.shield  = 'new';

%Audio Manager
if ~exist('aM','var') || isempty(aM) || ~isa(aM,'audioManager')
	aM=audioManager;
end
aM.silentMode = false;
if ~aM.isSetup;	aM.setup; end

trialN          = 3;
choiceTouch     = 1;
debug			= false;
timeOut			= 2;
nObjects		= 4;
stimSize		= 18;
circleRadius	= 25;
degsPerStep		= 360 / nObjects;
pxPerCm			= 16;
distance		= 25;
centerX			= -20;
centerY			= +20;
colourSelf		= [0.8 0.5 0.3];
colourOther		= [0.3 0.5 0.8];
colourBoth		= [0.8 0.3 0.5];
colourNone		= [0.5 0.5 0.8];

try
	
	s = screenManager('blend',true,'pixelsPerCm', pxPerCm,'distance', distance,...
		'backgroundColour',[0 0 0],'screenXOffset',centerX,'screenYOffset',centerY);
	open(s);

	self = imageStimulus('size',stimSize, 'colour', colourSelf,...
		'fileName',[s.paths.root '/stimuli/star.png']);
	other = imageStimulus('size',stimSize, 'colour', colourOther,...
		'fileName',[s.paths.root '/stimuli/triangle.png']);
	both = imageStimulus('size',stimSize, 'colour', colourBoth,...
		'fileName',[s.paths.root '/stimuli/heptagon.png']);
	none = imageStimulus('size',stimSize, 'colour', colourNone,...
		'fileName',[s.paths.root '/stimuli/circle.png']);
	setup(self, s);
	setup(other, s);
	setup(both, s);
	setup(none, s);

	% initiate the touchpanels
	tM				= touchManager('device',choiceTouch,'isDummy',false);
	setup(tM, s);

	subject= input ("Enter subject name:",'s');
	nameExp=[subject,'-',date,'.mat'];
	
	text='Please press ESCAPE to start experiment...';
	drawTextNow(s,text);
	RestrictKeysForKbCheck(KbName('ESCAPE'));
	KbWait;

	try Priority(1); end

	correctTrials.self = 0;
	correctTrials.other  = 0 ;
	correctTrials.both  = 0 ;
	correctTrials.none = 0;
	reactionTime.init = GetSecs;
	reactionTime.self = zeros(trialN,1);
	reactionTime.other  = zeros(trialN,1);
	reactionTime.both  = zeros(trialN,1); 
	reactionTime.none = zeros(trialN,1); 
	
	createQueue(tM);
	start(tM);
	
	for i=1:trialN
		fprintf('\n===>>> Running Trial %i\n',i);
		rewardSelf		= false;
		rewardOther		= false;
		rewardBoth		= false;
		rewardNone		= false;
		textMonkey		= 'no touch';
		
		randOffset = round(rand * 90);

		names = {'self','other','both','none'};
		for i = 1 : nObjects
			theta = deg2rad((degsPerStep * i) + randOffset);
			[x,y] = pol2cart(theta, circleRadius);
			pos.(names{i}).x = x;
			pos.(names{i}).y = y;
		end
		self.xPositionOut = pos.self.x;
		self.yPositionOut = pos.self.y;
		other.xPositionOut = pos.other.x;
		other.yPositionOut = pos.other.y;
		both.xPositionOut = pos.both.x;
		both.yPositionOut = pos.both.y;
		none.xPositionOut = pos.none.x;
		none.yPositionOut = pos.none.y;
		update(self); update(other); update(both); update(none);

		flush(tM)
		x = []; y = []; txt = ''; textMonkey = '';
		
		% ====================================SHOW STIMULI
		tStart = flip(s); 
		while GetSecs < (tStart + timeOut)
			draw(self);
			draw(other);
			draw(both);
			draw(none);
			if debug; drawText(s, txt); drawScreenCenter(s); drawGrid(s);end
			flip(s);
			cWins = [toDegrees(s,self.mvRect,'rect');toDegrees(s,other.mvRect,'rect');...
				toDegrees(s,both.mvRect,'rect');toDegrees(s,none.mvRect,'rect')];
			[results,x,y]	= checkTouchWindows(tM, cWins);

			if debug; if ~isempty(x);txt = sprintf('x = %.2f Y = %.2f',x(1),y(1)); end; end
			if ~any(results); continue; end

			if results(1) == true
				textMonkey='SELF:front monkey touched,reward to front';		
				rewardSelf    = 1;
				correctTrials.self = correctTrials.self+1;
				reactionTime.self(i,1) = GetSecs-tStart;
				disp(textMonkey);
				break;
			elseif results(2) == true
				textMonkey='OTHER:front monkey touched, but reward to back one';
				rewardOther     = 1;
				correctTrials.other = correctTrials.other+1;
				reactionTime.other(i,1) = GetSecs-tStart;
				disp(textMonkey);
				break;
			elseif results(3) == true
				textMonkey='BOTH:front monkey touched,both sides get reward';
				rewardBoth  = 1;
				correctTrials.both = correctTrials.both+1;
				reactionTime.both(i,1) = GetSecs-tStart;
				disp(textMonkey);
				break;
			elseif results(4) == true
				textMonkey='NONE:front monkey touched,none get reward';
				rewardNone  = 1;
				correctTrials.none = correctTrials.none+1;
				reactionTime.none(i,1) = GetSecs-tStart;
				disp(textMonkey);
				break;
			end
		end
		tEnd = flip(s);
		
		% =============================REWARDS
		if debug; drawTextNow(s,textMonkey); end
		if rewardSelf
			a_front.stepper(46);
			aM.beep(2000,0.1,0.1);
		elseif rewardOther
			a_back.stepper(46)
			aM.beep(2000,0.1,0.1);
		elseif rewardBoth
			a_back.stepper(46)
			a_front.stepper(46);
			aM.beep(2000,0.1,0.1);
		elseif rewardNone
			aM.beep(2000,0.1,0.1);
		end
		WaitSecs(3);
	end
	

	reactionTime.end = GetSecs;
	reactionTime.total = reactionTime.end - reactionTime.init;

	a_front.close;a_back.close;
	results = struct();
	results.correctTrials = correctTrials;
	results.reactionTime = reactionTime;
	results.subject = subject;
	results.trialN = trialN;
	results.TotalTime = reactionTime.total;
	cd(s.paths.savedData);
	save(nameExp, 'results');
    close(s);
	close(tM);
	reset(self); reset(other); reset(both); reset(none);
	sca;
	KbReleaseWait;
catch ME
	try close(s); end %#ok<*TRYNC> 
	try close(tM); end
	reset(self); reset(other); reset(both); reset(none);
	sca;
	getReport(ME);
	rethrow(ME);
end

end % END FUNCTION