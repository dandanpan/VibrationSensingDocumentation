function [ stepEventsSig, stepEventsIdx, stepEventsVal, ...
            stepStartIdxArray, stepStopIdxArray, ... 
            windowEnergyArray, noiseMu, noiseSigma, noiseRange ] = SEDetection( rawSig, noiseSig )

    % this function extract the footsteps from a signal segment
    
    windowSize = 1024*2.5;
    WIN1=windowSize/2;
    WIN2=windowSize;
    offSet = windowSize/2;
    eventSize = WIN1+WIN2;
    sigmaSize = 24;
    
    states = 0;
    windowEnergyArray = [];
    windowDataEnergyArray = [];
    stepEventsSig = [];
    stepEventsIdx = [];
    stepEventsVal = [];
    noiseRange = [];
    stepPeak = 1;
    stepStartIdxArray = [];
    stepStopIdxArray = [];
    
    idx = 1;
    while idx < length(noiseSig) - max(windowSize, eventSize) - 10
         windowData = noiseSig(idx:idx+windowSize-1);
         windowDataEnergy = sum(windowData.*windowData);
         windowDataEnergyArray = [windowDataEnergyArray windowDataEnergy];
         idx = idx + offSet; 
    end
    [noiseMu,noiseSigma] = normfit(windowDataEnergyArray);
    
    idx = 1;
    windowEnergyArray = [];
    signal = rawSig;
    
    while idx < length(signal) - 2 * max(windowSize, eventSize)
        % if one sensor detected, we count all sensor detected it
        windowData = signal(idx:idx+windowSize-1);
        windowDataEnergy = sum(windowData.*windowData);
        windowEnergyArray = [windowEnergyArray; windowDataEnergy idx];
        
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
                idx = stepStopIdx - offSet;
            end
            states = 0;
        else
            % mark step
            if states == 0 && idx - stepPeak > WIN1
                stepStart = idx; 
                states = 1;
            end
        end  
        
        idx = idx + offSet;
    end
    % unfinished Step
    if states == 1
        stepEnd = length(signal);
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

    end
end

