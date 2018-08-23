function [ TDoAs, peaksInOrder, highestFourPeaks, allPeaks, peakEnergyVariation, highestEnergySetIdx ] = TDoAExtraction3( signals, sensorSet, draw )
%TDOAEXTRACTION Summary of this function goes here
%   Using smaller sliding windows
    if nargin < 3
        draw = 0;
    end
    subWindowSize = 0.02;
    sensorNum = length(sensorSet);
    TDoAs = [];
    if draw == 1
        figure;
    end
    
    peakValSum = []; peakTimeEnd = [];
    for baseSensorID = 1:sensorNum
        stepSig = signals{sensorSet(baseSensorID)}(:,2);
        [ peakLoc{baseSensorID}, peakVal{baseSensorID} ] = inStepPeakExtraction( stepSig, 1/3 );
        peakTime{baseSensorID} = signals{sensorSet(baseSensorID)}(peakLoc{baseSensorID},1);
        peakTimeEnd = [peakTimeEnd, peakTime{baseSensorID}(end)];
    end
    
    selectedPeak = [];
    allPeaks = [];
    timeStamp = 0;
%     for timeStamp = 0:subWindowSize/2:0.16
    
    while timeStamp < max(peakTimeEnd)
        startTime = timeStamp;
        stopTime = timeStamp+subWindowSize;
        peakInfo = [];
        % one direction
        for sensorID = 1:sensorNum
            selectIdx = find(peakTime{sensorID}>=startTime & peakTime{sensorID}<stopTime & peakVal{sensorID} > 0);
            if ~isempty(selectIdx)
                peakInfo = [peakInfo; peakTime{sensorID}(selectIdx), peakVal{sensorID}(selectIdx), ones(length(selectIdx),1)*sensorID];
            end
        end
        % the other direction
        for sensorID = 1:sensorNum
            selectIdx = find(peakTime{sensorID}>=startTime & peakTime{sensorID}<stopTime & peakVal{sensorID} < 0);
            if ~isempty(selectIdx)
                peakInfo = [peakInfo; peakTime{sensorID}(selectIdx), peakVal{sensorID}(selectIdx), ones(length(selectIdx),1)*sensorID];
            end
        end
        if size(peakInfo,1) == sensorNum && (all(peakInfo(:,2) > 0) || all(peakInfo(:,2) < 0)) && length(unique(peakInfo(:,3))) == sensorNum
            % potential peak
            selectedPeak = [selectedPeak; peakInfo];
        end
        allPeaks = [allPeaks; peakInfo];
        timeStamp = timeStamp + subWindowSize/5;
    end
    
    selectedPeak = unique(selectedPeak,'rows');
    peakSetNum = size(selectedPeak,1)/sensorNum;
    selectedPeakEnergy = zeros(peakSetNum, 1);
    firstFourPeaks = selectedPeak(1:sensorNum,:);
    
    for peakSetID = 1:peakSetNum
        selectedPeakEnergy(peakSetID) = sum(abs(selectedPeak((peakSetID-1)*sensorNum+1:peakSetID*sensorNum,2)));
    end
    [~, highestEnergySetIdx] = max(selectedPeakEnergy);
    highestFourPeaks = selectedPeak((highestEnergySetIdx-1)*sensorNum+1:highestEnergySetIdx*sensorNum,:);
    
    peakEnergyVariation = std(selectedPeakEnergy);
    
    peaksInOrder = zeros(sensorNum, 3);
    % find first four peaks
    for baseSensorID = 1:sensorNum
        tSensorID = find(ismember(firstFourPeaks(:,1), peakTime{baseSensorID}) > 0);
        peaksInOrder(baseSensorID,:) = firstFourPeaks(tSensorID,:);
        if draw == 1
            plot(signals{sensorSet(baseSensorID)}(:,1), signals{sensorSet(baseSensorID)}(:,2));hold on;
            scatter(selectedPeak(:,1), selectedPeak(:,2),'rv');hold on;
            scatter(allPeaks(:,1),allPeaks(:,2),'k*');hold on;
        end 
    end
    
    for baseSensorID = 1:sensorNum
        for compareSensorID = baseSensorID+1:sensorNum
            TDoA = peaksInOrder(baseSensorID,1)-peaksInOrder(compareSensorID,1);
            % the calculated TDoAs are in the units of micro seconds
            TDoAs = [TDoAs; baseSensorID, compareSensorID, TDoA];
        end
    end
    
    if draw == 1
        hold off;
    end
    
end

