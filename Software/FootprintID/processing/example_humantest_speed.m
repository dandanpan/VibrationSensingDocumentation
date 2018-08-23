clear all
close all
clc

Fs = 1000;
WIN1 = 100;
WIN2 = 300;
numSpeed = 8;
numPeople = 5;
sensorID = 7;
personID = 1;
medianFrequencySet = zeros(numSpeed,numPeople);
stepFrequencySet = zeros(numSpeed,numPeople);
plotEach = 12;
numCA = 2;
%% select sensor 5 P1 frequency domain
% figure;
% for personID = 1 : numPeople
%     load(['../dataset/P' num2str(personID) '.mat']);
%     Signals = P{personID}.Sen{sensorID}.S;
%     speedSequence = [7,6,5,1,2,3,4,8];
%     for speedID = 1 : numSpeed
%         fprintf(['num people' num2str(personID) ' num speed' num2str(speedID) '\n']);
%         if plotEach == 1
%             subplot(numPeople,numSpeed,(personID-1)*numSpeed+speedID);
%         end
%         traces = Signals{speedSequence(speedID)};
%         for traceID = 1 : length(traces)
%             traceSig = traces{traceID,1};
%             traceSigFilter = signalDenoise(traceSig, 50);
%             [ stepEventValue ,stepEventsIdx ] = findpeaks(traceSigFilter,'MinPeakDistance',200,'MinPeakHeight',50,'Annotate','extents');
%              stepFrequency = (stepEventsIdx(2:end) - stepEventsIdx(1:end-1))./Fs;
%             [ selectedSteps ] = stepSelection( traceSigFilter, stepEventsIdx, WIN1, WIN2, 3 );
%             stepEventsIdx = stepEventsIdx(selectedSteps);
%             stepEventValue = stepEventValue(selectedSteps);
%             tempMF = 0;
%             mcount = 0;
%             for stepID = 1 : length(stepEventsIdx)
%                 % find first peak
%                 tempSig = traceSigFilter(stepEventsIdx(stepID)-WIN1+1:stepEventsIdx(stepID)+WIN2);
%                 tempThresh = max(tempSig)/2;
%                 [ tempV ,tempI ] = findpeaks(tempSig,'MinPeakDistance',20,'MinPeakHeight',tempThresh,'Annotate','extents');
%                 tempIndex = stepEventsIdx(stepID)-WIN1+1+tempI(1);
%                 % extract step
%                 stepSig = traceSigFilter(tempIndex-WIN1+1:tempIndex+WIN2);
%                 stepSig = signalNormalization(stepSig);
%                 [ Y, f, NFFT] = signalFreqencyExtract( stepSig, Fs );
%                 medianFreq = medianFrequency(Y, f);
%                 tempMF = tempMF + medianFreq;
%                 mcount = mcount + 1;
%                 if plotEach == 1
%                     %% plot time 
% %                     plot(stepSig);hold on;
%                     %% plot frequency
%                     plot(f,Y);hold on;xlim([0,90]);
%                     plot([medianFreq, medianFreq],[0,0.05]);
%                 else
%                     stepFeatureExtraction(stepSig);
%                 end
%             end
%             medianFrequencySet(speedID, personID) = medianFrequencySet(speedID, personID) + tempMF;
%             stepFrequency = stepFrequency(stepFrequency<1);
%             stepFrequencySet(speedID, personID) = mean(stepFrequency);
%     %         figure; plot(traceSigFilter);hold on;
%     %         for stepID = 1 : length(stepEventsIdx)
%     %             scatter(stepEventsIdx(stepID),stepEventValue(stepID),'rV');
%     %             plot([stepEventsIdx(stepID)-WIN1, stepEventsIdx(stepID)-WIN1],[-100,100],'r');
%     %             plot([stepEventsIdx(stepID)+WIN2, stepEventsIdx(stepID)+WIN2],[-100,100],'g');
%     %         end
%     %         hold off;
% 
%     %         figure;
%     %         plot(traceSig);hold on;
%     %         traceSigFilter = signalDenoise(traceSig, 50);
%     %         plot(traceSigFilter);hold off;
% 
%         end
%         hold off;
%         title(['personID' num2str(personID) 'speedID' num2str(speedID)]);
% 
%         medianFrequencySet(speedID, personID) = medianFrequencySet(speedID, personID)/length(traces);
%     %     xlim([0,80]);
%     end
% end

%% select sensor 5 P1 time domain
figure;
for personID = 1 : numPeople
    load(['./dataset/P' num2str(personID) '.mat']);
    Signals = P{personID}.Sen{sensorID}.S;
    speedSequence = [7,6,5,1,2,3,4,8];
    for speedID = 1 : numSpeed
        fprintf(['num people' num2str(personID) ' num speed' num2str(speedID) '\n']);
        if plotEach == 1 
            subplot(numPeople,numSpeed,(personID-1)*numSpeed+speedID);
        end
        traces = Signals{speedSequence(speedID)};
        numTrace = length(traces);
        figure;
        for traceID = 1 : numTrace
            traceSig = traces{traceID,1};
            traceSigFilter = signalDenoise(traceSig, 50);
            [ stepEventValue ,stepEventsIdx ] = findpeaks(traceSigFilter,'MinPeakDistance',200,'MinPeakHeight',50,'Annotate','extents');
             stepFrequency = (stepEventsIdx(2:end) - stepEventsIdx(1:end-1))./Fs;
            [ selectedSteps ] = stepSelectionSNR( traceSigFilter, stepEventsIdx, WIN1, WIN2, 4 );
            stepEventsIdx = stepEventsIdx(selectedSteps);
            stepEventValue = stepEventValue(selectedSteps);
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
                medianFreq = medianFrequency(Y, f);
                tempMF = tempMF + medianFreq;
                mcount = mcount + 1;
                if plotEach == 1
                    %% plot time 
                    plot(stepSig);hold on;
                    %% plot frequency
%                     plot(f,Y);hold on;xlim([0,90]);
%                     plot([medianFreq, medianFreq],[0,0.05]);
                elseif plotEach == 0
                    stepFeatureExtraction(stepSig);
                end
            end
%             figure; 
%             plot(pcaSig);
%             
            [coeff,score,latent] = pca(pcaSig,'NumComponents',numCA);
%             figure;
            for ca = 1 : numCA
                subplot(numTrace,numCA,(traceID-1)*numCA+ca);
                plot(score(:,ca));
                title(['personID' num2str(personID) 'speedID' num2str(speedID)]);
            end
            
            %% EMD
%             addpath('./emd');
%             imf = emd(pcaSig);
            
            medianFrequencySet(speedID, personID) = medianFrequencySet(speedID, personID) + tempMF;
            stepFrequency = stepFrequency(stepFrequency<1);
            stepFrequencySet(speedID, personID) = mean(stepFrequency);
    %         figure; plot(traceSigFilter);hold on;
    %         for stepID = 1 : length(stepEventsIdx)
    %             scatter(stepEventsIdx(stepID),stepEventValue(stepID),'rV');
    %             plot([stepEventsIdx(stepID)-WIN1, stepEventsIdx(stepID)-WIN1],[-100,100],'r');
    %             plot([stepEventsIdx(stepID)+WIN2, stepEventsIdx(stepID)+WIN2],[-100,100],'g');
    %         end
    %         hold off;

    %         figure;
    %         plot(traceSig);hold on;
    %         traceSigFilter = signalDenoise(traceSig, 50);
    %         plot(traceSigFilter);hold off;

        end
%         hold off;
%         title(['personID' num2str(personID) 'speedID' num2str(speedID)]);

        medianFrequencySet(speedID, personID) = medianFrequencySet(speedID, personID)/length(traces);
    %     xlim([0,80]);
    end
end