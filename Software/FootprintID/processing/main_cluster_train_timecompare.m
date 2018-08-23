addpath('./libsvm-master/matlab/');

%% training phase
configuration_setup;
trainingTraceID = [1:5];
trainingSpeedID = [1,7,8];
testingSpeedID = [1:8];
allTraceID = [1:10];
testingTraceID = allTraceID(~ismember(allTraceID,trainingTraceID));
clusterSignal = [];
clusterInfoPerson = [];
clusterInfoID = [];
   
%% method 1
for personID = 1 : numPeople
    load(['../dataset/P' num2str(personID) '.mat']);

    stepSigs = [];
    stepSigsLabel = [];   
    personIDLabel = [];   
    speedIDLabel = [];    
    traceIDLabel = []; 
    stepIdxLabel = [];
    stepFrequencySet = [];
    traceSigs = [];
    traceSigsLabel = [];
    traceCount = 0;
    speedCount = 0;
    Signals = P{personID}.Sen{sensorID}.S;

    %% self selected speed 8
    for speedID = speedSequence(trainingSpeedID)
        traces = Signals{speedID};
        for traceID = trainingTraceID
            traceSig = traces{traceID,1};
            traceSigFilter = signalDenoise(traceSig, 50);

            [ stepEventValue ,stepEventsIdx ] = findpeaks(traceSigFilter,'MinPeakDistance',200,'MinPeakHeight',50,'Annotate','extents');
            stepFrequency = (stepEventsIdx(2:end) - stepEventsIdx(1:end-1))./Fs;

            % filter out-of-range steps
            stepEventValue = stepEventValue(stepEventsIdx > WIN1 & stepEventsIdx < length(traceSigFilter)-WIN2);
            stepEventsIdx = stepEventsIdx(stepEventsIdx > WIN1 & stepEventsIdx < length(traceSigFilter)-WIN2);
            % select steps by energy
            [ selectedSteps ] = stepSelectionSNR( traceSigFilter, stepEventsIdx, WIN1, WIN2, 3 );
            stepEventsIdx = stepEventsIdx(selectedSteps);
            stepEventValue = stepEventValue(selectedSteps);

            for stepID = 1 : length(stepEventsIdx)
                % find first peak
                tempSig = traceSigFilter(stepEventsIdx(stepID)-WIN1+1:stepEventsIdx(stepID)+WIN2);
                tempThresh = max(tempSig)/1.1;
                [ tempV ,tempI ] = findpeaks(tempSig,'MinPeakDistance',20,'MinPeakHeight',tempThresh,'Annotate','extents');
                tempIndex = stepEventsIdx(stepID)-WIN1+1+tempI(1);
                % extract step
                stepSig = traceSigFilter(tempIndex-WIN1+1:tempIndex+WIN2);
                stepSig = signalNormalization(stepSig);

                stepSigs = [stepSigs; stepSig'];
                personIDLabel = [personIDLabel; personID];
                speedIDLabel = [speedIDLabel; speedID];
                traceIDLabel = [traceIDLabel; traceID];
                stepIdxLabel = [stepIdxLabel; tempIndex];
                stepFrequencySet = [stepFrequencySet; mean(stepFrequency), std(stepFrequency)];
            end
        end
    end
    % end of a person's training data
    [clusters] = stepSelection( stepSigs, 0);

    % record for each person
    personModel{personID}.stepSigs = stepSigs;
    personModel{personID}.speedIDLabel = speedIDLabel;
    personModel{personID}.traceIDLabel = traceIDLabel;
    personModel{personID}.stepIdxLabel = stepIdxLabel;
    personModel{personID}.stepFrequencySet = stepFrequencySet;
    personModel{personID}.clusters = clusters;

    clusterNum = length(clusters);
    % abstract the clusters
    for clusterID = 1 : clusterNum
        stepNum = length(clusters{clusterID});
        % signal not aligned by the shape 
        % therefore only look at the frequency domain for the first level
        % clustering

        %% check the shift error
        whiteList = [];
        if stepNum > 3
            for i = 1 : stepNum
                for j = i+1 : stepNum
                    stepIdx1 = clusters{clusterID}(i);
                    stepSig1 = stepSigs(stepIdx1,:);
                    stepIdx2 = clusters{clusterID}(j);
                    stepSig2 = stepSigs(stepIdx2,:);
                    stepSig1 = signalNormalization(stepSig1);
                    stepSig2 = signalNormalization(stepSig2);
                    [temp, shift] = max((xcorr(stepSig1,stepSig2)));
                    if abs(shift-400) < 2
                        whiteList = [whiteList, i,j];
                    end      
                end
            end
        else
            whiteList = 1;
        end
        whiteList = unique(whiteList);
        stepSigWhiteIdx = clusters{clusterID}(whiteList(1));
        stepSigWhite = stepSigs(stepSigWhiteIdx,:);
        stepSigWhite = signalNormalization(stepSigWhite);
        blackList = [1 : stepNum];
        blackList(blackList == whiteList(1)) = [];
        for bidx = 1 : length(blackList) 
            blackNum = blackList(bidx);
            stepIdxInCluster = clusters{clusterID}(blackNum);
            stepSigBlack = stepSigs(stepIdxInCluster,:);
            stepSigBlack = signalNormalization(stepSigBlack);
            [temp, shift] = max((xcorr(stepSigWhite,stepSigBlack)));
            if abs(shift-400) > 2
               a = 0; 
            end
            traceSig = Signals{speedIDLabel(stepIdxInCluster)}{traceIDLabel(stepIdxInCluster),1};
            traceSigFilter = signalDenoise(traceSig, 50);
            offset = shift - 400;
            tempSig = traceSigFilter(stepIdxLabel(stepIdxInCluster) - offset - WIN1+1 : ...
                                    stepIdxLabel(stepIdxInCluster) - offset + WIN2); 
            stepSigs(stepIdxInCluster,:) = signalNormalization(tempSig);
        end

        %% within a cluster processing
        stepFCluster = [];
        for stepID = 1 : stepNum
            % feature extraction
            stepIdx = clusters{clusterID}(stepID);
            stepSig = stepSigs(stepIdx,:);

            % frequency domainspeedSequence
            [ Y, f, NFFT] = signalFreqencyExtract( stepSig, Fs );
            Y = Y(f<=cutoffFrequency);
            f = f(f<=cutoffFrequency);
            Y = signalNormalization(Y);
            stepFCluster = [stepFCluster; Y];
        end
        clusterCharacter{personID, clusterID} = mean(stepFCluster);
%             figure; plot(clusterCharacter{personID, clusterID});
        clusterSignal = [clusterSignal; mean(stepFCluster)];
        clusterInfoPerson = [clusterInfoPerson; personID];
        clusterInfoID = [clusterInfoID; clusterID];
    end
end

%% id steps
trainingResult = [];
for personID = 1 : numPeople
    load(['../dataset/P' num2str(personID) '.mat']);
    Signals = P{personID}.Sen{sensorID}.S;

    for speedID = speedSequence(testingSpeedID)
        traces = Signals{speedID};

        %% start training on all different speed
        for traceID = testingTraceID
            if traceID > length(traces)
                continue;
            end
            traceSig = traces{traceID,1};
            traceSigFilter = signalDenoise(traceSig, 50);

            [ stepEventValue ,stepEventsIdx ] = findpeaks(traceSigFilter,'MinPeakDistance',200,'MinPeakHeight',50,'Annotate','extents');
            stepFrequency = (stepEventsIdx(2:end) - stepEventsIdx(1:end-1))./Fs;

            % filter out-of-range steps
            stepEventValue = stepEventValue(stepEventsIdx > WIN1 & stepEventsIdx < length(traceSigFilter)-WIN2);
            stepEventsIdx = stepEventsIdx(stepEventsIdx > WIN1 & stepEventsIdx < length(traceSigFilter)-WIN2);
            % select steps by energy
            [ selectedSteps ] = stepSelectionSNR( traceSigFilter, stepEventsIdx, WIN1, WIN2, 3 );
            stepEventsIdx = stepEventsIdx(selectedSteps);
            stepEventValue = stepEventValue(selectedSteps);

            for stepID = 1 : length(stepEventsIdx)
                % find first peak
                tempSig = traceSigFilter(stepEventsIdx(stepID)-WIN1+1:stepEventsIdx(stepID)+WIN2);
                tempThresh = max(tempSig)/1.1;
                [ tempV ,tempI ] = findpeaks(tempSig,'MinPeakDistance',20,'MinPeakHeight',tempThresh,'Annotate','extents');
                tempIndex = stepEventsIdx(stepID)-WIN1+1+tempI(1);
                % extract step
                stepSig = traceSigFilter(tempIndex-WIN1+1:tempIndex+WIN2);
                stepSig = signalNormalization(stepSig);

                % frequency domain
                [ Y, f, NFFT] = signalFreqencyExtract( stepSig, Fs );
                Y = Y(f<=cutoffFrequency);
                f = f(f<=cutoffFrequency);
                Y = signalNormalization(Y);

                %% matching for people/cluster
                matchMaker = [];
                for i = 1 : numPeople
                    for j = 1 : size(clusterCharacter, 2)
                        if length(clusterCharacter{i,j}) > 0
%                             tempMatch = max(xcorr(Y,clusterCharacter{i,j}));
                            tempMatch = 1 - sum((Y'-clusterCharacter{i,j}).*(Y'-clusterCharacter{i,j}));
                            matchMaker = [matchMaker; i,j,tempMatch];
                        end
                    end
                end

                % find top 1 and see the speed influence
                [~, mostSimilarCluster] = max(matchMaker(:,3));
                trainingResult = [trainingResult; personID,speedID,traceID,...
                                    -1,matchMaker(mostSimilarCluster,:), ...
                                    mean(stepFrequency), std(stepFrequency)];
            end
        end
    end
end

t1 = tic;
%% second clustering
thresholdSecondClustering = mean(trainingResult(:,7))+std(trainingResult(:,7));
numCluster = size(clusterSignal,1);
clusterMatrix = zeros(numCluster);
Y = [];
for clusterID1 = 1 : numCluster
    for clusterID2 = clusterID1 + 1: numCluster
        differenceBetween = clusterSignal(clusterID1,:) - clusterSignal(clusterID2,:);
        clusterMatrix(clusterID1, clusterID2) = sum(differenceBetween.*differenceBetween);
        clusterMatrix(clusterID2, clusterID1) = sum(differenceBetween.*differenceBetween); 
        Y = [Y, sum(differenceBetween.*differenceBetween)];
    end
end
% create the tree based on the clusterMatrix
clusterCluster = generateHTree( Y, 1-thresholdSecondClustering, numCluster );
% re-assign the clusters
recluster = zeros(size(clusterSignal,1), 3); % 1: personID; 2: clusterID; 3: currentCluster
oricluster = [1:size(clusterSignal,1)];
clusterCount = 0;
for i = 1 : length(clusterCluster)
    clusterCount = clusterCount + 1;
    for j = 1 : length(clusterCluster{i})
        recluster(clusterCluster{i}(j),1) = clusterInfoPerson(clusterCluster{i}(j));
        recluster(clusterCluster{i}(j),2) = clusterInfoID(clusterCluster{i}(j));
        recluster(clusterCluster{i}(j),3) = clusterCount;
        oricluster(oricluster == clusterCluster{i}(j)) = [];
    end
end
for i = 1 : length(oricluster)
    clusterCount = clusterCount + 1;
    recluster(oricluster(i),1) = clusterInfoPerson(oricluster(i));
    recluster(oricluster(i),2) = clusterInfoID(oricluster(i));
    recluster(oricluster(i),3) = clusterCount;
end

tracePatternTrain = [];
tracePatternLabel = [];
% revisit the training trace
for personID = 1 : numPeople
    for traceID = trainingTraceID
        info = personModel{personID};
        stepIdxs = find(info.traceIDLabel == traceID);
        traceFeature =[];
        for stepID = 1:length(stepIdxs)
            oldClusterID = findClusterID(info.clusters, stepIdxs(stepID));
            newClusterID = recluster(recluster(:,1) == personID & recluster(:,2) == oldClusterID,3);
            traceFeature = [traceFeature, newClusterID];
        end
        tempHist = zeros(1,clusterCount);
        for i = 1 : clusterCount
            tempHist(i) = sum(traceFeature == i);
        end
%         tracePatternTrain = [tracePatternTrain; info.stepFrequencySet(stepIdxs(1),:),tempHist./sum(tempHist)];
        tracePatternTrain = [tracePatternTrain; info.stepFrequencySet(stepIdxs(1),:),tempHist>0];
        tracePatternLabel = [tracePatternLabel; personID];
    end
end
% SVM TRAIN
svmstruct = svmtrain(tracePatternLabel, tracePatternTrain, '-s 0 -t 2 -b 1 -g 0.07 -e 0.01');
t2 = tic;
method1Time = t2-t1;

%% method2
t3 = tic;
stepsFeature = [];
stepsLabel = [];
for personID = 1 : numPeople
    load(['../dataset/P' num2str(personID) '.mat']);
    Signals = P{personID}.Sen{sensorID}.S;

    for speedID = speedSequence(testingSpeedID)
        traces = Signals{speedID};

        %% start training on all different speed
        for traceID = testingTraceID
            if traceID > length(traces)
                continue;
            end
            traceSig = traces{traceID,1};
            traceSigFilter = signalDenoise(traceSig, 50);

            [ stepEventValue ,stepEventsIdx ] = findpeaks(traceSigFilter,'MinPeakDistance',200,'MinPeakHeight',50,'Annotate','extents');
            stepFrequency = (stepEventsIdx(2:end) - stepEventsIdx(1:end-1))./Fs;

            % filter out-of-range steps
            stepEventValue = stepEventValue(stepEventsIdx > WIN1 & stepEventsIdx < length(traceSigFilter)-WIN2);
            stepEventsIdx = stepEventsIdx(stepEventsIdx > WIN1 & stepEventsIdx < length(traceSigFilter)-WIN2);
            % select steps by energy
            [ selectedSteps ] = stepSelectionSNR( traceSigFilter, stepEventsIdx, WIN1, WIN2, 3 );
            stepEventsIdx = stepEventsIdx(selectedSteps);
            stepEventValue = stepEventValue(selectedSteps);

            for stepID = 1 : length(stepEventsIdx)
                % find first peak
                tempSig = traceSigFilter(stepEventsIdx(stepID)-WIN1+1:stepEventsIdx(stepID)+WIN2);
                tempThresh = max(tempSig)/1.1;
                [ tempV ,tempI ] = findpeaks(tempSig,'MinPeakDistance',20,'MinPeakHeight',tempThresh,'Annotate','extents');
                tempIndex = stepEventsIdx(stepID)-WIN1+1+tempI(1);
                % extract step
                stepSig = traceSigFilter(tempIndex-WIN1+1:tempIndex+WIN2);
                stepSig = signalNormalization(stepSig);

                % frequency domain
                [ Y, f, NFFT] = signalFreqencyExtract( stepSig, Fs );
                Y = Y(f<=cutoffFrequency);
                f = f(f<=cutoffFrequency);
                Y = signalNormalization(Y);

                stepsFeature = [stepsFeature; [Y; stepSig]'];
                stepsLabel = [stepsLabel, personID];
            end
        end
    end
end
svmstruct = svmtrain(stepsLabel, stepsFeature, '-s 0 -t 2 -b 1');

t4 = tic;
method2Time = t4-t3;


method1Time
method2Time



