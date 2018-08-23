%% this script is used to organize the step.mat metadata

clear 
close all
clc

init();
configuration_setup;

%% cluster the steps with time domain distance
load('./dataset/steps.mat');
load('./dataset/step_time_cluster_all_020.mat');

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

stepInfoAll = [stepInfoAll, stepSpeed];

%% find step cluster
stepCluster = zeros(length(personIDLabel),1);
totalCount = 0;
clusterSizes = [];
for clusterID = 1:length(clustersTime)
    stepCluster(clustersTime{clusterID}) = clusterID;
    totalCount = totalCount + length(clustersTime{clusterID});
    clusterSizes = [clusterSizes, length(clustersTime{clusterID})];
end

stepInfoAll = [stepInfoAll, stepCluster];
save('./dataset/steps.mat','stepSigs','stepSigsLabel','personIDLabel','speedIDLabel','traceIDLabel',...
    'stepIDLabel','stepIdxLabel','traceSigs','traceSigsLabel','detectedStepNum','stepPattern','stepPatternLabel','stepInfoAll');

%% one cluster analysis
clusterID = 6;
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

feMethod='ksrdl';
feOption.facts=4;
optionKSRDL.lambda=0.1;
optionKSRDL.SCMethod='nnqpAS'; % can be nnqpAS, l1qpAS, nnqpIP, l1qpIP, l1qpPX, nnqpSMO, l1qpSMO
optionKSRDL.dicPrior='uniform'; % can be uniform, Gaussian
optionKSRDL.kernel='rbf';
optionKSRDL.param=2^0;
optionKSRDL.iter=100;
optionKSRDL.dis=0;
optionKSRDL.residual=1e-4;
optionKSRDL.tof=1e-4;
feOption.option=optionKSRDL;

[trainExtr,outTrain]=featureExtractionTrain(trainingPattern',trainingLabel,feMethod,feOption);
[testExtr,outTest]=featureExtrationTest(testingPattern',outTrain);

figure;
for personID = 1:10
    trainingIdx = find(trainingLabel == personID);
%     scatter(trainExtr(1,trainingIdx),trainExtr(2,trainingIdx));hold on;
    scatter3(trainExtr(1,trainingIdx),trainExtr(2,trainingIdx),trainExtr(3,trainingIdx));hold on;
end
hold off;

%% SC
optionKSRSC.SCMethod='nnqpAS';
optionKSRSC.lambda=0;
optionKSRSC.predicter='knn';
optionKSRSC.k = 10;
optionKSRSC.kernel='rbf';
optionKSRSC.param=2^0;
if min(trainingLabel) > 0
    trainingLabel = trainingLabel - 1;
    testingLabel = testingLabel - 1;
end
[testClassPredictedKSRSC,sparse,Y,otherOutput]=KSRSCClassifier(trainingPattern',trainingLabel,testingPattern',optionKSRSC);
[performanceKSRSC, conMat]=perform(testClassPredictedKSRSC,testingLabel,10);
performanceKSRSC
conMat
return;

%% Use multiClassifier
optionksrsc.normalization = 1;
optionksrsc.normMethod='unitl2norm';
optionksrsc.SCMethod='l1nnlsAS';
optionksrsc.lambda=0;
optionksrsc.predicter='knn';
optionksrsc.kernel='rbf';
optionksrsc.param=2^0;
optionksrsc.search=false;
optionksrsc.ifMissValueImpute=false;

% numMetasample=5;
% optionsubdic.normalization=1;
% optionsubdic.normMethod='unitl2norm';
% optionsubdic.metaSampleMethod='svd'; % svd or nmf or vsmf
% optionsubdic.ks=numMetasample*ones(10,1); % Colon: 3, Leukemia2: 5, Adenoma: 4, SRBCT: 5
% optionsubdic.ifModelSelection=false;
% optionsubdic.alpha2=0;
% optionsubdic.alpha1=0;
% optionsubdic.lambda2=0;
% optionsubdic.lambda1=0; % lambda for matrix factorization
% optionsubdic.t1=true;
% optionsubdic.t2=true;
% optionsubdic.kernelizeAY=0;
% optionsubdic.method='pca';
% optionsubdic.kernel='linear';
% optionsubdic.SCMethod='l1lsAS';
% optionsubdic.lambda=2^-3; % lambda for sparse coding
% optionsubdic.predictor='ns';

methods={'ksrsc'};%;'subdic'};
options={optionksrsc};%;optionsubdic};
[testClassPredicteds,classPerforms,conMats,tElapseds,OtherOutputs]=multiClassifiers(trainingPattern',trainingLabel,testingPattern',testingLabel,methods,options);
classPerforms
[testClassPredicteds, testingLabel]
