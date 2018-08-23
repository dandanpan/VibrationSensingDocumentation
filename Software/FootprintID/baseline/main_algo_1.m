clear all
close all
clc

init();
configuration_setup;

% load data
load('./dataset/steps.mat');
load('./dataset/step_time_cluster_all_020.mat');
load('./dataset/direction_info.mat');

%% separate training data and testing data
trainingSpeedID = [1,4,7];
for trainingTraceStartIdx = 1:9
    trainingIdx{trainingTraceStartIdx} = [];
    testingIdx{trainingTraceStartIdx} = [];
    for personID = 1:10
        for speedID = 1:8
            psIdx = find(stepInfoAll(:,1) == personID & stepInfoAll(:,2) == speedSequence(speedID));
            traceNum = max(stepInfoAll(psIdx,3));
            trainingTraceIdx = trainingTraceStartIdx:trainingTraceStartIdx+4;
            trainingTraceIdx(trainingTraceIdx>traceNum) = trainingTraceIdx(trainingTraceIdx>traceNum)-traceNum;
            testingTraceIdx = 1:traceNum;
            testingTraceIdx(ismember(testingTraceIdx, trainingTraceIdx)) = [];
            pstIdxTraining = [];
            if ismember(speedID,trainingSpeedID)
                for i = 1:length(trainingTraceIdx)
                    pstIdx = find(stepInfoAll(:,1) == personID & stepInfoAll(:,2) == speedSequence(speedID) & stepInfoAll(:,3) == trainingTraceIdx(i));
%                     if length(pstIdx)~= 7
%                         personID
%                         speedID
%                         length(pstIdx)
%                         trainingTraceIdx(i)
%                     end
                    
                    pstIdxTraining = [pstIdxTraining; pstIdx];
                end
            end
            pstIdxTesting = [];
            for i = 1:length(testingTraceIdx)
                pstIdx = find(stepInfoAll(:,1) == personID & stepInfoAll(:,2) == speedSequence(speedID) & stepInfoAll(:,3) == testingTraceIdx(i));
                pstIdxTesting = [pstIdxTesting; pstIdx];
            end
            trainingIdx{trainingTraceStartIdx} = [trainingIdx{trainingTraceStartIdx}; pstIdxTraining];
            testingIdx{trainingTraceStartIdx} = [testingIdx{trainingTraceStartIdx}; pstIdxTesting];
        end
    end
end

%%

%% train the model with the training data
% cluster the training idx
for iterationID = 1%:9
    [acc{iterationID} , mIdx, clusterPattern, clusterEntropy, tIdx, clusterSubset, clusterHistogram] = algo2Eva(stepSigs, stepPattern, stepInfoAll, trainingIdx{iterationID}, trainingSpeedID, testingIdx{iterationID}, length(clustersTime));
end
