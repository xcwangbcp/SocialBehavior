clear;close;sca;
a=arduinoManager();a.openGUI=false;a.open;
monkeytouched=1;
a.pinMode(2,'Input')

if monkeytouched
	for i=1:20
		driveMotor(a)
		pause(1)
	end
end



function driveMotor(a)
 delaylength = 0.02;
 nbstep      = 8;
 for       i = 1:nbstep
	 i
%   check_sensor(a);
%   sensor    = a.digitalRead(2)
%   if sensor ==0
%      break
%   end
  a.digitalWrite(9, 0);    %//ENABLE CH A 
  a.digitalWrite(8, 1);    %//DISABLE CH B
  a.digitalWrite(12,1);   %//Sets direction of CH A
  a.digitalWrite(3, 1);    %//Moves CH A
  pause(delaylength);
  
%   check_sensor(a);
%  sensor    = a.digitalRead(2)
%    if sensor ==0
%      break
%   end
  a.digitalWrite(9, 1);    %//DISABLE CH A
  a.digitalWrite(8, 0);    %//ENABLE CH B
  a.digitalWrite(13,0);   %//Sets direction of CH B
  a.digitalWrite(11,1);   %//Moves CH B
  pause(delaylength);
  
%   check_sensor(a);
%  sensor    = a.digitalRead(2)
%    if sensor ==0
%      break
%   end
  a.digitalWrite(9, 0);     %//ENABLE CH A-
  a.digitalWrite(8, 1);     %//DISABLE CH B
  a.digitalWrite(12,0);    %//Sets direction of CH A
  a.digitalWrite(3, 1);     %//Moves CH A
  pause(delaylength);
  
%   check_sensor(a);
 
  a.digitalWrite(9, 1);   %//DISABLE CH A
  a.digitalWrite(8, 0);   %//ENABLE CH B-
  a.digitalWrite(13,1);  %//Sets direction of CH B
  a.digitalWrite(11,1);  %//Moves CH B
  pause(delaylength);
%   pause(0.5)
%   sensor    = a.digitalRead(2)
%    if sensor ==0
%      break
%   end
   
 end
  stop_motor(a);
end
%   clear(a);
function stop_motor(a)
    delaylength    = 0.01;    % in seconds
    a.digitalWrite(9,1);        %//DISABLE CH A
    a.digitalWrite(3, 0);       %//stop Move CH A
    a.digitalWrite(8,1);        %//DISABLE CH B
    a.digitalWrite(11,0);      %//stop Move CH B 
    pause(delaylength);
end

% function check_sensor(a)
%   sensor    = a.digitalRead(2)
%   if sensor ==0
%      stop_motor(a);
%   end
% end