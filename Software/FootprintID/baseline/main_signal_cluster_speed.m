clear 
close all
clc

init();
configuration_setup;

%% cluster the steps with time domain distance
load('./dataset/steps.mat');
load('./dataset/step_time_cluster_all_015.mat');

stepInfoAll = [personIDLabel, speedIDLabel, traceIDLabel, stepIDLabel];
%% find step speed
stepSpeed = zeros(length(personIDLabel),1);
for personID = 1:10
    for speedID = 1:8
        psIdx = find(stepInfoAll(:,1) == personID & stepInfoAll(:,2) == speedSequence(speedID));
        traceNum = max(stepInfoAll(psIdx,3));
        for traceID = 1:traceNum
            pstIdx = find(stepInfoAll(:,1) == personID ...
                           & stepInfoAll(:,2) == speedSequence(speedID)...
                           & stepInfoAll(:,3) == traceID);
            stepIdxSubset = stepIdxLabel(pstIdx); 
            stepIdxSubset = sort(stepIdxSubset, 'ascend');
            stepInterval = stepIdxSubset(2:end)-stepIdxSubset(1:end-1);
            medianFreq = trimmean(stepInterval,60);
            stepSpeed(pstIdx) = medianFreq/Fs;
        end
    end
end

stepSpeed = 60./stepSpeed;

%% cluster entropy analysis
clusterNum = length(clustersTime);
clusterEntropy = zeros(clusterNum,1);
for clusterID = 1:clusterNum
    clusterIdx = clustersTime{clusterID};
    clusterSigs = stepSigs(clusterIdx,:);
    clusterPatterns = stepPattern(clusterIdx,:);
    clusterInfo = stepInfoAll(clusterIdx,:);
    
    %% calculate entropy from cluster person ID directly 
%     clusterEntropy(clusterID) = entropy(clusterInfo(:,1));

    %% calculate entropy from 
    personCluster = zeros(10,1);
    for personID = 1:10
        pIdx = find(clusterInfo(:,1) == personID);
        personCluster(personID) = length(pIdx);
    end
    clusterEntropy(clusterID) = entropyFromDistribution(personCluster, 2);
    
end

figure;
subplot(2,1,1);
imagesc(clusterSummaryTime);
title('cluster based on time domain signal cross correlation');
subplot(2,1,2);
plot(clusterEntropy);

%% example
figure;
bar(clusterSummaryTime([1,4,7],:)');
