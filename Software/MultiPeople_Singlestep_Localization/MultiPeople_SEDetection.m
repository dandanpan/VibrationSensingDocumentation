function [ stepEventsIdx, stepEventsVal, ...
            stepStartIdxArray, stepStopIdxArray, ... 
            windowEnergyArray, noiseMu, noiseSigma, noiseRange ] = MultiPeople_SEDetection( rawSig, noiseSig, windowSize,sigmaSize )

    % this function extract the footsteps from a signal segment
    
%     windowSize = 1024*2.5;
    WIN1=windowSize/2;
    WIN2=windowSize;
    offSet = windowSize/16;
    eventSize = WIN1+WIN2;
%     sigmaSize = 16;
    %% other parameters 
    WIN_start=1024*2.5; % the window for signal start
    WIN_error=offSet*5;
    %%&&&&&&&&&&&
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
        idx
        % if one sensor detected, we count all sensor detected it
        windowData = signal(idx:idx+windowSize-1);
        windowDataEnergy = sum(windowData.*windowData);
        windowEnergyArray = [windowEnergyArray; windowDataEnergy idx]; % save the window energy and index
        
        % gaussian fit
        if abs(windowDataEnergy - noiseMu) < noiseSigma * sigmaSize

            if states == 1 && idx < length(signal) - eventSize
                % find the event peak as well as the event
                stepEnd = idx;
                stepRange = rawSig(stepStart:stepEnd);
                [localPeakValue, localPeak] = max(abs(stepRange));
                stepPeak = stepStart + localPeak - 1;


                % extract clear signal
                stepStartIdx=stepStartIdxArray(length(stepStartIdxArray));
                stepStopIdx = idx+windowSize-1;
                stepSig = rawSig(stepStartIdx:stepStopIdx);
                stepStopIdxArray(length(stepStopIdxArray))=stepStopIdx;

                % save the signal
%                 if size(stepSig,2) == 1
%                     stepEventsSig = [stepEventsSig; stepSig'];
%                 else
%                     stepEventsSig = [stepEventsSig; stepSig];
%                 end
                stepEventsIdx = [stepEventsIdx; stepPeak];
                stepEventsVal = [stepEventsVal; localPeakValue];

                % move the index to skip the event
                idx = stepStopIdx - offSet;
            end
            states = 0;
        else
            % mark step
            if (isempty(stepStartIdxArray)) % this is the first step
                stepStart = idx; 
                states = 1;
                % extract clear signal
                stepStartIdx = max(stepPeak,stepStart-WIN_start);
                stepStopIdx = idx+windowSize-1;
                stepSig = rawSig(stepStartIdx:stepStopIdx);
                stepStartIdxArray = [stepStartIdxArray, stepStartIdx];
                stepStopIdxArray = [stepStopIdxArray, stepStopIdx];
            elseif states == 0 && idx - stepPeak >WIN_error  %% start a new step
                stepStart = idx;
                states = 1;
                stepStartIdx = max(stepStart- WIN_start/2, stepStopIdxArray(length(stepStopIdxArray))-WIN_start/2);
                stepStopIdx = idx+windowSize-1;
                stepSig = rawSig(stepStartIdx:stepStopIdx);
                stepStartIdxArray = [stepStartIdxArray, stepStartIdx];
                stepStopIdxArray = [stepStopIdxArray, stepStopIdx];
            elseif states==0  % continue the last step if encounting step errors
                stepStart = stepStartIdxArray(length(stepStartIdxArray));
                states=1;
                stepStopIdx=idx+windowSize-1;
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
%         if size(stepSig,2) == 1
%             stepEventsSig = [stepEventsSig; stepSig'];
%         else
%             stepEventsSig = [stepEventsSig; stepSig];
%         end
        stepEventsIdx = [stepEventsIdx; stepPeak];
        stepEventsVal = [stepEventsVal; localPeakValue];

    end
end



