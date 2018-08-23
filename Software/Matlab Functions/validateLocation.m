function [ isValid ] = validateLocation( SensorLocations, calcLocation )
%VALIDATELOCATION Summary of this function goes here
%   Detailed explanation goes here
    sensorNum = size(SensorLocations,1);
    distToSensor = 0;
    for sensorID = 1 : sensorNum
        distToSensor = distToSensor + dist(SensorLocations(sensorID,:),calcLocation);
    end
    if distToSensor > 30
        isValid = 0
    else
        isValid = 1;
    end

end

