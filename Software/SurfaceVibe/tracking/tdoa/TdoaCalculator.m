classdef TdoaCalculator < handle
    %TdoaCalculator generic class for calculating tdoa between signals
    
    properties
    end
    
    methods
        
        % calculate
        % given a 1-d vector for time and a matrix of signals
        % compute the tdoa between the given set of signals
        function tdoa = calculate(obj, time, signals)
            tdoa = mean(zeros(size(signals)));
            error('Use a concrete subclass of this');
        end
        
    end
    
end

