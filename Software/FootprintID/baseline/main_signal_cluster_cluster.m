%% based on clustered data organize the statistics of the clusters

clear 
close all
clc

init();
configuration_setup;

%% cluster the steps with time domain distance
load('./dataset/steps.mat');
load('./dataset/step_time_cluster_all_015.mat');

stepInfoAll = [personIDLabel, speedIDLabel, traceIDLabel, stepIDLabel];
clusterNum = length(clustersTime);
accuracyPerCluster = zeros(clusterNum,1);
clusterEntropy = zeros(clusterNum,1);
%% cluster analysis
for clusterID = 1:clusterNum
    clusterIdx = clustersTime{clusterID};
    clusterSigs = stepSigs(clusterIdx,:);
    clusterPatterns = stepPattern(clusterIdx,:);
    clusterInfo = stepInfoAll(clusterIdx,:);

    trainingSigIdx = [];
    testingSigIdx = [];
    for personID = 1:10
        for speedID = [1,4,7]
            psIdx = find(clusterInfo(:,1) == personID & clusterInfo(:,2) == speedSequence(speedID));
            trainingSigIdx = [trainingSigIdx; psIdx];
        end
        for speedID = [2,3,5,6]
            psIdx = find(clusterInfo(:,1) == personID & clusterInfo(:,2) == speedSequence(speedID));
            testingSigIdx = [testingSigIdx; psIdx];
        end
    end
    trainingSig = clusterSigs(trainingSigIdx,:);
    trainingPattern = clusterPatterns(trainingSigIdx,:); 
    trainingLabel = clusterInfo(trainingSigIdx,1);

    testingSig = clusterSigs(testingSigIdx,:);
    testingPattern = clusterPatterns(testingSigIdx,:);
    testingLabel = clusterInfo(testingSigIdx,1);

    %% pca 
    if ~isempty(trainingLabel) && ~isempty(testingLabel) 
        optionksrsc.normalization=1;
        optionksrsc.normMethod='unitl2norm';
        optionksrsc.SCMethod='l1nnlsAS';
        optionksrsc.lambda=0;
        optionksrsc.predicter='knn';
        optionksrsc.kernel='rbf';
        optionksrsc.param=2^0;
        optionksrsc.search=false;
        optionksrsc.ifMissValueImpute=false;

        if min(trainingLabel) > 0
            trainingLabel = trainingLabel - 1;
            testingLabel = testingLabel - 1;
        end
        [testClassPredictedKSRSC,sparse,Y,otherOutput]=KSRSCClassifier(trainingPattern',trainingLabel,testingPattern',optionksrsc);
        [performanceKSRSC, conMat]=perform(testClassPredictedKSRSC,testingLabel,10);
        accuracyPerCluster(clusterID) = performanceKSRSC(end-1);
    else
        accuracyPerCluster(clusterID) = NaN;
    end
    
    %% calculate entropy from 
    personCluster = zeros(10,1);
    for personID = 1:10
        pIdx = find(clusterInfo(:,1) == personID);
        personCluster(personID) = length(pIdx);
    end
    clusterEntropy(clusterID) = entropyFromDistribution(personCluster, 3);
end

%% plot
figure;
bar([accuracyPerCluster,clusterEntropy]);

accE1 = accuracyPerCluster(clusterEntropy <= 1);
accE2 = accuracyPerCluster(clusterEntropy > 1 & clusterEntropy <= 2);
accE3 = accuracyPerCluster(clusterEntropy > 2 );

accE1Avg = mean(accE1(~isnan(accE1)));accE1Std = std(accE1(~isnan(accE1)));
accE2Avg = mean(accE2(~isnan(accE2)));accE2Std = std(accE2(~isnan(accE2)));
accE3Avg = mean(accE3(~isnan(accE3)));accE3Std = std(accE3(~isnan(accE3)));

figure;
bar([accE1Avg,accE2Avg,accE3Avg]);hold on;
errorbar([accE1Avg,accE2Avg,accE3Avg],[accE1Std,accE2Std,accE3Std],'.');

accE{1} = accE1;accE{2} = accE2;accE{3} = accE3;
figure;aboxplot(accE);

