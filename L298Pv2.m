% a.close
clear;close;sca;
a       = arduinoManager('port','/dev/ttyACM2')%,'shield','old');
a.board = 'Pico'
time= 0.05;% seconds

a.open
a.pinMode(4,'o');
a.pinMode(5,'o');

%digital channels for a DC motor
IN1=4;IN2=5;EN=3;

a.digitalWrite(4, 0); % stop the motor
a.digitalWrite(2, 0); % stop the mo
for i=1:1000
	tic
	i
a.analogWrite(3, 1024);  % here must be the analogWrite

a.digitalWrite(4, 1);
a.digitalWrite(2, 0);
WaitSecs(time);
a.digitalWrite(2, 0); % stop the motor
a.digitalWrite(4, 0); % stop the motor
WaitSecs(1);
toc
% a.close 
end
% driveMotor(a);
% 
% function driveMotor(a)
%  delaylength = 0.2;
%  nbstep        = 8;
%  switch a.shield
% 	 case 'new'
%      for  i = 1:nbstep
% %   check_sensor(a);
%            a.digitalWrite(9, 0);    %//ENABLE CH A 
%            a.digitalWrite(8, 1);    %//DISABLE CH B
%            a.digitalWrite(12,1);   %//Sets direction of CH A
%            a.digitalWrite(10, 1);    %//Moves CH A
%            pause(delaylength);
% %   check_sensor(a);
% 		  a.digitalWrite(9, 1);    %//DISABLE CH A
% 		  a.digitalWrite(8, 0);    %//ENABLE CH B
% 		  a.digitalWrite(13,0);   %//Sets direction of CH B
% 		  a.digitalWrite(11,1);   %//Moves CH B
% 		  pause(delaylength);
%   
% %   check_sensor(a);
% 		  a.digitalWrite(9, 0);     %//ENABLE CH A-
% 		  a.digitalWrite(8, 1);     %//DISABLE CH B
% 		  a.digitalWrite(12,0);    %//Sets direction of CH A
% 		  a.digitalWrite(10, 1);     %//Moves CH A
% 		  pause(delaylength);
%   
% %   check_sensor(a);
% 		  a.digitalWrite(9, 1);   %//DISABLE CH A
% 		  a.digitalWrite(8, 0);   %//ENABLE CH B-
% 		  a.digitalWrite(13,1);  %//Sets direction of CH B
% 		  a.digitalWrite(11,1);  %//Moves CH B
% 		  pause(delaylength);
% 	 end
% 	case 'old'
% 		for  i = 1:nbstep
% %   check_sensor(a);
%            a.digitalWrite(9, 0);    %//ENABLE CH A 
%            a.digitalWrite(8, 1);    %//DISABLE CH B
%            a.digitalWrite(12,1);   %//Sets direction of CH A
%            a.digitalWrite(3, 1);    %//Moves CH A
%            pause(delaylength);
% %   check_sensor(a);
% 		  a.digitalWrite(9, 1);    %//DISABLE CH A
% 		  a.digitalWrite(8, 0);    %//ENABLE CH B
% 		  a.digitalWrite(13,0);   %//Sets direction of CH B
% 		  a.digitalWrite(11,1);   %//Moves CH B
% 		  pause(delaylength);
%   
% %   check_sensor(a);
% 		  a.digitalWrite(9, 0);     %//ENABLE CH A-
% 		  a.digitalWrite(8, 1);     %//DISABLE CH B
% 		  a.digitalWrite(12,0);    %//Sets direction of CH A
% 		  a.digitalWrite(3, 1);     %//Moves CH A
% 		  pause(delaylength);
%   
% %   check_sensor(a);
% 		  a.digitalWrite(9, 1);   %//DISABLE CH A
% 		  a.digitalWrite(8, 0);   %//ENABLE CH B-
% 		  a.digitalWrite(13,1);  %//Sets direction of CH B
% 		  a.digitalWrite(11,1);  %//Moves CH B
% 		  pause(delaylength);
% 		end
%  end
%   stop_motor(a);
% end
% %   clear(a);
% function stop_motor(a)
%     delaylength    = 0.1;    % in seconds
%     a.digitalWrite(9,1);        %//DISABLE CH A
%     a.digitalWrite(8,1);        %//DISABLE CH B
%     a.digitalWrite(11,0);      %//stop Move CH B 
% 
% 	switch  a.shield
% 		case 'new'
% 			 a.digitalWrite(10,0);   
% 		case 'old'
% 			a.digitalWrite(3,0);   
% 	end
%     pause(delaylength);
% end


% IN1=2;IN2=3;EN=4;
% a.digitalWrite(IN1, 0); % stop the motor
% a.digitalWrite(IN2, 0); % stop the mo
% a.analogWrite(EN, 255);  % here must be the analogWrite
% a.digitalWrite(IN1, 1);
% a.digitalWrite(IN2, 0);
% WaitSecs(time)
% a.digitalWrite(IN1, 0); % stop the motor
% a.digitalWrite(IN2, 0); % stop the motor


% a=arduinoManager();a.openGUI=false;a.open;
% monkeytouched=1;
% a.pinMode(2,'Input')
% 
% if monkeytouched
% 	for i=1:20
% 		driveMotor(a)
% 		pause(1)
% 	end
% end
% 
% 
% 
% function driveMotor(a)
%  delaylength = 0.02;
%  nbstep      = 8;
%  for       i = 1:nbstep
% 	 i
% %   check_sensor(a);
% %   sensor    = a.digitalRead(2)
% %   if sensor ==0
% %      break
% %   end
%   a.digitalWrite(9, 0);    %//ENABLE CH A 
%   a.digitalWrite(8, 1);    %//DISABLE CH B
%   a.digitalWrite(12,1);   %//Sets direction of CH A
%   a.digitalWrite(3, 1);    %//Moves CH A
%   pause(delaylength);
%   
% %   check_sensor(a);
% %  sensor    = a.digitalRead(2)
% %    if sensor ==0
% %      break
% %   end
%   a.digitalWrite(9, 1);    %//DISABLE CH A
%   a.digitalWrite(8, 0);    %//ENABLE CH B
%   a.digitalWrite(13,0);   %//Sets direction of CH B
%   a.digitalWrite(11,1);   %//Moves CH B
%   pause(delaylength);
%   
% %   check_sensor(a);
% %  sensor    = a.digitalRead(2)
% %    if sensor ==0
% %      break
% %   end
%   a.digitalWrite(9, 0);     %//ENABLE CH A-
%   a.digitalWrite(8, 1);     %//DISABLE CH B
%   a.digitalWrite(12,0);    %//Sets direction of CH A
%   a.digitalWrite(3, 1);     %//Moves CH A
%   pause(delaylength);
%   
% %   check_sensor(a);
%  
%   a.digitalWrite(9, 1);   %//DISABLE CH A
%   a.digitalWrite(8, 0);   %//ENABLE CH B-
%   a.digitalWrite(13,1);  %//Sets direction of CH B
%   a.digitalWrite(11,1);  %//Moves CH B
%   pause(delaylength);
% %   pause(0.5)
% %   sensor    = a.digitalRead(2)
% %    if sensor ==0
% %      break
% %   end
%    
%  end
%   stop_motor(a);
% end
% %   clear(a);
% function stop_motor(a)
%     delaylength    = 0.01;    % in seconds
%     a.digitalWrite(9,1);        %//DISABLE CH A
%     a.digitalWrite(3, 0);       %//stop Move CH A
%     a.digitalWrite(8,1);        %//DISABLE CH B
%     a.digitalWrite(11,0);      %//stop Move CH B 
%     pause(delaylength);
% end
% 
% % function check_sensor(a)
% %   sensor    = a.digitalRead(2)
% %   if sensor ==0
% %      stop_motor(a);
% %   end
% % end