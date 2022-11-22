ana.taskNam='Control';
touched_front=1;
touched_back=0;
while 1
switch  ana.taskNam
					case {'Control','Audience Effect','Altruism','Envy','Competition'}
						if touched_front == 1 || touched_back==1
							break;
						end
					case {Co-action}
						if touched_front == 1 && touched_back==1
							break;
						end
end
end

ana.taskNam = 's';
ss=100