function [ location ] = locationEstFromTDoA( TDoAPairs, sensorLoc, sensorSet, velocity )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    % start point is set to center of the sensors
    if nargin < 4
        velocity = 1100;
    end
        
    x0 = [0;0]; 
    for sensorID = sensorSet
        x0 = x0 + sensorLoc{sensorID}';
    end
    x0 = x0./length(sensorSet);
    options = optimoptions('fsolve', 'Algorithm', 'levenberg-marquardt', 'Display', 'none');
    
    [location, ~, ~] = fsolve(@(x) buildLocEq( TDoAPairs, sensorLoc, x, velocity ),x0,options);
end

