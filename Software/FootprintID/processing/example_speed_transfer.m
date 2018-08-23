clear all
close all
clc

% init();
speedSequence = [7,6,5,1,2,3,4];
Fs = 1000;
WIN1 = 100;
WIN2 = 300;
numSpeed = 7;
numPeople = 5;
sensorID = 5;
cutoffFrequency = 200;
medianFrequencySet = zeros(numSpeed,numPeople);
stepFrequencySet = zeros(numSpeed,numPeople);
plotEach = 1;
performStepSelection = 1;

load(['./dataset/P5.mat']);
personID = 5;
Signals = P{personID}.Sen{sensorID}.S;
figure;
for speedID = 1 : numSpeed
    fprintf(['num people' num2str(personID) ' num speed' num2str(speedID) '\n']);
    subplot(1,numSpeed,speedID);
    traces = Signals{speedSequence(speedID)};
    numTrace = length(traces);
    for traceID = 1 : numTrace
        traceSig = traces{traceID,1};
        traceSigFilter = signalDenoise(traceSig, 50);
        [ stepEventValue ,stepEventsIdx ] = findpeaks(traceSigFilter(WIN1+1:end-WIN2*2),'MinPeakDistance',200,'MinPeakHeight',50,'Annotate','extents');
         stepFrequency = (stepEventsIdx(2:end) - stepEventsIdx(1:end-1))./Fs;
        if performStepSelection == 1
            [ selectedSteps ] = stepSelectionSNR( traceSigFilter, stepEventsIdx, WIN1, WIN2, 4 );
            stepEventsIdx = stepEventsIdx(selectedSteps);
            stepEventValue = stepEventValue(selectedSteps);
        elseif performStepSelection == 2
            [ selectedSteps ] = stepSelectionSNR( traceSigFilter, stepEventsIdx, WIN1, WIN2, 2 );
            stepEventsIdx = stepEventsIdx(selectedSteps);
            stepEventValue = stepEventValue(selectedSteps);
        end
        tempMF = 0;
        mcount = 0;

        %% PCA
        pcaSig = [];
        for stepID = 1 : length(stepEventsIdx)
            % find first peak
            tempSig = traceSigFilter(stepEventsIdx(stepID)-WIN1+1:stepEventsIdx(stepID)+WIN2);
            tempThresh = max(tempSig)/3;
            [ tempV ,tempI ] = findpeaks(tempSig,'MinPeakDistance',20,'MinPeakHeight',tempThresh,'Annotate','extents');
            tempIndex = stepEventsIdx(stepID)-WIN1+1+tempI(1);
            % extract step
            stepSig = traceSigFilter(tempIndex-WIN1+1:tempIndex+WIN2);
            stepSig = signalNormalization(stepSig);
            pcaSig = [pcaSig stepSig];
            [ Y, f, NFFT] = signalFreqencyExtract( stepSig, Fs );
            Y = Y(f<=cutoffFrequency);
            f = f(f<=cutoffFrequency);
            Y = signalNormalization(Y);
            medianFreq = medianFrequency(Y, f);
            
            tempMF = tempMF + medianFreq;
            mcount = mcount + 1;
            if plotEach == 1
                %% plot time 
%                 plot(stepSig);hold on;
                %% plot frequency
                plot(f,Y);hold on;
                plot([medianFreq, medianFreq],[0,0.5]);
            elseif plotEach == 0
                stepFeatureExtraction(stepSig);
            end
        end 
        hold off;
        
        medianFrequencySet(speedID, personID) = medianFrequencySet(speedID, personID) + tempMF;
        stepFrequency = stepFrequency(stepFrequency<1);
        stepFrequencySet(speedID, personID) = mean(stepFrequency);
%         figure; plot(traceSigFilter);hold on;
%         for stepID = 1 : length(stepEventsIdx)
%             scatter(stepEventsIdx(stepID),stepEventValue(stepID),'rV');
%             plot([stepEventsIdx(stepID)-WIN1, stepEventsIdx(stepID)-WIN1],[-100,100],'r');
%             plot([stepEventsIdx(stepID)+WIN2, stepEventsIdx(stepID)+WIN2],[-100,100],'g');
%         end

%         figure;
%         plot(traceSig);hold on;
%         traceSigFilter = signalDenoise(traceSig, 50);
%         plot(traceSigFilter);hold off;

    end
end
    



