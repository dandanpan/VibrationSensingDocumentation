function [ stepEventsIdx, stepEventsVal, ...
            stepStartIdxArray, stepStopIdxArray, ... 
            windowEnergyArray, noiseMu, noiseSigma, noiseRange ] = SEDetectionSigma( rawSig, noiseSig, sigmaSize )

    % This function extract the footstep-induced signals 
    % Inputs:
    %     rawSig: entire investigated signal segments
    %     noiseSig: sample ambient noise signal segments without any excitation
    %     sigmaSize: Gaussian noise model based parameter, impacts false positive/negative rate
    
    windowSize = 1024;     % can be adjusted based on the sampling rate
    WIN1=windowSize/2;     % pre-defined signal onset size
    WIN2=windowSize*2;     % pre-defined signal tail size
    offSet = windowSize/2; % sliding window step size
    eventSize = WIN1+WIN2; % total event size
    
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
    
    % noiseSig modeling
    idx = 1;
    while idx < length(noiseSig) - max(windowSize, eventSize) - 10
         windowData = noiseSig(idx:idx+windowSize-1);
         windowDataEnergy = sum(windowData.*windowData);
         windowDataEnergyArray = [windowDataEnergyArray windowDataEnergy];
         idx = idx + offSet; 
    end
    [noiseMu,noiseSigma] = normfit(windowDataEnergyArray);
    
    % rawSig detecting
    idx = 1;
    windowEnergyArray = [];
    signal = rawSig;
    
    while idx < length(signal) - 2 * max(windowSize, eventSize)
        windowData = signal(idx:idx+windowSize-1);
        windowDataEnergy = sum(windowData.*windowData);
        windowEnergyArray = [windowEnergyArray; windowDataEnergy idx];
        
        % gaussian noise model updates
        if abs(windowDataEnergy - noiseMu) < noiseSigma * sigmaSize
            % the window is noise
            if states == 1 
                % previous window is step
                % find the event peak as well as the event
                stepEnd = idx;
                stepRange = rawSig(stepStart:stepEnd);
                [localPeakValue, localPeak] = max(abs(stepRange));
                stepPeak = stepStart + localPeak - 1;


                % extract clear signal
                stepStartIdx = min(stepPeak - WIN1, stepStart);
                stepStopIdx = max(stepStartIdx + eventSize - 1,stepEnd);
                stepStartIdxArray = [stepStartIdxArray, stepStartIdx];
                stepStopIdxArray = [stepStopIdxArray, stepStopIdx];
                stepEventsIdx = [stepEventsIdx; stepPeak];
                stepEventsVal = [stepEventsVal; localPeakValue];

                % move the index to skip the event
                idx = stepStopIdx - offSet;
            end
            states = 0;
        else
            % mark step
            if states == 0 && idx - stepPeak > WIN2
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

