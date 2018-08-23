function [ accuracy, mIdx, clusterPattern, clusterEntropy, tIdx, clusterSubset, clusterHistogram ] = algo1Eva( stepSigs, stepPattern, stepInfoAll, trainingIdx, trainingSpeedID, testingIdx, clusterNum )
%   method: pca and knn
%   INPUT:
%   stepSigs: time domain signals
%   stepPattern: freq domain signals
%   stepInfoAll: personID, speedID, traceID, stepID, stepFreq, clusterID
%   trainingIdx/testingIdx: for cross validation
%   clusterNum: total number of cluster
%   OUTPUT: accuracy
    % training options
    optionKSRSC.SCMethod='nnqpAS';
    optionKSRSC.lambda=0;
    optionKSRSC.predicter='knn';
    optionKSRSC.k = 5;
    optionKSRSC.kernel='rbf';
    optionKSRSC.param=2^0;
    
    % variables
    accuracy = 0;
    speedSequence = [7,6,5,1,2,3,4,8];
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
    clusterPattern = cell(8,clusterNum);
    clusterLabel = cell(8,clusterNum);
    for speedID = trainingSpeedID
        for clusterID = 1:clusterNum
            mIdx{speedID, clusterID} = find(trainingInfo(:,2) == speedSequence( speedID ) & trainingInfo(:,6) == clusterID);
            if ~isempty( mIdx{speedID, clusterID})
                if length(mIdx{speedID, clusterID}) > 1
                    clusterPattern{speedID, clusterID} = mean( trainingPatterns( mIdx{speedID, clusterID}, : ) );
                elseif length(mIdx{speedID, clusterID}) == 1
                    clusterPattern{speedID, clusterID} =  trainingPatterns( mIdx{speedID, clusterID}, : );
                else 
                    continue;
                end  
                clusterTrainer{speedID, clusterID} = trainingPatterns( mIdx{speedID, clusterID}, : );
                clusterLabel{speedID, clusterID} = trainingInfo( mIdx{speedID, clusterID}, 1 ) ;
                clusterEntropy{speedID, clusterID} = entropyFromDistribution( clusterPattern{speedID, clusterID}, 3 );
            end
        end
    end
    
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
%     length(find(testingSimilarity-testingHistogramLabel' == 0))/length(testingHistogramLabel)

    % cluster based step level identification
%     for clusterID = 1:clusterNum
%         for speedID = 1:8
%             testingCluster{speedID, clusterID} = [];
%             testingLabel{speedID, clusterID} = [];
%         end
%     end
    
    %% each step id in corresponding clusters
    testNum = size(testingSigs, 1);
    testingStepEntropy = zeros(testNum, 1);
    testingResults = zeros(testNum, 1);
    for testID = 1:testNum
        % extract trace step freq
        traceFreq = testingInfo(testID, 5);
        stepClusterID = testingInfo(testID, 6);
        stepGTID = testingInfo(testID, 1);
        
        freqDist = abs(avgSpeed - traceFreq);
        [~,traceSpeed] = min(freqDist);

        % check the trace speed corresponding cluster set
        if ~ismember(stepClusterID, clusterSubsetPerSpeed{traceSpeed})
            minDist = 10000;
            for clusterID = 1:clusterNum
                if ~isempty(clusterPattern{traceSpeed, clusterID})
                    clusterDist = distFreq(clusterPattern{traceSpeed, clusterID}, testingPatterns(testID,:));
                    if clusterDist < minDist
                        stepClusterID = clusterID;
                    end
                end
            end
        end
        
        % in cluster ID collection
%         testingCluster{traceSpeed, stepClusterID} = [testingCluster{traceSpeed, stepClusterID}; testID, stepClusterID];
%         testingLabel{traceSpeed, stepClusterID} = [testingLabel{traceSpeed, stepClusterID}; testID, stepGTID];

%         if stepClusterID == 0
%             testingResults(testID) = NaN;
%             continue;
%         end
        [ testingResults(testID), sparse, Y, otherOutput ]=KSRSCClassifier(clusterTrainer{traceSpeed, stepClusterID}',clusterLabel{traceSpeed, stepClusterID}',testingPatterns(testID,:)',optionKSRSC);
%         testingResults(testID) = 
        % select the weight for the step using entropy
        testingStepEntropy(testID) = clusterEntropy{traceSpeed, stepClusterID};
    end
    
    stepLevelAcc = length(find(testingResults-testingLabels == 0))/length(testingLabels)
    
%% for each cluster do a step level 
%     optionKSRSC.SCMethod='nnqpAS';
%     optionKSRSC.lambda=0;
%     optionKSRSC.predicter='knn';
%     optionKSRSC.k = 10;
%     optionKSRSC.kernel='rbf';
%     optionKSRSC.param=2^0;
%     for clusterID = 1:clusterNum
%         for speedID = 1:8
%             if ~isempty(testingCluster{speedID, clusterID})
%                 % do the classification
%                 [testClassPredictedKSRSC,sparse,Y,otherOutput]=KSRSCClassifier(clusterPattern{speedID, clusterID}',clusterLabel{speedID, clusterID},testingCluster{traceSpeed, clusterID}',optionKSRSC);
%                 [performanceKSRSC, conMat]=perform(testClassPredictedKSRSC,testingLabel{speedID, clusterID},10);
% 
%             end
%         end
%     end

    %% combination
end

