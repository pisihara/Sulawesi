function [expiry,zone] = newRequest(timeStep,zonelocations)

%% Determine zone in which request occurs by a uniform random process
z = randperm(11);
zone(1)=z(1);
zone(2)=zonelocations(zone(1),1);
zone(3)=zonelocations(zone(1),2);
zone(4)= 1050;
zone(5)= 1700;

%% Determine the number of minutes before request expires
expiry=timeStep+100*rand; %time request will expire
end