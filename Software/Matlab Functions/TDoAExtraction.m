function [ TDoAs ] = TDoAExtraction( signals, sensorSet, draw, Fs )
%TDOAEXTRACTION Summary of this function goes here
%   Detailed explanation goes here
    if nargin < 3
        draw = 0;
    elseif nargin < 4
        Fs = 6500;
    end
    sensorNum = length(sensorSet);
    TDoAs = [];
    if draw == 1
        figure;
    end
    for baseSensorID = 1:sensorNum
        sig1 = signals{sensorSet(baseSensorID)}(:,2);
        [firstPeak1, val1] = firstPeakExtraction( sig1, 1/2 );    
        
        if draw == 1
            plot(signals{sensorSet(baseSensorID)}(:,1), signals{sensorSet(baseSensorID)}(:,2));hold on;
            plot([signals{sensorSet(baseSensorID)}(firstPeak1,1), signals{sensorSet(baseSensorID)}(firstPeak1,1)], [-10,10],'r');hold on;
        end
        
        for compareSensorID = baseSensorID+1:sensorNum
            sig2 = signals{sensorSet(compareSensorID)}(:,2);
            
            %% tdoa method 1: cross correlation
            [similarity, shift] = max(xcorr(sig1, sig2));
            % TDoA calculates sig1 shift towards right to match sig2
            TDoA1 = (shift-length(sig1))*(1/Fs);
            %% tdoa method 2: first peak that is higher than 1/2 of the highest peak
            [firstPeak2, val2] = firstPeakExtraction( sig2, 1/2 );
            TDoA = signals{baseSensorID}(firstPeak1,1)-signals{compareSensorID}(firstPeak2,1);
            % the calculated TDoAs are in the units of micro seconds
            TDoAs = [TDoAs; baseSensorID, compareSensorID, TDoA, TDoA1];
        end
    end
    if draw == 1
        hold off;
    end
    
end

