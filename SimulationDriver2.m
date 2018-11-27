%% Goal:  To illustrate object oriented programming in MATLAB 
%%         using a simple UAV fleet assignment model

clear all; close all; format long;

%% Parameters
lengthSimulation=100;    % Number of time steps in minutes
requestprob=.7; % probability that a request occurs each minute
numZones = 11;  % number of request zones
base = [1050,1700];    % Location of the base (x,y) on the simulation map
km2pixRatio = 1.8204/100; % Number of pixels in one kilometer on the map (converted from miles)
% (x,y) locations of zone delivery locations (in pixels) on the simulation map
zoneLocations = [1100 1470;
                 1070 1100;
                 1030 930;
                 750 420;
                 685 1350;
                 600 1150;
                 480 930;
                 300 620;
                 300 398;
                 1280 2000;
                 1000 2300];
% Color array for the UAV's
color = ['y', 'c','m','b','r','w','k','g','y','c','m','b','r','w','k','g'];

%% Create UAV Fleet 
numUAVs = 3; % The number of UAV's in the fleet;
for i=1:numUAVs
    x(i,1)=base(1,1); %initially all UAVs are at the base
    y(i,1)=base(1,2);
    batterylife(i,1)=600; %each UAV is fully charged (60 minute) 
    zone(i,1)=0;  % no UAV has been assigned a request yet
    requestID(i,1)=0;
    speed(i,1)=35;  % each UAV has a speed of 35 km/hr
end
    
CayeyUAVManager = UAVMANAGER(x,y,batterylife,zone,requestID,speed);        

%% Create UAV Request Manager
maxrequest=100;
log=[0,0,0,base(1,1),base(1,2),0,0];
CayeyRequestManager = REQUESTMANAGER(log,maxrequest);
            
%% Read in map for background of graph (use file name of image for map)
% and plot the base location
figure
MAP=imread('Sulawesi_regions.png'); image(MAP);
hold on
plot(base(1,1),base(1,2),'ro','MarkerFaceColor','r')
hold on

%% Run Simulation and display UAV paths
reqid=0; %% Initially there are no requests
for timeStep =1:lengthSimulation
    r=rand;
    if r <= requestprob
      reqid=reqid+1;
      [expiry,zone] = newRequest(timeStep,zoneLocations)
      CayeyRequestManager=CayeyRequestManager.addNewRequest(timeStep,expiry,zone,reqid)
      [CayeyUAVManager,CayeyRequestManager]=CayeyUAVManager.assignUAVs(CayeyRequestManager,reqid,numUAVs);
    end
      
   CayeyUAVManager=CayeyUAVManager.updateUAVpositions(CayeyRequestManager,numUAVs);
    for k=1:numUAVs
        xUAV(timeStep,k)=CayeyUAVManager.UAVlog(k, 1);
        yUAV(timeStep,k)=CayeyUAVManager.UAVlog(k, 2);
    end
    for k=1:numUAVs
       plot(xUAV(:,k),yUAV(:,k),color(k))
       hold on
    end
      pause(.1)
    end

