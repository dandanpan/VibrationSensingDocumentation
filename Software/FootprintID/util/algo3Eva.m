function [ accuracy, mIdx, clusterPattern, clusterEntropy, tIdx, clusterSubset, clusterHistogram ] = algo3Eva( stepSigs, stepPattern, stepInfoAll, trainingIdx, trainingSpeedID, testingIdx, clusterNum )
%   method: trace level use cluster
%           step level still use svm
%   INPUT:
%   stepSigs: time domain signals
%   stepPattern: freq domain signals
%   stepInfoAll: personID, speedID, traceID, stepID, stepFreq, clusterID
%   trainingIdx/testingIdx: for cross validation
%   clusterNum: total number of cluster

%   OUTPUT: accuracy
    % training options
    addpath('./libsvm-master/');
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
    
    % variables
    clusterPattern = -1;
    clusterEntropy = -1;
    accuracy = 0;
    speedSequence = [7,6,5,1,2,3,4,8];
    
%     % normalize
    stepPatternNum = size(stepPattern, 2);
    for patternID = 1:stepPatternNum
        patternVal = stepPattern(:,patternID);
        stepPattern(:,patternID) = stepPattern(:,patternID) - min(patternVal);
        stepPattern(:,patternID) = stepPattern(:,patternID) / (max(patternVal)-min(patternVal));
    end
    
    % organize training testing data
    trainingSigs = stepSigs(trainingIdx,:);
    trainingPatterns = stepPattern(trainingIdx,:);
    trainingLabels = stepInfoAll(trainingIdx,1);
    trainingInfo = stepInfoAll(trainingIdx, :);
    
    testingSigs = stepSigs(testingIdx,:);
    testingPatterns = stepPattern(testingIdx,:);
    testingLabels = stepInfoAll(testingIdx,1);
    testingInfo = stepInfoAll(testingIdx, :);
    
    %% training
    % for each speed/cluster in training data, train a model
    speedTrainer = cell(8,1);
    speedTrainerLabel = cell(8,1);
    for speedID = trainingSpeedID
        speedID
        mIdx{speedID} = find(trainingInfo(:,2) == speedSequence( speedID ));
        if ~isempty( mIdx{speedID})
            speedTrainer{speedID} = trainingPatterns( mIdx{speedID}, : );
            speedTrainerLabel{speedID} = trainingInfo( mIdx{speedID}, 1 ) ;
            svmstruct{speedID} = svmtrain(speedTrainerLabel{speedID}, speedTrainer{speedID}, ['-s 0 -t 2 -b 1 -g 1 -c 100' ]);
        end  
    end
    svmstructAll = svmtrain(trainingInfo(:,1), trainingPatterns, ['-s 0 -t 2 -b 1 -g 1 -c 100' ]);
    % extract each person's histogram based on speed
    speedPerson = zeros(8,10);
    for speedID = trainingSpeedID
        clusterSubsetPerSpeed{speedID} = [];
        for personID = 1:10
            tIdx{speedID, personID} = find(trainingInfo(:,2) == speedSequence(speedID) & trainingInfo(:,1) == personID);
            speedPerson(speedID, personID) = mean(trainingInfo(tIdx{speedID, personID},5));
            clusterSubset = trainingInfo(tIdx{speedID, personID},6);
            clusterSubsetPerSpeed{speedID} = [clusterSubsetPerSpeed{speedID}; clusterSubset(clusterSubset>0)];
            clusterHistogram{speedID, personID} = myBin(clusterSubset(clusterSubset>0), clusterNum);
        end
        clusterSubsetPerSpeed{speedID} = unique(clusterSubsetPerSpeed{speedID});
    end
    avgSpeed = mean(speedPerson, 2);
    
    %% testing
    % 1. based on histogram -- speed, select candidates
    % 2. cluster each step
    % 3. using model trained for each speed to id each step, entropy as
    % weight
    
    %% histogram based
    testingHistogram = [];
    testingSpeed = [];
    testingHistogramLabel = [];
    for personID = 1:10
        for speedID = 1:8
            % find the testing trace ID set
            ttIdx{speedID, personID} = find(testingInfo(:,2) == speedSequence(speedID) & testingInfo(:,1) == personID);
            traceIDSubset = testingInfo(ttIdx{speedID, personID},3);
            traceIDSet = unique(traceIDSubset);
            for traceID = 1:numel(traceIDSet)
                pstIdx = find(testingInfo(:,2) == speedSequence(speedID) & testingInfo(:,1) == personID & testingInfo(:,3) == traceIDSet(traceID));
                clusterComponents = testingInfo(pstIdx,6);
                testingHistogram = [testingHistogram; myBin(clusterComponents(clusterComponents>0), clusterNum)'];
                testingSpeed = [testingSpeed; mean(testingInfo(pstIdx,5))];
                testingHistogramLabel = [testingHistogramLabel; mean(testingInfo(pstIdx,1))];
            end
        end
    end

    % evaluate historgram similarity
    N = 10;
    
    testingSimilarity = [];
    testingSimilarityVal = [];
    
    testingNum = length(testingHistogramLabel);
    for testingID = 1:testingNum
        % select speed level
        traceFreq = testingInfo(testingID, 5);
        freqDist = abs(avgSpeed - traceFreq);
        [~,traceSpeed] = min(freqDist);
        
        similarityArray = zeros(1,10);
        for personID = 1:10
            if ~isempty(clusterHistogram{traceSpeed, personID})
                % similarity method 1
                similarityArray(personID) = distHist( clusterHistogram{traceSpeed, personID}, testingHistogram(testingID,:)', 3);
            end
        end
        [similarVal,similarID] = maxN(similarityArray, N);
        testingSimilarityVal = [testingSimilarityVal; similarVal];
        testingSimilarity = [testingSimilarity; similarID, similarVal(1)-similarVal(N)];
    end
    r = [testingSimilarity, testingHistogramLabel];
    rd = [];
    parray = [];
    for i = 1:N
       r(:,i)= r(:,i)-r(:,N+2);
       rd = [rd; mean(testingSimilarityVal(:,1)-testingSimilarityVal(:,i))];
       if i == 1
           rr = r(:,1);
       else
           rr = rr.*r(:,i);
       end
       parray = [parray;i, length(find(rr==0))/length(rr)];
    end
    figure;subplot(2,1,1);
    plot(parray(:,1),parray(:,2));
    title('first N number v.s. accuracy');
    subplot(2,1,2);
    plot(parray(:,1),rd);  
    title('first N number v.s. variation in them');
    
    parray = [];
    N = 5; r = [testingSimilarity(:,[1:N,end]), testingHistogramLabel];
    for i = 1:N
       r(:,i) = r(:,i)-r(:,N+2);
       if i == 1
           rr = r(:,1);
       else
           rr = rr.*r(:,i);
       end
    end
    for i = 0:0.1:0.5
        parray = [parray;i, length(find(r(:,N+1) > i)), ...
                    length(find(rr == 0 & r(:,N+1) > i))/length(find(r(:,N+1) > i))];
    end
    figure;
    subplot(2,1,1);
    plot(parray(:,1),parray(:,2));
    title('first 5 variation');
    subplot(2,1,2);
    plot(parray(:,1),parray(:,3));
    title('first 5, accuracy when variation is high');

    
    %% each step id in corresponding clusters
    testNum = size(testingSigs, 1);
    testingStepEntropy = zeros(testNum, 1);
    testingResults = zeros(testNum, 1);
    topN = 3;
    decisionScores = zeros(testNum, topN);
    decisionScoresIdx = zeros(testNum, topN);
    for testID = 1:testNum
        testID
        % extract trace step freq
        traceFreq = testingInfo(testID, 5);
        stepClusterID = testingInfo(testID, 6);
        stepGTID = testingInfo(testID, 1);
        
        freqDist = abs(avgSpeed - traceFreq);
        [~,traceSpeed] = min(freqDist);
        
        % in cluster ID collection
%         testingCluster{traceSpeed, stepClusterID} = [testingCluster{traceSpeed, stepClusterID}; testID, stepClusterID];
%         testingLabel{traceSpeed, stepClusterID} = [testingLabel{traceSpeed, stepClusterID}; testID, stepGTID];
%         [testExtr,outTest]=featureExtrationTest(testingPatterns(testID,:)',outTrain{traceSpeed, stepClusterID});

        if length(unique(speedTrainerLabel{traceSpeed})) < 2
            testingResults(testID) = unique(speedTrainerLabel{traceSpeed}) ;
            decisionScores(testID, 1) = 1;
            decisionScoresIdx(testID, 1) = testingResults(testID);
        else
            [testingResults(testID), ~, decision_values] = svmpredict(testingLabels(testID), testingPatterns(testID,:), svmstruct{traceSpeed},'-b 1');
            [Y,I] = sort(decision_values,'descend');
            minLen = min(length(Y),topN);
            decisionScores(testID, 1:minLen) = Y(1:minLen);
            decisionScoresIdx(testID, 1:minLen) = I(1:minLen);
            decisionScores(testID, :)
        end
        % select the weight for the step using entropy
    end
    [testingResults-testingLabels, testingResults, testingLabels, decisionScores, decisionScoresIdx]
    
    stepLevelAcc = length(find(testingResults-testingLabels == 0))/length(testingLabels)
    
%% trace level old method    
    traceMax = zeros(size(testingSimilarity,1),1);
    for stepIdx = 1:7:size(testingInfo,1)
        traceResult = testingResults(stepIdx:stepIdx+6);
        traceResultWeight = decisionScores(stepIdx:stepIdx+6,1);
        traceMax(floor(stepIdx/7)+1) = majorityVote(traceResult, traceResultWeight);
    end
    [traceMax, testingHistogramLabel]
    traceLevelAcc = length(find(traceMax-testingHistogramLabel == 0))/length(testingHistogramLabel)

%% combination weights
    traceCombinedWeight = zeros(size(testingSimilarity,1),1);
    for stepIdx = 1:7:size(testingInfo,1)
        traceResult = testingResults(stepIdx:stepIdx+6);
        traceResultWeight = decisionScores(stepIdx:stepIdx+6,1);
        traceCombinedWeight(floor(stepIdx/7)+1) = combinedVote(traceResult, traceResultWeight,...
                            testingSimilarity(floor(stepIdx/7)+1,:), testingSimilarityVal(floor(stepIdx/7)+1,:),...
                            testingStepEntropy);
    end
    [traceCombinedWeight, testingHistogramLabel]
    traceLevelAcc2 = length(find(traceCombinedWeight-testingHistogramLabel == 0))/length(testingHistogramLabel)



end

