classdef Localizer < handle
    %LOCALIZER a module for localizing a set of TDoA's into x-y coordinates
    
    properties 
        environment     % the surface model and attached sensors
        velocity        % the velocity of a wave to use for localization
    end
    
    methods
        
        function obj = Localizer(environment, velocity)
           if nargin < 2
              error('Must provide an environment and velocity'); 
           end
           if length(environment.sensors) < 3
              error('Environment must have at least 3 sensors!')
           end
           obj.environment = environment;
           obj.velocity = velocity;
        end
        
        function [results, exitFlags]= resolve(obj, tdoas)
            
            % localize an array of tdoas onto the target environment
            % number of tdoa columns must match the number of sensors in 
            % the environment and have a 1-to-1 mapping in matrix index
            
            % number of dimensions in this space
            d = length(obj.environment.dimensions);
            v = obj.velocity;
            
            sensorLocations = obj.environment.getSensorPlacements();
            
            [m,n1] = size(tdoas);           % m x n matrix
            [n2,~] = size(sensorLocations); % n x d matrix 
            
            assert(n1 == n2, 'TDoA count must match number of sensors');
            
            results = zeros(m, d);     % m x d matrix (d-coordinate system)
            exitFlags = zeros(m,1);
            x0 = ones(1,d) * 20; 
            options = optimoptions('fsolve', 'Algorithm', 'levenberg-marquardt', 'Display', 'none');
            
            parfor idx = 1:m
                tdoaSet = tdoas(idx,:);
                
                if sum(~isnan(tdoaSet)) >= 3 
                    [fX,~,exitflag] = fsolve(@(x) build(obj, x, sensorLocations, tdoaSet, v) ,x0,options);
                    exitFlags(idx) = exitflag;
                    results(idx,:) = fX;
                else 
                    results(idx,:) = NaN .* ones(1,d);
                    exitFlags(idx) = NaN;
                end
                
                
            end
            
        end
        
        function F = build(~, x, sensors, tdoas, v)
            
            % generate all indices
            idxs = 1:size(sensors,1);
            % find bad ones to filter out (TDoA == NaN)
            badIdx = find(isnan(tdoas));
            % remove bad indices
            idxs(badIdx) = [];
            
            sCount = length(idxs);

            % tdoas is one set of readings
            i0 = idxs(1);
            t0 = tdoas(i0);      % first one is always reference
            p0 = sensors(i0,:);  % first sensor is reference
            
            % build equations to solve
            F = zeros(sCount-1,1);
            for i = 2:sCount
                idx = idxs(i);
                tDiff = tdoas(idx) - t0;
                F(idx-1) = (norm(x - sensors(idx,:)) - norm(x - p0) - v(idx)*tDiff);
            end 
        end
        
    end
    
end

