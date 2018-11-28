%% RequestZone object class
classdef UAVMANAGER < handle
    %keeps track of UAV fleet position and status
       
    properties
       UAVlog  %%  ith row describes UAV i
        % (i,1) = x coord  
        % (i,2) = y coord 
        % (i,3) = remaining battery (minutes) 
        % (i,4)  = destination zone
        %        base= zone 0  parked = -1
        % (i,5) = speed in km/hr
    end
    
    
    methods
        % Constructor 
        
        function obj = UAVMANAGER(x,y,batterylife,zone,requestID,speed)
          obj.UAVlog(:,1) = x; % initial x coordinate of UAVs
          obj.UAVlog(:,2) = y; % initial y coordinates of UAVs
          obj.UAVlog(:,3) = batterylife; % battery life of UAVs (minutes)
          obj.UAVlog(:,4) = zone; % zone of destination of UAVs
          obj.UAVlog(:,5) = requestID; % requests assigned to UAVs
          obj.UAVlog(:,6) = speed; % speed in km/hr of UAVs
        end
        
        function [obj,RM]= assignUAVs(obj,REQUESTMANAGER,reqid,fleetsize)
            RM=REQUESTMANAGER;
            for i=1:reqid
                if RM.requestlog(i,6)==0 && RM.requestlog(i,7)==0%% Request i is active&unassigned
                    for j=1:fleetsize
                        if obj.UAVlog(j,5)==0 && RM.requestlog(i,7)==0 %% UAV j is unassigned
                            obj.UAVlog(j,5)=i; %% UAV j is assigned to request i
                            RM.requestlog(i,7)=j; %% request i is assigned
                        end
                    end
                end
            end
          end                
                    
         
        function obj= updateUAVpositions(obj,REQUESTMANAGER,fleetsize)
            RM=REQUESTMANAGER;
            for i=1:fleetsize                                    
                if  obj.UAVlog(i,5)~= 0  % UAV has an active request
                  x1= obj.UAVlog(i,1);  %x-coord of UAV
                  y1= obj.UAVlog(i,2); % y-coord of UAV
                  x2=RM.requestlog(obj.UAVlog(i,5),4); %x-coord of drop-off
                  y2=RM.requestlog(obj.UAVlog(i,5),5); % y-ccord of drop off
                  d=((x2-x1)^2+(y2-y1)^2)^.5;
                  dx = (100/1.8204)*(1/60)*(x2-x1)*obj.UAVlog(i,6)/d;
                  dy = (100/1.8204)*(1/60)*(y2-y1)*obj.UAVlog(i,6)/d;
                  if sqrt(dx^2+dy^2) < d
                      obj.UAVlog(i,1) = x1 + dx;
                      obj.UAVlog(i,2) = y1 + dy;
                  else 
                      obj.UAVlog(i,1) = x2;
                      obj.UAVlog(i,2) = y2;
                  end
                end
            end
        end
    end
end