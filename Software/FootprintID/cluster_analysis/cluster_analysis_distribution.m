clear all
close all
clc
load('./dataset/steps.mat');
load('./dataset/step_time_cluster_all_020.mat');
figure;imagesc(clusterSummaryTime');
title('cluster based on time domain signal cross correlation');
clusters = clustersTime;

% load('./dataset/step_freq_cluster_all');
% figure;imagesc(clusterSummaryFreq');
% title('cluster based on time domain signal cross correlation');
% clusters = clustersFreq;


% analysis each cluster distribution v.s. speed
clusterNum = length(clusters);
stepNum = length(stepIDLabel);
speedSequence = [7,6,5,1,2,3,4,8];
stepClusterID = zeros(stepNum,1);
    
for clusterID = 1:clusterNum
    % for each cluster plot 10 people

    clusterSet = clusters{clusterID};
    for clusterEleID = 1:length(clusterSet)
        eleID = clusterSet(clusterEleID);
        stepClusterID(eleID) = clusterID;
    end
end

clusterInfo = [personIDLabel, speedIDLabel, traceIDLabel, stepIDLabel, stepClusterID];
investigatedSpeedNum = 7;

%% plot cluster distribution
for clusterID = 1:clusterNum
    if length(clusters{clusterID}) <= 5
        continue;
    end
    figure;
    for personID = 1:10
        speedAve = zeros(1,investigatedSpeedNum);
        speedStd = zeros(1,investigatedSpeedNum);
        for speedID = 1:investigatedSpeedNum
            speedIdx = speedSequence(speedID);
            clusterInfoSubset = clusterInfo(clusterInfo(:,1) == personID ...
                                            & clusterInfo(:,2) == speedIdx,:);
            traceNum = max(clusterInfoSubset(:,3));
            traceClusterNum = zeros(traceNum, 1);
            for traceID = 1:traceNum
                clusterInfoSubset = clusterInfo(clusterInfo(:,1) == personID ...
                                                & clusterInfo(:,2) == speedIdx ...
                                                & clusterInfo(:,3) == traceID,:);
                traceClusterNum(traceID) = sum(clusterInfoSubset(:,5) == clusterID);
            end
            speedAve(speedID) = mean(traceClusterNum);
            speedStd(speedID) = std(traceClusterNum);
        end
        subplot(10,1,personID);
        errorbar(speedAve, speedStd);title(['person ', num2str(personID)]);
    end
end

%% evaluate number of steps in each cluster
clusterSingleSize = zeros(clusterNum,1);
for clusterID = 1:clusterNum
    clusterSingleSize(clusterID) = length(clusters{clusterID});
end