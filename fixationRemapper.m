function fixationRemapper(s)

	if ~exist('s','var'); s = screenManager; end

	f = fixationCrossStimulus('type','pulse','size',2);

	if ~s.isOpen; open(s); didOpen = true; end
	setup(f, s);
	f.isVisible = false;

	KbName('UnifyKeyNames');
	up = KbName('UpArrow'); down = KbName('DownArrow');
	right = KbName('RightArrow'); left = KbName('LeftArrow'); 
	zero = KbName('0)'); esc = KbName('escape'); 
	menu = KbName('LeftShift'); sample = KbName('RightShift'); shot = KbName('F1');
	oldr = RestrictKeysForKbCheck([up down left right ...
		zero esc menu sample shot]);

	loop = true;
	x = f.xPosition;
	y = f.yPosition;

	while loop
		s.drawText('MENU: esc = exit | Arrow Keys = move | RShift = toggle');
		drawGrid(s);
		draw(f);
		finishDrawing(s);
		animate(f);
		flip(s);

		[pressed,name,keys] = optickaCore.getKeys();
		if pressed
			
			if keys(sample)
				f.isVisible = ~f.isVisible;
				fprintf('Toggle Visibility @ %.2f %.2f\n',x,y);
			elseif keys(esc)
				loop = false;
			elseif keys(up)
				hide(f);
				y = y - 0.5;
				fprintf('Y Position: %.2g\n',y);
				f.yPositionOut = y;
				update(f);
			elseif keys(down)
				hide(f);
				y = y + 0.5;
				fprintf('Y Position: %.2g\n',y);
				f.yPositionOut = y;
				update(f);
			elseif keys(left)
				hide(f);
				x = x - 0.5;
				fprintf('X Position: %.2g\n',x);
				f.xPositionOut = x;
				update(f);
			elseif keys(right)
				hide(f);
				x = x + 0.5;
				fprintf('X Position: %.2g\n',x);
				f.xPositionOut = x;
				update(f);
			end
		end
	end

	RestrictKeysForKbCheck(oldr);
	reset(f);
	if exist('didOpen','var'); s.close; end
	sca

end