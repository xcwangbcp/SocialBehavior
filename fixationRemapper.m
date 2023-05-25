function fixationRemapper(s)

	if ~exist('s','var'); s = screenManager; end

	f = fixationCrossStimulus('type','pulse','size',2);

	if ~s.isOpen; open(s); didOpen = true; end
	setup(f, s);
	f.isVisible = false;

	KbName('UnifyKeyNames');
	up = KbName('UpArrow'); down = KbName('DownArrow');
	right = KbName('RightArrow'); left = KbName('LeftArrow'); 
	mag = KbName('/?');
	zero = KbName('0)'); esc = KbName('escape'); 
	menu = KbName('LeftShift'); sample = KbName('RightShift'); shot = KbName('F1');
	oldr = RestrictKeysForKbCheck([up down left right mag...
		zero esc menu sample shot]);
	ListenChar(-1);
	loop = true;
	x = f.xPosition;
	y = f.yPosition;
	step = 1;

	while loop
		s.drawText(sprintf('MENU %.2gx %.2gy: esc = exit | Arrow Keys = move | / = change step | RShift = toggle',x,y));
		%drawGrid(s);
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
			elseif keys(mag)
				if step == 10
					step = 1;
				elseif step == 1
					step = 0.5;
				else
					step = 10;
				end
				fprintf('Step size: %.2g degs\n',step);
			elseif keys(up)
				hide(f);
				y = y - step;
				fprintf('Y Position: %.2g\n',y);
				f.yPositionOut = y;
				update(f);
			elseif keys(down)
				hide(f);
				y = y + step;
				fprintf('Y Position: %.2g\n',y);
				f.yPositionOut = y;
				update(f);
			elseif keys(left)
				hide(f);
				x = x - step;
				fprintf('X Position: %.2g\n',x);
				f.xPositionOut = x;
				update(f);
			elseif keys(right)
				hide(f);
				x = x + step;
				fprintf('X Position: %.2g\n',x);
				f.xPositionOut = x;
				update(f);
			end
		end
	end

	RestrictKeysForKbCheck(oldr); ListenChar(0);
	reset(f);
	if exist('didOpen','var'); s.close; end

end