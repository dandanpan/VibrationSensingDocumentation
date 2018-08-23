function [ medianFreq ] = medianFrequency( Y, f )
%MEDIANFREQUENCY Summary of this function goes here
%   Detailed explanation goes here
    sumEnergy = 0;
    medianFreq = 0;
    totalEnergy = sum(Y.*Y);
    for i = 1 : length(Y)
        sumEnergy = sumEnergy + Y(i)*Y(i);
        if sumEnergy >= totalEnergy/2;
            medianFreq = f(i);
            break;
        end
    end

end

