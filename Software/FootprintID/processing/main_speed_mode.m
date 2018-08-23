% Explore different speed modes
% PLOT mode v.s. speed
clear all
close all
clc

configuration_setup;
plotTrace = 0;
plotStep = 0;
only8 = [];
allspeed = [];
%% only 8
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
    only8 = [only8, clusterNum];
    clusterMat = zeros(clusterNum, numSpeed);

    for clusterID = 1 : clusterNum
        stepNum = length(clusters{clusterID});
        for stepID = 1 : stepNum
            clusterMat(clusterID, stepSigsLabel(clusters{clusterID}(stepID))) = ...
                clusterMat(clusterID, stepSigsLabel(clusters{clusterID}(stepID))) + 1;
        end
    end
   
end


%% all
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
    allspeed = [allspeed, clusterNum];
    clusterMat = zeros(clusterNum, numSpeed);
%     x_cluster = [];
%     y_speed = [];
    for clusterID = 1 : clusterNum
        stepNum = length(clusters{clusterID});
        for stepID = 1 : stepNum
            clusterMat(clusterID, stepSigsLabel(clusters{clusterID}(stepID))) = ...
                clusterMat(clusterID, stepSigsLabel(clusters{clusterID}(stepID))) + 1;
%             x_cluster = [x_cluster, clusterID];
%             y_speed = [y_speed, stepSigsLabel(clusters{clusterID}(stepID))];
        end
%         figure; scatter(x_cluster, y_speed);
%         figure;
%         for stepID = 1 : length(clusters{clusterID})
%             stepSig = stepSigs(clusters{clusterID}(stepID),:);
%             stepFeature = stepFeatureExtraction(stepSig, 1, 1);hold on;
%         end
%         hold off;
%         ylim([-0.4, 0.4]);
%         for stepID = 1 : length(clusters{clusterID})
%             stepSig = stepSigs(clusters{clusterID}(stepID),:);
%             stepFeature = stepFeatureExtraction(stepSig, 1, 2);hold on;
%         end
%         title(['speed ' num2str(speedID) 'cluster' num2str(clusterID)]);
    end
    
%% plot all
    figure;
    colormap('hot');
    imagesc(clusterMat);
    colorbar;
    xlabel('Speed');
    ylabel('Cluster');
    set(gca,'XtickLabel',{'-3\sigma', '-2\sigma', '-\sigma', '\mu','\sigma','2\sigma', '3\sigma','self select'});        
    title(['Person' num2str(personID)]);
    
    figure;
    subplot(2,3,1);
    stepSig = stepSigs(clusters{1}(1),:);
    plot([1:length(stepSig)]./Fs,stepSig);
    xlabel('Time (s)');
    ylabel('Amplitude');
    subplot(2,3,4);
    [ Y, f, NFFT] = signalFreqencyExtract( stepSig, Fs );
    Y = Y(f<=cutoffFrequency);
    f = f(f<=cutoffFrequency);
    Y = signalNormalization(Y);
    plot(f,Y);
    xlabel('Frequency (Hz)');
    ylabel('Amplitude');
    
    subplot(2,3,2);
    stepSig = stepSigs(clusters{2}(1),:);
    plot([1:length(stepSig)]./Fs,stepSig);
    xlabel('Time (s)');
    ylabel('Amplitude');
    subplot(2,3,5);
    [ Y, f, NFFT] = signalFreqencyExtract( stepSig, Fs );
    Y = Y(f<=cutoffFrequency);
    f = f(f<=cutoffFrequency);
    Y = signalNormalization(Y);
    plot(f,Y);
    xlabel('Frequency (Hz)');
    ylabel('Amplitude');
    
    
    subplot(2,3,3);
    stepSig = stepSigs(clusters{4}(1),:);
    plot([1:length(stepSig)]./Fs,stepSig);
    xlabel('Time (s)');
    ylabel('Amplitude');
    subplot(2,3,6);
    [ Y, f, NFFT] = signalFreqencyExtract( stepSig, Fs );
    Y = Y(f<=cutoffFrequency);
    f = f(f<=cutoffFrequency);
    Y = signalNormalization(Y);
    plot(f,Y);
    xlabel('Frequency (Hz)');
    ylabel('Amplitude');
    
    
%% plot 1 and 5 show different change activity
%     figure; 
%     if personID == 1 || personID == 5
%         if personID == 1
%             subplot(2,1,1);
%         else
%             subplot(2,1,2);
%         end
%         colormap('hot');
%         imagesc(clusterMat);
%         colorbar;
%         xlabel('speed');
%         ylabel('cluster');
%         title(['Person' num2str(personID)]);
%     end
%% plot 3 to show why single speed training is bad on him     
%     if personID == 3
%         colormap('hot');
%         imagesc(clusterMat);
%         colorbar;
%         xlabel('speed');
%         ylabel('cluster');
%         title(['Person' num2str(personID)]);
%     end
end

% only8 = [3,3,3,3,4];
% allspeed = [7,15,10,20,16];
figure;
bar([only8;allspeed]');
