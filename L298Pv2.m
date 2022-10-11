clear;close;sca;
a=arduinoManager();
a.open;
% a.pinMode(8,'output');
% a.pinMode(9,'output');
% a.pinMode(12,'output');
% a.pinMode(13,'output');
% a.pinMode(3,'output');
% a.pinMode(11,'output');
% a.pinMode(5,'input');
% t=100;
% while t>0
% 	a.digitalWrite(13,1);
% 	pause(0.5)
% 	a.digitalWrite(13,0);
% 	pause(0.5)
% end
monkeytouched=1;

if monkeytouched
    driveMotor(a)
end



function driveMotor(a)
 delaylength = 0.3;
 nbstep        = 8;
 for       i      = 1:nbstep
%   check_sensor(a);
  a.digitalWrite(9, 0);    %//ENABLE CH A 
  a.digitalWrite(8, 1);    %//DISABLE CH B
  a.digitalWrite(12,1);   %//Sets direction of CH A
  a.digitalWrite(10, 1);    %//Moves CH A
  pause(delaylength);
  
%   check_sensor(a);
  a.digitalWrite(9, 1);    %//DISABLE CH A
  a.digitalWrite(8, 0);    %//ENABLE CH B
  a.digitalWrite(13,0);   %//Sets direction of CH B
  a.digitalWrite(11,1);   %//Moves CH B
  pause(delaylength);
  
%   check_sensor(a);
  a.digitalWrite(9, 0);     %//ENABLE CH A-
  a.digitalWrite(8, 1);     %//DISABLE CH B
  a.digitalWrite(12,0);    %//Sets direction of CH A
  a.digitalWrite(10, 1);     %//Moves CH A
  pause(delaylength);
  
%   check_sensor(a);
  a.digitalWrite(9, 1);   %//DISABLE CH A
  a.digitalWrite(8, 0);   %//ENABLE CH B-
  a.digitalWrite(13,1);  %//Sets direction of CH B
  a.digitalWrite(11,1);  %//Moves CH B
  pause(delaylength);
   i
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

function check_sensor(a)
  sensor    = digitalReas(5);
  if sensor ==0
     stop_motor(a);
  end
end