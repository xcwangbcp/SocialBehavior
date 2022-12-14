clear;close;sca;
a_front = arduinoManager('port','/dev/ttyACM0');a_front.open;a_front.shield = 'new';
a_front.pinMode(2,'Input');
a_front.digitalRead(2);

a_back = arduinoManager('port','/dev/ttyACM1');a_back.open;a_back.shield = 'old';
a.pinMode(2,'output');
N     = 10;
x     = randperm(N);
monkey_front_touched=0;
monkey_back_touched=0;

for i =1:N
     if x(i)>5
	    monkey_front_touched=1;
	 else
	    monkey_back_touched=1;
	 end

    if monkey_front_touched
       driveMotor(a_front);
	end
	if monkey_back_touched
		driveMotor(a_back );
	end
	monkey_front_touched=0;
	monkey_back_touched=0;
	
end


function driveMotor(a)
 delaylength = 0.2;
 nbstep        = 8;
 switch a.shield
	 case 'new'
     for  i = 1:nbstep
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
	 end
	case 'old'
		for  i = 1:nbstep
%   check_sensor(a);
           a.digitalWrite(9, 0);    %//ENABLE CH A 
           a.digitalWrite(8, 1);    %//DISABLE CH B
           a.digitalWrite(12,1);   %//Sets direction of CH A
           a.digitalWrite(3, 1);    %//Moves CH A
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
		  a.digitalWrite(3, 1);     %//Moves CH A
		  pause(delaylength);
  
%   check_sensor(a);
		  a.digitalWrite(9, 1);   %//DISABLE CH A
		  a.digitalWrite(8, 0);   %//ENABLE CH B-
		  a.digitalWrite(13,1);  %//Sets direction of CH B
		  a.digitalWrite(11,1);  %//Moves CH B
		  pause(delaylength);
		end
 end
  stop_motor(a);
end
%   clear(a);
function stop_motor(a)
    delaylength    = 0.1;    % in seconds
    a.digitalWrite(9,1);        %//DISABLE CH A
    a.digitalWrite(8,1);        %//DISABLE CH B
    a.digitalWrite(11,0);      %//stop Move CH B 

	switch  a.shield
		case 'new'
			 a.digitalWrite(10,0);   
		case 'old'
			a.digitalWrite(3,0);   
	end
    pause(delaylength);
end

function check_sensor(a)
  sensor    = digitalReas(5);
  if sensor ==0
     stop_motor(a);
  end
end