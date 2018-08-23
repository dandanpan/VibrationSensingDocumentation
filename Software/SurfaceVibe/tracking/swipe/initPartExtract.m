function [ initLoc, initIdx, restEvent, initTdoa] = initPartExtract( event, Fs, wFilter, localizer )
%INITPARTEXTRACT Summary of this function goes here
%   Detailed explanation goes here
    restEvent = copy(event);
    rawSig = event.data;
    initIdx = -1;
    
    eProfile = [];
    energyIdx = [];
    for swIdx = 1:Fs/100:length(rawSig)-Fs/100
        tempWinEnergy = [];
        for senIdx = 2:5
            tempE = sqrt(sum(rawSig(swIdx+1:swIdx+Fs/100,senIdx).^2));
            tempWinEnergy = [tempWinEnergy, tempE];
        end
        eProfile = [eProfile, sum(tempWinEnergy)];
        energyIdx = [energyIdx, swIdx];
        if swIdx > 1 && eProfile(end)-eProfile(end-1) > .5
            initIdx = swIdx;
            break;
        end
    end
    
    initSig = rawSig(max(1,initIdx-2*Fs/100):min(initIdx+8*Fs/100,length(rawSig)),:);
    filteredInit = wFilter.filter(initSig);
%     filteredInit = filter(wFilter, initSig);
    filteredInit(1:200,:) = [];
    
%     figure;plot(filteredInit);
    threshold = 6;
    
    oneTdoa = [];
    MPH = max(filteredInit(:,2))/threshold;
    [~,i] = findpeaks(filteredInit(:,2),'MinPeakHeight',MPH,'Annotate','extents');hold on;
    oneTdoa = [oneTdoa, i(1)];
    MPH = max(filteredInit(:,3))/threshold;
    [~,i] = findpeaks(filteredInit(:,3),'MinPeakHeight',MPH,'Annotate','extents');hold on;
    oneTdoa = [oneTdoa, i(1)];
    MPH = max(filteredInit(:,4))/threshold;
    [~,i] = findpeaks(filteredInit(:,4),'MinPeakHeight',MPH,'Annotate','extents');hold on;
    oneTdoa = [oneTdoa, i(1)];
    MPH = max(filteredInit(:,5))/threshold;
    [~,i] = findpeaks(filteredInit(:,5),'MinPeakHeight',MPH,'Annotate','extents');hold off;
    oneTdoa = [oneTdoa, i(1)];

    initLoc = localizer.resolve(oneTdoa./Fs);
    restEvent.data(1:min(initIdx+10*Fs/100,length(restEvent.data)),:) = [];
    initTdoa = oneTdoa ./ Fs;

end

