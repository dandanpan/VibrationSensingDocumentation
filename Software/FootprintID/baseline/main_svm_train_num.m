% this code generates Figure 9(a) in Ubicomp

clear all
close all
clc

init();
load('./dataset/steps.mat');
load('./dataset/step_time_cluster_all_020.mat');
load('./dataset/direction_info.mat');
load('./dataset/area_step.mat');

totalTraceID = 1:10;
selectSpeed = 4;
selectSpeed2 = 8;
totalResult = zeros(9,10);
totalResultT = zeros(9,10);
totalResultTC = zeros(9,10);
stepInfoAll = [stepInfoAll, [1:length(stepInfoAll)]'];

for trainingNum = 1:9
    for foldID = 1:10
        results = zeros(9,10);
        resultsT = zeros(9,10);
        resultsTC = zeros(9,10);
        % testing data
        trainingTraceIDR = [foldID:foldID+8];
        trainingTraceIDR(trainingTraceIDR>10) = trainingTraceIDR(trainingTraceIDR>10)-10;
        testingTraceID = totalTraceID;
        testingTraceID(ismember(totalTraceID, trainingTraceIDR)) = [];
        % training data
        trainingTraceID = [foldID:foldID+trainingNum-1];
        trainingTraceID(trainingTraceID>10) = trainingTraceID(trainingTraceID>10)-10;
        

        newPattern = [stepInfoAll(:,5), stepPattern];
        % use areaID data for training
        % and use compareAreaID data for testing
        trainingSet = [];
        trainingLabel = [];
        for personID = 1:10
            trainingAreaInfo = stepInfoAll(stepInfoAll(:,2) == selectSpeed,:);
            for traceID = 1:length(trainingTraceID)
                tIdx = trainingAreaInfo(ismember(trainingAreaInfo(:,3),trainingTraceID),7);
                tLabel = trainingAreaInfo(ismember(trainingAreaInfo(:,3),trainingTraceID),1);
                trainingSet = [trainingSet; newPattern(tIdx,:)];
                trainingLabel = [trainingLabel; tLabel];
            end
        end

        testingSet = [];
        testingLabel = [];
        for personID = 1:10
            testingAreaInfo = stepInfoAll(stepInfoAll(:,2) == selectSpeed2,:);
            for traceID = 1:length(testingTraceID)
                tIdx = testingAreaInfo(ismember(testingAreaInfo(:,3),testingTraceID),7);
                tLabel = testingAreaInfo(ismember(testingAreaInfo(:,3),testingTraceID),1);
                testingSet = [testingSet; newPattern(tIdx,:)];
                testingLabel = [testingLabel; tLabel];
            end
        end

        svmstruct = svmtrain(trainingLabel, trainingSet, ['-s 0 -t 2 -b 1 -g 1 -c 100' ]);
        [tr, ~, decision_values] = svmpredict(testingLabel, testingSet, svmstruct,'-b 1');

        %% get trace level results
        [ stepLevelAcc, traceLevelAcc, traceCLevelAcc ] = accCal( tr, testingLabel, 7 );

        results(trainingNum, foldID) = stepLevelAcc;
        resultsT(trainingNum, foldID) = traceLevelAcc;
        resultsTC(trainingNum, foldID) = traceCLevelAcc;
        
        totalResult = totalResult + results;
        totalResultT = totalResultT + resultsT;
        totalResultTC = totalResultTC + resultsTC;
    end
end

save('./dataset/train_num_compare_v4_v8.mat','totalResult','totalResultT','totalResultTC','results','resultsT','resultsTC');

% save('./dataset/train_num_compare.mat','totalResult','totalResultT','results','resultsT');
return;
%% plot comparison
load('./dataset/train_num_compare_v4_v4.mat');
traceL_v4 = mean(totalResultT,2);
traceS_v4 = std(totalResultT,[],2);

load('./dataset/train_num_compare_v4_v5.mat');
traceL_v5 = mean(totalResultT,2);
traceS_v5 = std(totalResultT,[],2);

load('./dataset/train_num_compare_v4_v6.mat');
traceL_v6 = mean(totalResultT,2);
traceS_v6 = std(totalResultT,[],2);

figure;
errorbar(traceL_v4,traceS_v4);hold on;
errorbar(traceL_v5,traceS_v5);hold off;

return;

%% Plot Figure 9(a)
load('../dataset/train_num_compare_v4_v4.mat');

stepL = mean(totalResult,2);
traceL = mean(totalResultT,2);
traceCL = mean(totalResultTC,2);
stepS = std(totalResult,[],2);
traceS = std(totalResultT,[],2);
traceCS = std(totalResultTC,[],2);

figure;
errorbar(stepL,stepS);hold on;
errorbar(traceCL,traceCS);hold on;
errorbar(traceL,traceS);hold off;


