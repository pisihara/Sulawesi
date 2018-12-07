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
        
        function obj = UAVMANAGER(x,y,batterylife,zone,requestID,speed,park)
          obj.UAVlog(:,1) = x; % initial x coordinate of UAVs
          obj.UAVlog(:,2) = y; % initial y coordinates of UAVs
          obj.UAVlog(:,3) = batterylife; % battery life of UAVs (minutes)
          obj.UAVlog(:,4) = zone; % zone of destination of UAVs
          obj.UAVlog(:,5) = requestID; % requests assigned to UAVs
          obj.UAVlog(:,6) = speed; % speed in km/hr of UAVs
          obj.UAVlog(:,7) = park; %remaining time for UAV to be parked 
        end
        
        function [obj,RM]= assignUAVs(obj,REQUESTMANAGER,reqid,fleetsize)
            RM=REQUESTMANAGER;
            for i=1:reqid
                
                if RM.requestlog(i,6)==0 && RM.requestlog(i,7)==0%% Request i is active&unassigned
                    if RM.requestlog(i,10) == max(RM.requestlog(:,10))
                    for j=1:fleetsize
                        if obj.UAVlog(j,5)==0 && RM.requestlog(i,7)==0 %% UAV j is unassigned
                            obj.UAVlog(j,5)=i; %% UAV j is assigned to request i
                            RM.requestlog(i,7)=j; %% request i is assigned
                            RM.requestlog(i,6)=1; %Mark request as completed
                            RM.requestlog(i,10)=0; %Set priority to zero
                        end
                   
                    end
                    else
                        i=i+1;
                    end
                end
            end
          end                
                    
         
        function [obj,RM] = updateUAVpositions(obj,REQUESTMANAGER,fleetsize)
            RM=REQUESTMANAGER;
            for i=1:fleetsize                                    
                if  obj.UAVlog(i,5)~= 0  % UAV has an active request
                  x2=RM.requestlog(obj.UAVlog(i,5),4); %x-coord of drop-off
                  y2=RM.requestlog(obj.UAVlog(i,5),5); % y-coord of drop off
                  x1= obj.UAVlog(i,1);  %x-coord of UAV
                  y1= obj.UAVlog(i,2); %y-coord of UAV
                  d=((x2-x1)^2+(y2-y1)^2)^.5; %distance left to current request zone
                  d2=((1050-x2)^2+(1700-y2)^2)^.5; %distance from current request zone to base
                  d3=d+d2; %total distance to request zone and back to base
                  
                  if obj.UAVlog(i,3)*(100/1.8204)*(obj.UAVlog(i,6)/60) < d3 %UAV does not have enough battery to deliver and get back to base
                      x2=RM.requestlog(obj.UAVlog(i,5),8); %x-coordinate of base
                      y2=RM.requestlog(obj.UAVlog(i,5),9); %y-coordinate of base
                      d=((x2-x1)^2+(y2-y1)^2)^.5; %distance left to base
                      dx = (100/1.8204)*(1/60)*(x2-x1)*obj.UAVlog(i,6)/d; %distance to move in the x direction
                      dy = (100/1.8204)*(1/60)*(y2-y1)*obj.UAVlog(i,6)/d; %distance to move in the y direction
                      
                      if sqrt(dx^2+dy^2) < d %The distance UAV will travel in one time step is less than total distance left
                      obj.UAVlog(i,1) = x1 + dx; %update x-coord of UAV
                      obj.UAVlog(i,2) = y1 + dy; %update y-coord of UAV
                     else %The distance UAV will travel in one time step is greater than total distance left
                      obj.UAVlog(i,1) = x2; %update x-coord of UAV to base coord
                      obj.UAVlog(i,2) = y2; %update y-coord of UAV to base coord
                      obj.UAVlog(i,7) = obj.UAVlog(i,7)-1; %Start park timer countdown
               
                      
                      if obj.UAVlog(i,7) == 0 %Park timer reaches 0
                          obj.UAVlog(i,5) = 0; %Take away active request
                          obj.UAVlog(i,7) = 5; %Reset park timer to 5 minutes
                          obj.UAVlog(i,3) = 120; %Give UAV a new battery pack
                      end   
                      end
                  else  %UAV does have enough battery to deliver and get back to base
                  d=((x2-x1)^2+(y2-y1)^2)^.5; %total distance left to request zone
                  dx = (100/1.8204)*(1/60)*(x2-x1)*obj.UAVlog(i,6)/d; %distance to move in the x direction
                  dy = (100/1.8204)*(1/60)*(y2-y1)*obj.UAVlog(i,6)/d; %distance to move in the y direction
                  
                      if sqrt(dx^2+dy^2) < d %The distance UAV will travel in one time step is less than total distance left
                      obj.UAVlog(i,1) = x1 + dx; %update x-coord of UAV
                      obj.UAVlog(i,2) = y1 + dy; %update y-coord of UAV
                     else %The distance UAV will travel in one time step is greater than total distance left
                      obj.UAVlog(i,1) = x2; %update x-coord of UAV to request zone coord
                      obj.UAVlog(i,2) = y2; %update y-coord of UAV to request zone coord
                      obj.UAVlog(i,7) = obj.UAVlog(i,7)-1; %Start park timer countdown
                   
                      
                      if obj.UAVlog(i,7) == 0 %Park timer reaches 0
                          RM.requestlog(obj.UAVlog(i,5),6)= 1;
                          RM.requestlog(obj.UAVlog(i,5),6)
                          obj.UAVlog(i,5)
                          obj.UAVlog(i,5) = 0; %Take away active request
                          obj.UAVlog(i,7) = 5; %Reset park timer to 5 minutes
                          
                      end
                  end
                  obj.UAVlog(i,3) = obj.UAVlog(i,3)-1; %Battery level decreases by one unit per minute
                  end
                end
            end
        end
    end
end
