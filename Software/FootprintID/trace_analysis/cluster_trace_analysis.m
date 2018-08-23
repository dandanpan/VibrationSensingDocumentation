% clear 
% close all
% clc
% 
% init();    
% configuration_setup;
% 
% stepSigs = [];
% stepSigsLabel = [];   
% personIDLabel = [];   
% speedIDLabel = [];    
% traceIDLabel = []; 
% 
% for personID = 1 : numPeople
%     personID
%     clear P;
%     load(['./dataset/P' num2str(personID) '.mat']);
% 
%     
%     stepIdxLabel = [];
%     traceSigs = [];
%     traceSigsLabel = [];
%     traceCount = 0;
%     speedCount = 0;
%     Signals = P{personID}.Sen{sensorID}.S;
% 
%     %% self selected speed 8
%     for speedID = 1:numSpeed
%         speedID
%         traces = Signals{speedID};
%         for traceID = 1:5%size(traces,1)
%             traceID
%             
%             traceSig = traces{traceID,1};
%             traceSigFilter = signalDenoise(traceSig, 50);
% 
%             [ stepEventValue ,stepEventsIdx ] = findpeaks(traceSigFilter,'MinPeakDistance',200,'MinPeakHeight',50,'Annotate','extents');
%             stepFrequency = (stepEventsIdx(2:end) - stepEventsIdx(1:end-1))./Fs;
% 
%             % filter out-of-range steps
%             stepEventValue = stepEventValue(stepEventsIdx > WIN1 & stepEventsIdx < length(traceSigFilter)-WIN2);
%             stepEventsIdx = stepEventsIdx(stepEventsIdx > WIN1 & stepEventsIdx < length(traceSigFilter)-WIN2);
%             % select steps by energy
%             [ selectedSteps ] = stepSelectionSNR( traceSigFilter, stepEventsIdx, WIN1, WIN2, 1.5 );
%             stepEventsIdx = stepEventsIdx(selectedSteps);
%             stepEventValue = stepEventValue(selectedSteps);
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
%                 stepIdxLabel = [stepIdxLabel; tempIndex];
%             end
%         end
%     end
% end

 % end of a person's training data
% [clusters] = stepSelection( stepSigs, 0, 0.15);

% save('cluster_overall_t015.mat','clusters','stepSigs','personIDLabel','speedIDLabel','traceIDLabel','stepIdxLabel');

%%
% load('cluster_overall.mat');
clusterNum = length(clusters);
speedSequence = [7,6,5,1,2,3,4,8];
clusterSummary = zeros(numPeople*(numSpeed+1),clusterNum);
for clusterID = 1 : clusterNum
    clusterSet = clusters{clusterID};
    for clusterEleID = 1:length(clusterSet)
        eleID = clusterSet(clusterEleID);
        matchID = (personIDLabel(eleID)-1)*(numSpeed+1)+speedSequence(speedIDLabel(eleID));
        clusterSummary(matchID,clusterID) = clusterSummary(matchID,clusterID) + 1;
    end
end
clusterSummary([(numSpeed+1):(numSpeed+1):end],:) = -1;
figure;imagesc(clusterSummary');

%% extract step cluster histogram for normal walking speed
for personID = 1:numPeople
    speedID = 8;
    matchID = (personID-1)*(numSpeed+1)+speedID;
    clusterHist = clusterSummary(matchID,:);
    figure;bar(clusterHist);
    traceEntropy = entropy(clusterHist);
    title(['personID:' num2str(personID) ', entropy:' num2str(traceEntropy)]);
end

%% abstract the clusters
% for clusterID = 1 : clusterNum
%     stepNum = length(clusters{clusterID});
%     % signal not aligned by the shape 
%     % therefore only look at the frequency domain for the first level
%     % clustering
% 
%     %% check the shift error
%     whiteList = [];
%     if stepNum > 4
%         for i = 1 : stepNum
%             for j = i+1 : stepNum
%                 stepIdx1 = clusters{clusterID}(i);
%                 stepSig1 = stepSigs(stepIdx1,:);
%                 stepIdx2 = clusters{clusterID}(j);
%                 stepSig2 = stepSigs(stepIdx2,:);
%                 stepSig1 = signalNormalization(stepSig1);
%                 stepSig2 = signalNormalization(stepSig2);
%                 [temp, shift] = max((xcorr(stepSig1,stepSig2)));
%                 if abs(shift-400) < 2
%                     whiteList = [whiteList, i,j];
%                 end      
%             end
%         end
%     else
%         whiteList = 1;
%     end
%     whiteList = unique(whiteList);
%     stepSigWhiteIdx = clusters{clusterID}(whiteList(1));
%     stepSigWhite = stepSigs(stepSigWhiteIdx,:);
%     stepSigWhite = signalNormalization(stepSigWhite);
%     blackList = [1 : stepNum];
%     blackList(blackList == whiteList(1)) = [];
%     for bidx = 1 : length(blackList) 
%         blackNum = blackList(bidx);
%         stepIdxInCluster = clusters{clusterID}(blackNum);
%         stepSigBlack = stepSigs(stepIdxInCluster,:);
%         stepSigBlack = signalNormalization(stepSigBlack);
%         [temp, shift] = max((xcorr(stepSigWhite,stepSigBlack)));
%         if abs(shift-400) > 2
%            a = 0; 
%         end
%         traceSig = Signals{speedIDLabel(stepIdxInCluster)}{traceIDLabel(stepIdxInCluster),1};
%         traceSigFilter = signalDenoise(traceSig, 50);
%         offset = shift - 400;
%         tempSig = traceSigFilter(stepIdxLabel(stepIdxInCluster) - offset - WIN1+1 : ...
%                                 stepIdxLabel(stepIdxInCluster) - offset + WIN2); 
%         stepSigs(stepIdxInCluster,:) = signalNormalization(tempSig);
%     end
% 
%     %% within a cluster processing
%     stepFCluster = [];
%     for stepID = 1 : stepNum
%         % feature extraction
%         stepIdx = clusters{clusterID}(stepID);
%         stepSig = stepSigs(stepIdx,:);
% 
%         % frequency domain
%         [ Y, f, NFFT] = signalFreqencyExtract( stepSig, Fs );
%         Y = Y(f<=cutoffFrequency);
%         f = f(f<=cutoffFrequency);
%         Y = signalNormalization(Y);
%         stepFCluster = [stepFCluster; Y];
%     end
%     clusterCharacter{personID, clusterID} = mean(stepFCluster);
% %         figure; plot(clusterCharacter{personID, clusterID});
% end

%%



