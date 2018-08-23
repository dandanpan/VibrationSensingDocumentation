% example of Step Events

clear all
close all
clc

configuration_setup;
plotTrace = 0;
plotStep = 0;

for personID = 1 : numPeople
    load(['./dataset/P' num2str(personID) '.mat']);
    if plotStep == 1
        figure;
    end
    stepSigs = [];
    stepSigsLabel = [];   
    personIDLabel = [];   
    speedIDLabel = [];    
    traceIDLabel = [];    
    speedCount = 0;
    for speedID = 8
        speedCount = speedCount + 1;
        Signals = P{personID}.Sen{sensorID}.S;
        traces = Signals{speedID};
        trainingTraceID = [1:5];
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
    end
    % end of a person's training data
    [clusters] = stepSelection( stepSigs, 0);
    clusterNum = length(clusters);
    clusterMat = zeros(clusterNum, numSpeed);

    for clusterID = 1 : clusterNum
        stepNum = length(clusters{clusterID});
        for stepID = 1 : stepNum
            clusterMat(clusterID, stepSigsLabel(clusters{clusterID}(stepID))) = ...
                clusterMat(clusterID, stepSigsLabel(clusters{clusterID}(stepID))) + 1;
        end
    end
   
end



