%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Class identified to Controller
%ma581
% It is called in the code ScenarioBase line 171
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef controller < handle
    
    properties
        previousClass = 'No Movement';
        currentClass;
        classNames = {
            'No Movement'; 
            'Power Grasp'; %2
            'Hook Grasp';
            'Thumb Grasp'; %4 
            'Point Grasp';
            'Index Grasp';%6
            'Tripod Grasp'; 
            'Hand Open'; %8
            'Shoulder Flexion'; %9 For middle finger :P --- Custom classes
            'Middle Grasp'; 
            'Ring Grasp';
            'Little Grasp';
            };
        mappingTable = {'G0', 'G0', 'G1', 'G2', 'G3', 'G4', 'G5'};
        firstRun = 1;
        port; %Contains Serial Port variable
        
        customGrips = {'F2 P100 S255', 'F0 P100 S255'; 
            'F3 P100 S255', 'F0 P100 S255'; 
            'F4 P100 S255', 'F0 P100 S255'; };
    end
    %     properties (Constant)
    %         firstRun = 1;
    %     end
    
    methods(Static)
        
    end
    
    methods
        function obj = controlHand(obj,className)
            
            obj.currentClass = className;
            
            % Calling Termite (terminal)
            
            classHasNotChanged = strcmp(obj.currentClass,obj.previousClass);
            classNoMovement = strcmp(obj.currentClass, obj.classNames{1});
            openHand = strcmp(obj.currentClass,obj.classNames{8});
            middleFinger = strcmp(obj.currentClass,obj.classNames{9});
            
            currentIndex = find(ismember(obj.classNames, obj.currentClass));
            previousIndex = find(ismember(obj.classNames, obj.previousClass));
            
            
            % Turn off demo mode for first run
            
            %             if obj.firstRun ==1
            %                 obj.termiteMA('A0');
            %                 obj.firstRun =0;
            %             end
            
            
            
            if (classHasNotChanged==false && classNoMovement==false)
                % Call terminal with new input string
                
                if openHand
                    % Open previous grip
%                     a = strcat(obj.mappingTable{previousIndex}, ' 0')
                    a = 'G0 O'
                    disp('openHand');
                    obj.sendToCOMPort(a);
                    %                     obj.termiteMA([obj.mappingTable{previousIndex}, ' O']);
                elseif middleFinger
                    a = 'G0 C'
                    obj.sendToCOMPort(a);
                    a = 'F2 P0 S255'
                    obj.sendToCOMPort(a);
                elseif currentIndex<=9
                    %First open previous grip
                    %                     obj.termiteMA([obj.mappingTable{previousIndex}, ' O']);
                    %a = strcat(obj.mappingTable{previousIndex}, ' 0')
                    a = 'G0 O'
                    obj.sendToCOMPort(a);
                    %Now close current crip
                    a = strcat(obj.mappingTable{currentIndex}, ' C')
                    obj.sendToCOMPort(a);
                    %                     obj.termiteMA([obj.mappingTable{currentIndex}, ' C']);
                    obj.previousClass = obj.currentClass; %update previous class for next iteration
                end
            end
            %             end
        end
        
        function [] = termiteMA(obj,inputString)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Calling Termite (terminal)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Setup .ini of Termite for the correct channel communications and
            % COM port number
            % See here http://www.compuphase.com/software_termite.htm
            
            fname = tempname; %Temporary file
            while exist(fname, 'file')
                fname = tempname;
            end
            
            fid = fopen(fname, 'wt');
            
            fprintf(fid, inputString ); %write out the input parameters the program will need
            fclose(fid);
            
            system(['Termite.exe < ' fname]);
            %inputString %For testing
            
            
            % TAKING INPUT
            % If it is straight-forward text input (as seems likely from your reference to a simple way
            % to do it in IDL) then I suggest you create files containing the inputs, and use I/O
            % redirection:
            %
            % fname = tempname;
            % while exist(fname, 'file')
            %   fname = tempname;
            % end
            %
            % fid = fopen(fname, 'wt');
            % FID = fopen(FILENAME,PERMISSION) opens the file FILENAME in the
            %     mode specified by PERMISSION
            % fprintf(fid, .... ) %write out the input parameters the program will need
            % fclose(fid);
            %
            % system(['MyExecutable.exe < ' fname]); %run executable with content of fname as inputs
            
            
            
            
        end
        
        function obj = openCOMPort(obj)
            disp('Opening COM Port');
            obj.port = serial('COM3');
            set(obj.port,'BaudRate',38400);
            fopen(obj.port);
        end
        
        function [] = sendToCOMPort(obj, message)
            
            for i=1:900
                if((obj.port.BytesAvailable > 0) && strcmp(obj.port.Status,'open'))
                    fprintf(obj.port,message);
                    disp('Sent message');
                    break;
                else
                    pause(0.1);
                end
            end
            
        end
        
        
        %% Grip Table
        % Command	Function	Description
        % G0	Fist grip       All fingers and thumb move
        % G1	Palm grip       Fingers move, thumb stays open
        % G2	Thumbs up       Fingers remain closed, thumb moves
        % G3	Point           All fingers closed, index finger moves
        % G4	Pinch grip      All fingers closed, thumb and index finger move
        % G5	Tripod grip     All fingers closed, thumb, index and middle finger move
        %
        % G# O	Open grip       Open grip (# is a grip number)
        % G# C	Close  grip     Close grip (# is a grip number)
        
        %% Serial port communication
%             s = serial('COM3');
%             set(s,'BaudRate',38400);
%             fopen(s);
%               pause(0.9);
%             fprintf(s,'G1 C');
%         %     for i=1:10
%         %         out = fscanf(s)
%         %     end
%             fprintf(s,'G0 C')
%             fclose(s)
%             delete(s)
%             clear s
    end
end
    
    % fclose(instrfind)