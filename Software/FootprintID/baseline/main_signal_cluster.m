%% this script is used for organize the data and cluster the steps
%% do not run it again unless the cluster criteria changes

clear 
close all
clc

init();
configuration_setup;

%% extract all steps
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
% save('./dataset/steps.mat','stepSigs','stepSigsLabel','personIDLabel','speedIDLabel','traceIDLabel',...
%     'stepIDLabel','stepIdxLabel','traceSigs','traceSigsLabel','detectedStepNum','stepPattern','stepPatternLabel');
% 
% 
% for personID = 10%1 : numPeople
%     load(['./dataset/P' num2str(personID) '.mat']);
%     load('./dataset/steps.mat');
% 
%     traceCount = 0;
%     speedCount = 0;
%     Signals = P{personID}.Sen{sensorID}.S;
% 
%     for speedID = 1:8
%         traces = Signals{speedID};
%         traceNum = size(traces,1);
%         for traceID = 1:traceNum
%             if personID == 2 && speedID == 1 && traceID == 5
%                 continue;
%             end
%             traceSig = traces{traceID,1};
%             traceSigFilter = signalDenoise(traceSig, 50);
%             MPH = max(traceSigFilter)/10;
%             if personID == 9 && speedID == 7 && traceID == 9
%                 MPH = 100;
%             elseif personID == 10 && speedID == 5 && traceID == 9
%                 MPH = MPH/2;
%             end
%             [ stepEventValue ,stepEventsIdx ] = findpeaks(traceSigFilter,'MinPeakDistance',300,'MinPeakHeight',MPH,'Annotate','extents');
%             stepFrequency = (stepEventsIdx(2:end) - stepEventsIdx(1:end-1))./Fs;
%             if personID == 4 && speedID == 2 && traceID == 2
%                 stepEventValue(1) = [];
%                 stepEventsIdx(1) = [];
%             elseif personID == 4 && speedID == 1 && traceID == 2
%                 stepEventValue(1:3) = [];
%                 stepEventsIdx(1:3) = [];
%             elseif personID == 4 && speedID == 1 && traceID == 4
%                 stepEventValue(1) = [];
%                 stepEventsIdx(1) = [];
%             elseif personID == 4 && speedID == 1 && traceID == 8
%                 stepEventValue(1) = [];
%                 stepEventsIdx(1) = [];
%             elseif personID == 6 && speedID == 7 && traceID == 9
%                 stepEventValue(1) = [];
%                 stepEventsIdx(1) = [];
%             end
%             
%             % filter out-of-range steps
%             stepEventValue = stepEventValue(stepEventsIdx > WIN1 & stepEventsIdx < length(traceSigFilter)-WIN2);
%             stepEventsIdx = stepEventsIdx(stepEventsIdx > WIN1 & stepEventsIdx < length(traceSigFilter)-WIN2);
%             detectedStepNum = [detectedStepNum; length(stepEventsIdx)];
% 
%             % select steps by energy
%             [ selectedSteps ] = stepSelectionLoc( traceSigFilter, stepEventsIdx, WIN1, WIN2 );
%             stepEventsIdx = stepEventsIdx(selectedSteps);
%             stepEventValue = stepEventValue(selectedSteps);
% 
%             figure;plot(traceSigFilter);hold on;
%             scatter(stepEventsIdx,stepEventValue);hold off;
%             title(['speed' num2str(speedID) ', trace' num2str(traceID)]);
%             
%             for stepID = 1 : length(stepEventsIdx)
%                 % find first peak
%                 tempSig = traceSigFilter(stepEventsIdx(stepID)-WIN1+1:stepEventsIdx(stepID)+WIN2);
%                 tempThresh = max(tempSig)/1.1;
%                 [ tempV ,tempI ] = findpeaks(tempSig,'MinPeakDistance',20,'MinPeakHeight',tempThresh,'Annotate','extents');
%                 tempIndex = stepEventsIdx(stepID)-WIN1+1+tempI(1);
%                 % extract step
%                 stepSig = traceSigFilter(tempIndex-WIN1+1:tempIndex+WIN2);
%                 stepSig = signalNormalization(stepSig);
% 
%                 stepSigs = [stepSigs; stepSig'];
%                 personIDLabel = [personIDLabel; personID];
%                 speedIDLabel = [speedIDLabel; speedID];
%                 traceIDLabel = [traceIDLabel; traceID];
%                 stepIDLabel = [stepIDLabel; stepID];
%                 stepIdxLabel = [stepIdxLabel; tempIndex];
% 
%                 % frequency domain
%                 [ Y, f, NFFT] = signalFreqencyExtract( stepSig, Fs );
%                 Y = Y(f<=cutoffFrequency);
%                 f = f(f<=cutoffFrequency);
%                 Y = signalNormalization(Y);
%                 stepPattern = [stepPattern; Y'];
%                 stepPatternLabel = [stepPatternLabel; personID];
% 
%             end
%         end
%     end
% end
% save('./dataset/steps.mat','stepSigs','stepSigsLabel','personIDLabel','speedIDLabel','traceIDLabel',...
%     'stepIDLabel','stepIdxLabel','traceSigs','traceSigsLabel','detectedStepNum','stepPattern','stepPatternLabel');


%% cluster the steps with time domain distance
load('./dataset/steps.mat');
stepNum = size(stepSigs,1);
[ clustersTime, nodeContainsLeave ] = stepClusteringTime( stepSigs, 0, 0.1 );
[clusterSummaryTime] = clusterVisualization(clustersTime, numPeople, speedIDLabel, personIDLabel,stepNum);
save('./dataset/step_time_cluster_all.mat','clustersTime','nodeContainsLeave','clusterSummaryTime');

figure;imagesc(clusterSummaryTime');
title('cluster based on time domain signal cross correlation');


%% cluster the steps with freq domain distance
[ clustersFreq ] = stepClusteringFreq( stepPattern, 0, 0.05  );
[clusterSummaryFreq, stepClusterID] = clusterVisualization(clustersFreq, numPeople, speedIDLabel, personIDLabel,stepNum);
save('./dataset/step_freq_cluster_all.mat','clustersFreq','clusterSummaryFreq','stepClusterID');

figure;imagesc(clusterSummaryFreq');
title('cluster based on freq domain signal correlation');


            