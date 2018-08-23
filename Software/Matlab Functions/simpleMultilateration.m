function [ locX, locY ] = simpleMultilateration( measurements, sensorLoc, speed )
%SIMPLEMULTILATERATION Summary of this function goes here
%   Detailed explanation goes here
    measurements = measurements(measurements>0);
    delta1 = measurements(1)-measurements(2);
    delta2 = measurements(1)-measurements(3);
    minError = 1000000;
    locX = -1;
    locY = -1;
    if delta1 > 10^16/100 || delta2 > 10^16/100
        return;
    end
    
    for i = -10:0.1:20
        for j = -10:0.1:20
            currentError = 0;
            dist1 = sqrt((i-sensorLoc(1,1))*(i-sensorLoc(1,1))+(j-sensorLoc(1,2))*(j-sensorLoc(1,2)));
            dist2 = sqrt((i-sensorLoc(2,1))*(i-sensorLoc(2,1))+(j-sensorLoc(2,2))*(j-sensorLoc(2,2)));
            dist3 = sqrt((i-sensorLoc(3,1))*(i-sensorLoc(3,1))+(j-sensorLoc(3,2))*(j-sensorLoc(3,2)));
            mdelta1 = dist1 - dist2;
            mdelta2 = dist1 - dist3;
            
            ddelta1 = delta1/10^16*speed;
            ddelta2 = delta2/10^16*speed;
            currentError = currentError + (ddelta1-mdelta1)*(ddelta1-mdelta1);
            currentError = currentError + (ddelta2-mdelta2)*(ddelta2-mdelta2);
            
            if currentError < minError
                locX = i;
                locY = j;
                minError = currentError;
            end
            
        end
    end

end

