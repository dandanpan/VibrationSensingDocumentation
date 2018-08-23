classdef PatternLocalizer
    %PATTERNLOCALIZER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        locations
        patterns
    end
    
    methods
        
        function obj = PatternLocalizer(locations, patterns)
            if nargin < 2
               error('Must provide both locations and patterns'); 
            end
            if length(locations) ~= length(patterns) 
               error('Locations and Patterns must be of same length');
            end
            obj.locations = locations;
            obj.patterns = patterns;
        end
        
        function [results, exitFlags] = resolve(obj, toas)
            
            [m,n] = size(toas); % number of points x number of sensor ToAs
            nPoints = length(obj.patterns); % number of possible patterns
            
            results = zeros(m,2); % initialize storage
            exitFlags = zeros(m,1); % de nada
            % localize each tdoa to a point
            for pIdx = 1:m
                
                % toa of this point
                pToa = toas(pIdx,:);
                % generate tdoa
                pTdoa = zeros(1,n-1);
                for tIdx = 1:n-1
                   pTdoa(tIdx) = pToa(tIdx+1) - pToa(1); 
                end
                
                minError = 10000; % start with some large error value
                estLoc = []; % best match location
                
                % go through each pattern and get error from this current
                % pattern. the one with the lowest error correlates to
                % the estimated location
                for patternIdx = 1:nPoints
                    tdoaDist = sqrt(sum((pTdoa-obj.patterns(patternIdx,:)).^2));
                    if tdoaDist < minError
                        minError = tdoaDist;
                        estLoc = obj.locations(patternIdx,:);
                    end
                end
                
                % save result
                results(pIdx,:) = estLoc;
                exitFlags(pIdx) = minError; % save the error from this point
            end

        end
        
    end
    
end

