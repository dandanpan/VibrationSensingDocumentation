% Explore different speed modes
% PLOT strength v.s. speed v.s. people

configuration_setup;
plotTrace = 0;
stepStrength = zeros(numPeople,numSpeed);
stepStrengthStd = zeros(numPeople,numSpeed);
for personID = 1 : numPeople
    load(['../dataset/P' num2str(personID) '.mat']);
    if plotStep == 1
        figure;
    end
    stepSigs = [];
    stepSigsLabel = [];   
    personIDLabel = [];   
    speedIDLabel = [];    
    traceIDLabel = [];    
    speedCount = 0;
    for speedID = speedSequence %1 : numSpeed
        speedCount = speedCount + 1;
        Signals = P{personID}.Sen{sensorID}.S;
        traces = Signals{speedID};
        trainingTraceID = [1:5];
        tempStepStrength = [];
        for traceID = trainingTraceID
            traceSig = traces{traceID,1};
            traceSigFilter = signalDenoise(traceSig, 50);

            [ stepEventValue ,stepEventsIdx ] = findpeaks(traceSigFilter,'MinPeakDistance',200,'MinPeakHeight',50,'Annotate','extents');
            % filter out-of-range steps
            stepEventValue = stepEventValue(stepEventsIdx > WIN1 & stepEventsIdx < length(traceSigFilter)-WIN2);
            stepEventsIdx = stepEventsIdx(stepEventsIdx > WIN1 & stepEventsIdx < length(traceSigFilter)-WIN2);
            % select steps by energy
            [ selectedSteps ] = stepSelectionSNR( traceSigFilter, stepEventsIdx, WIN1, WIN2, 3 );
            stepEventsIdx = stepEventsIdx(selectedSteps);
            stepEventValue = stepEventValue(selectedSteps);

            if plotTrace == 1
                figure;
                plot(traceSigFilter);hold on;
                scatter(stepEventsIdx, stepEventValue, 'rV');
                hold off;
            end

            tempMF = 0;
            mcount = 0;
            for stepID = 1 : length(stepEventsIdx)
                % find first peak
                tempSig = traceSigFilter(stepEventsIdx(stepID)-WIN1+1:stepEventsIdx(stepID)+WIN2);
                tempThresh = max(tempSig)/1.1;
                [ tempV ,tempI ] = findpeaks(tempSig,'MinPeakDistance',20,'MinPeakHeight',tempThresh,'Annotate','extents');
                tempIndex = stepEventsIdx(stepID)-WIN1+1+tempI(1);
                % extract step
                stepSig = traceSigFilter(tempIndex-WIN1+1:tempIndex+WIN2);
                tempStepStrength = [tempStepStrength, sum(stepSig.*stepSig)];
                
                stepSig = signalNormalization(stepSig);
                [ Y, f, NFFT] = signalFreqencyExtract( stepSig, Fs );
                Y = Y(f<=cutoffFrequency);
                f = f(f<=cutoffFrequency);
                Y = signalNormalization(Y);
                medianFreq = medianFrequency(Y, f);

                tempMF = tempMF + medianFreq;
                mcount = mcount + 1;
                if plotStep == 1
                    plot(f,Y);hold on;xlim([0,90]);
                    plot([medianFreq, medianFreq],[0,0.05]);
                end
                stepSigs = [stepSigs; stepSig'];
                stepSigsLabel = [stepSigsLabel; speedCount];
                personIDLabel = [personIDLabel; personID];
                speedIDLabel = [speedIDLabel; speedID];
                traceIDLabel = [traceIDLabel; traceID];
            end
        end
        
        stepStrength(personID, speedID) = mean(tempStepStrength);
        stepStrengthStd(personID, speedID) = std(tempStepStrength);
    end
end


stepStrength(:,speedSequence)

