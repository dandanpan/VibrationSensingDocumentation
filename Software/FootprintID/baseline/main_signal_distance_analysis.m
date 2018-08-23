clear 
close all
clc

init();
configuration_setup;

% stepPatternLabel = [];
% stepPattern = [];
% stepSigs = [];
% stepSigsLabel = [];   
% personIDLabel = [];   
% speedIDLabel = [];    
% traceIDLabel = []; 
% stepIDLabel = [];
% stepIdxLabel = [];
% traceSigs = [];
% traceSigsLabel = [];
% detectedStepNum = [];
%     
% for personID = 1 : numPeople
%     load(['./dataset/P' num2str(personID) '.mat']);
% 
%     traceCount = 0;
%     speedCount = 0;
%     Signals = P{personID}.Sen{sensorID}.S;
% 
%     speedID = 8;
%     traces = Signals{speedID};
%     traceNum = size(traces,1);
%     for traceID = 1:traceNum
%         traceSig = traces{traceID,1};
%         traceSigFilter = signalDenoise(traceSig, 50);
%         MPH = max(traceSigFilter)/10;
%         [ stepEventValue ,stepEventsIdx ] = findpeaks(traceSigFilter,'MinPeakDistance',200,'MinPeakHeight',MPH,'Annotate','extents');
%         stepFrequency = (stepEventsIdx(2:end) - stepEventsIdx(1:end-1))./Fs;
% 
%         % filter out-of-range steps
%         stepEventValue = stepEventValue(stepEventsIdx > WIN1 & stepEventsIdx < length(traceSigFilter)-WIN2);
%         stepEventsIdx = stepEventsIdx(stepEventsIdx > WIN1 & stepEventsIdx < length(traceSigFilter)-WIN2);
%         detectedStepNum = [detectedStepNum; length(stepEventsIdx)];
%         
%         % select steps by energy
%         [ selectedSteps ] = stepSelectionLoc( traceSigFilter, stepEventsIdx, WIN1, WIN2 );
%         stepEventsIdx = stepEventsIdx(selectedSteps);
%         stepEventValue = stepEventValue(selectedSteps);
% 
%         for stepID = 1 : length(stepEventsIdx)
%             % find first peak
%             tempSig = traceSigFilter(stepEventsIdx(stepID)-WIN1+1:stepEventsIdx(stepID)+WIN2);
%             tempThresh = max(tempSig)/1.1;
%             [ tempV ,tempI ] = findpeaks(tempSig,'MinPeakDistance',20,'MinPeakHeight',tempThresh,'Annotate','extents');
%             tempIndex = stepEventsIdx(stepID)-WIN1+1+tempI(1);
%             % extract step
%             stepSig = traceSigFilter(tempIndex-WIN1+1:tempIndex+WIN2);
%             stepSig = signalNormalization(stepSig);
% 
%             stepSigs = [stepSigs; stepSig'];
%             personIDLabel = [personIDLabel; personID];
%             speedIDLabel = [speedIDLabel; speedID];
%             traceIDLabel = [traceIDLabel; traceID];
%             stepIDLabel = [stepIDLabel; stepID];
%             stepIdxLabel = [stepIdxLabel; tempIndex];
% 
%             % frequency domain
%             [ Y, f, NFFT] = signalFreqencyExtract( stepSig, Fs );
%             Y = Y(f<=cutoffFrequency);
%             f = f(f<=cutoffFrequency);
%             Y = signalNormalization(Y);
%             stepPattern = [stepPattern; Y'];
%             stepPatternLabel = [stepPatternLabel; personID];
% 
%         end
%     end
% end


load('./dataset/steps.mat');
%% cluster the steps with time domain distance
stepNum = size(stepSigs,1);
[ clustersTime, nodeContainsLeave ] = stepClusteringTime( stepSigs, 0, 0.2 );
[ clusterSummaryTime ] = clusterVisualization(clustersTime, numPeople, speedIDLabel, personIDLabel,stepNum);
figure;imagesc(clusterSummaryTime');
title('cluster based on time domain signal cross correlation');
save('./dataset/step_time_cluster_all.mat','clustersTime','nodeContainsLeave','clusterSummaryTime');

%% cluster the steps with freq domain distance
[ clustersFreq ] = stepClusteringFreq( stepPattern, 0, 0.1  );
[ clusterSummaryFreq, stepClusterID ] = clusterVisualization(clustersFreq, numPeople, speedIDLabel, personIDLabel,stepNum);
figure;imagesc(clusterSummaryFreq');
title('cluster based on freq domain signal correlation');

%% based on the direction, extract steps within the same area and use the same criteria to cluster
load('./dataset/direction_info.mat');
stepIdxInfo = [personIDLabel, speedIDLabel, traceIDLabel, stepIDLabel];
% area1: closer to the sensor3
% area2: central area
% area3: closer to the sensor7
idxA1 = [];
idxA2 = [];
idxA3 = [];

speedID = 8;
for personID = 1 : numPeople
    traceNum = max(stepIdxInfo(stepIdxInfo(:,1) == personID,3));
    for traceID = 1:traceNum
        direction = directionInfo(directionInfo(:,1) == personID & directionInfo(:,2) == speedID & directionInfo(:,3) == traceID,4);
        if direction == 1
            stepSigA1Idx = find(stepIdxInfo(:,1) == personID & stepIdxInfo(:,3) == traceID...
                                & (stepIdxInfo(:,4) == 1 | stepIdxInfo(:,4) == 2 | stepIdxInfo(:,4) == 3)); 
            stepSigA2Idx = find(stepIdxInfo(:,1) == personID & stepIdxInfo(:,3) == traceID...
                                & (stepIdxInfo(:,4) == 3 | stepIdxInfo(:,4) == 4 | stepIdxInfo(:,4) == 5)); 
            stepSigA3Idx = find(stepIdxInfo(:,1) == personID & stepIdxInfo(:,3) == traceID...
                                & (stepIdxInfo(:,4) == 5 | stepIdxInfo(:,4) == 6 | stepIdxInfo(:,4) == 7));
        else
            stepSigA3Idx = find(stepIdxInfo(:,1) == personID & stepIdxInfo(:,3) == traceID...
                                & (stepIdxInfo(:,4) == 1 | stepIdxInfo(:,4) == 2 | stepIdxInfo(:,4) == 3)); 
            stepSigA2Idx = find(stepIdxInfo(:,1) == personID & stepIdxInfo(:,3) == traceID...
                                & (stepIdxInfo(:,4) == 3 | stepIdxInfo(:,4) == 4 | stepIdxInfo(:,4) == 5)); 
            stepSigA1Idx = find(stepIdxInfo(:,1) == personID & stepIdxInfo(:,3) == traceID...
                                & (stepIdxInfo(:,4) == 5 | stepIdxInfo(:,4) == 6 | stepIdxInfo(:,4) == 7));
        end
        idxA1 = [idxA1; stepSigA1Idx];
        idxA2 = [idxA2; stepSigA2Idx];
        idxA3 = [idxA3; stepSigA3Idx];
    end
end
stepSigA1 = stepSigs(idxA1,:);
stepSigA2 = stepSigs(idxA2,:);
stepSigA3 = stepSigs(idxA3,:);

stepPatternA1 = stepPattern(idxA1,:);
stepPatternA2 = stepPattern(idxA2,:);
stepPatternA3 = stepPattern(idxA3,:);

%% different areas signal freq pattern clustering
[ clustersFreqA1 ] = stepClusteringFreq( stepPatternA1, 0, 0.05  );
[clusterSummaryFreq] = clusterVisualization(clustersFreqA1, numPeople, speedIDLabel(idxA1), personIDLabel(idxA1),length(idxA1));
figure;imagesc(clusterSummaryFreq');
title('cluster based on freq domain signal correlation A1');

[ clustersFreqA2 ] = stepClusteringFreq( stepPatternA2, 0, 0.05  );
[clusterSummaryFreq] = clusterVisualization(clustersFreqA2, numPeople, speedIDLabel(idxA2), personIDLabel(idxA2),length(idxA2));
figure;imagesc(clusterSummaryFreq');
title('cluster based on freq domain signal correlation A2');

[ clustersFreqA3 ] = stepClusteringFreq( stepPatternA3, 0, 0.05  );
[clusterSummaryFreq] = clusterVisualization(clustersFreqA3, numPeople, speedIDLabel(idxA3), personIDLabel(idxA3),length(idxA3));
figure;imagesc(clusterSummaryFreq');
title('cluster based on freq domain signal correlation A3');

%% classification by different area?
stepResultsA1M0 = crossValidationSVM( stepPatternA1, stepIdxInfo(idxA1,:), 0 );
stepResultsA1M1 = crossValidationSVM( stepPatternA1, stepIdxInfo(idxA1,:), 1 );
stepResultsA1M2 = crossValidationSVM( stepPatternA1, stepIdxInfo(idxA1,:), 2 );

stepResultsA2M2 = crossValidationSVM( stepPatternA2, stepIdxInfo(idxA2,:), 2 );
stepResultsA3M2 = crossValidationSVM( stepPatternA3, stepIdxInfo(idxA3,:), 2 );

mean(stepResultsA1M2)
mean(stepResultsA2M2)
mean(stepResultsA3M2)

%% classification result and the cluster results comparison
[ avgSimilarityA1 ] = stepSimilarityEvaluation( stepPatternA1, stepIdxInfo(idxA1,:) );
[ avgSimilarityA2 ] = stepSimilarityEvaluation( stepPatternA2, stepIdxInfo(idxA2,:) );
[ avgSimilarityA3 ] = stepSimilarityEvaluation( stepPatternA3, stepIdxInfo(idxA3,:) );

mean(avgSimilarityA1)
mean(avgSimilarityA2)
mean(avgSimilarityA3)

%% 

            