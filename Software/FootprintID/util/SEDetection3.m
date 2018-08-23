function [ stepEventsSig, stepEventsIdx, stepEventsVal, ...
            stepStartIdxArray, stepStopIdxArray, ... 
            windowEnergyArray, noiseMu, noiseSigma, noiseRange, meanSig ] = SEDetection3( rawSig )

    % this function extract the footsteps from a signal segment
    
    windowSize = 128; 
    initialLen = 500;
    WIN1=50;
    WIN2=300;
    eventSize = WIN1+WIN2;
    sigmaSize = 2;
    meanSig = mean(rawSig);
    signal = rawSig - meanSig;
    
    idx = 1;
    states = 0;
    windowEnergyArray = [];
    windowDataEnergyArray = [];
    stepEventsSig = [];
    stepEventsIdx = [];
    stepEventsVal = [];
    continueDetection = 0;
    noiseRange = [];
    stepStartIdx = 1;
    stepStopIdx = 1;
    stepPeak = 1;
    stepStartIdxArray = [];
    stepStopIdxArray = [];
    
    
    while idx < length(signal) - 2 * max(windowSize, eventSize)
        % if one sensor detected, we count all sensor detected it
        windowData = signal(idx:idx+windowSize-1);
        windowDataEnergy = sum(windowData.*windowData);
        windowEnergyArray = [windowEnergyArray; windowDataEnergy idx];
        if idx <= initialLen
            windowDataEnergyArray = [windowDataEnergyArray windowDataEnergy];
            [noiseMu,noiseSigma] = normfit(windowDataEnergyArray);
        else
            % gaussian fit
            if abs(windowDataEnergy - noiseMu) < noiseSigma * sigmaSize
                
                if states == 1 && idx < length(signal) - eventSize
                    % find the event peak as well as the event
                    stepEnd = idx;
                    stepRange = rawSig(stepStart:stepEnd);
                    [localPeakValue, localPeak] = max(abs(stepRange));
                    stepPeak = stepStart + localPeak - 1;
                    
                    
                    % extract clear signal
                    stepStartIdx = max(stepPeak - WIN1, stepStart);
                    stepStopIdx = stepStartIdx + eventSize - 1;
                    stepSig = rawSig(stepStartIdx:stepStopIdx);
                    stepStartIdxArray = [stepStartIdxArray, stepStartIdx];
                    stepStopIdxArray = [stepStopIdxArray, stepStopIdx];
                    
                    % save the signal
                    if size(stepSig,2) == 1
                        stepEventsSig = [stepEventsSig; stepSig'];
                    else
                        stepEventsSig = [stepEventsSig; stepSig];
                    end
                    stepEventsIdx = [stepEventsIdx; stepPeak];
                    stepEventsVal = [stepEventsVal; localPeakValue];
                    
                    % move the index to skip the event
                    idx = stepStopIdx - windowSize/2;
                end
                states = 0;
                continueDetection = 0;
            else
                % mark step
                if states == 0 && idx - stepPeak > 350
                    stepStart = idx; 
                    states = 1;
                end
            end  
        end
        idx = idx + windowSize/2;
    end
end

