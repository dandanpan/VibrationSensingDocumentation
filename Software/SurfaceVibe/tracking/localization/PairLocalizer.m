classdef PairLocalizer < Localizer
    %PAIRLOCALIZER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = PairLocalizer(environment, velocity)
           obj@Localizer(environment, velocity);
        end
        
        function F = build(~, x, sensors, tdoas, v)
            n = size(sensors,1);
            nPairs = n*(n-1)/2;
            F = zeros(nPairs, 1);
            idx=1;
            for i = 1:n
                % get the reference
                % tdoas is one set of readings
                t0 = tdoas(i);      % reference tdoa
                p0 = sensors(i,:);  % reference sensor
                for j = (i+1):n
                    % index to compare
                    tDiff = tdoas(j) - t0;
                    F(idx) = (norm(x - sensors(j,:)) - norm(x - p0) - v(idx)*tDiff);
                    idx = idx+1;
                end
            end
        end
    end
    
end

