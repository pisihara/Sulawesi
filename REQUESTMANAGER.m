classdef REQUESTMANAGER
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        requestlog
    end
    
    methods
        function obj = REQUESTMANAGER(log,maxrequest)
            obj.requestlog=zeros(maxrequest,7); %% simulation can process up to 100 frequests.
            obj.requestlog(1,:)=log;  %% initialize request log
               
         end
         
        function obj = addNewRequest(obj,time,expiry,zone,reqid)
            %METHOD Add a new request to the Request Log
            obj.requestlog(reqid,1) = time; % time of new request
            obj.requestlog(reqid,2) = expiry; % time new request will expire
            obj.requestlog(reqid,3) = zone(1); % zone of new request
            obj.requestlog(reqid,4) = zone(2); % x coord of zone drop-off
            obj.requestlog(reqid,5) = zone(3); % y coord of zone drop-off
            obj.requestlog(reqid,6) = 0; % 0=new request is active; 1=completed; -1=expired
            obj.requestlog(reqid,7) = 0; % UAV assigned to the request
            obj.requestlog(reqid,8) = zone(4); %x-coordinate of base
            obj.requestlog(reqid,9) = zone(5); %y-coordinate of base
        end
    end
end

