function [ TDoAs ] = tdoaFromPeakSet( peakSet, sensorSet )
%UNTITLED Summary of this function goes here
%   peakSet includes: peak location, amplitude, and sensorID
    sensorNum = length(sensorSet);
    TDoAs = [];
    for baseSensorID = 1:sensorNum
        for compareSensorID = baseSensorID+1:sensorNum
            baseIdx = find(peakSet(:,3) == sensorSet(baseSensorID));
            compareIdx = find(peakSet(:,3) == sensorSet(compareSensorID));
            if (baseIdx && compareIdx)
                TDoA = peakSet(baseIdx,1)-peakSet(compareIdx,1);
            else 
                TDoA = NaN;
            end
            % the calculated TDoAs are in the units of micro seconds
            TDoAs = [TDoAs; sensorSet(baseSensorID), sensorSet(compareSensorID), TDoA];
        end
    end


end

