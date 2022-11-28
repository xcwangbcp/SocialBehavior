classdef TestTouchManager < optickaCore
	%UNTITLED Summary of this class goes here
	%   Detailed explanation goes here

	%--------------------PUBLIC PROPERTIES----------%
	properties
		devices  = 6; 
		verbose  = false;
        win      = 10;
	end
	properties (SetAccess=private,GetAccess=public)
% 	    devices  
		names  char  ;
        allinfo     ;
		nSlots = 1e5;
	end
	properties (SetAccess = private, GetAccess = private)
		allowedProperties char	= ['devices|rewardPin|rewardTime|openGUI|board|'...
			'port|silentMode|verbose']
	end

	%=======================================================================
	methods %------------------PUBLIC METHODS
	%=======================================================================

		% ===================================================================
		function me = TestTouchManager(varargin)
		%> @fn touchManager
		%> @brief Class constructor
		%>
		%> Initialises the class sending any parameters to parseArgs.
		%>
		%> @param varargin are passed as a structure of properties which is
		%> parsed.
		%> @return instance of the class.
		% ===================================================================
			args = optickaCore.addDefaults(varargin,struct('name','touchManager'));
			me = me@optickaCore(args); %superclass constructor
			me.parseArgs(args, me.allowedProperties);
			[me.devices,me.names,me.allinfo] = GetTouchDeviceIndices([], 1);
			
			
		end
		%================SET UP TOUCH INPUT============
		function  setup(me)
% 					[me.devices,me.names,me.allinfo] = GetTouchDeviceIndices([], 1);
					if   isempty(me.devices)
				 		me.comment = 'No Touch Screen are available, please check the usb end';
				 		fprintf('--->touchManager: %s\n',me.comment);
					elseif length(me.devices)==1
                 		me.comment = 'found one Touch Screen plugged ';
				 		fprintf('--->touchManager: %s\n',me.comment);
% 				 		TouchQueueCreate(win, me.devices(1),me.nSlots);
					elseif length(me.devices)==2
				 		me.comment = 'found two Touch Screens plugged ';
				 		fprintf('--->touchManager: %s\n',me.comment);
					end
		end
		function Qcreate(me,win)
			     TouchQueueCreate(win, me.devices(1), me.nSlots) ;
		end
		%===============START
		function start(me)
				 TouchQueueStart(me.devices(1)); 
		end
		%===============FLUSH
		function flush(me)
		 		 TouchEventFlush(me.devices(1));
		end
		%===========CHECK EVENT=========
		function navail = eventAvail(me)
		 		 navail=TouchEventAvail(me.devices(1));
		end
		function event = getEvent(me,win)
		 		 event = TouchEventGet(me.devices(1), win);
		end
		function stop(me)
			     TouchQueueStop(me.devices(1));
		end
		function touched = checkBox(x, y, box)
			touched = 0;
			checkWin= 0;
			if x>box(1)-checkWin && x<box(3)+checkWin && y>box(2)-checkWin&&y<box(4)+checkWin
				touched = 1;
			end
		end
			
	end
end