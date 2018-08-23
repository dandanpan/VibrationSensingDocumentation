clear 
close all
clc

resultsSummary = [];
trainingResultAll = [];
traceResultAll = [];
crossValid = 1;
save('resultsSVM_part_all.mat','resultsSummary','crossValid','trainingResultAll','traceResultAll');


for crossValid = 1 : 4
    save('resultsSVM_part_all.mat','resultsSummary','crossValid','trainingResultAll','traceResultAll');
    clear
    load('resultsSVM_part_all.mat');

    configuration_setup;
    addpath('./libsvm-master/matlab/');
    
    trainingSpeedID = [8];
    testingSpeedID = [8];
    
    trainingTraceID = [crossValid:crossValid+6];
    allTraceID = [1:10];
    testingTraceID = allTraceID(~ismember(allTraceID,trainingTraceID));
    plotTrace = 0;
    plotStep = 0;

    trainingFlag = 1;
    testingFlag = 1;
    analysisFlag = 1;

    if trainingFlag == 1
        %% training phase
        stepPatternTrainLabel = [];
        stepPatternTrain = [];
        for personID = 1 : numPeople
            load(['../dataset/P' num2str(personID) '.mat']);

            stepSigs = [];
            stepSigsLabel = [];   
            personIDLabel = [];   
            speedIDLabel = [];    
            traceIDLabel = []; 
            stepFrequencySet = [];
            stepIdxLabel = [];
            traceSigs = [];
            traceSigsLabel = [];
            traceCount = 0;
            speedCount = 0;
            Signals = P{personID}.Sen{sensorID}.S;

            %% train on all speed
            for speedID = speedSequence(trainingSpeedID) %1 : numSpeed
                speedCount = speedCount + 1;
                Signals = P{personID}.Sen{sensorID}.S;
                traces = Signals{speedID};
                trainingTraceID = [1:5];
                for traceID = trainingTraceID
                    traceSig = traces{traceID,1};
                    traceSigFilter = signalDenoise(traceSig, 50);

                    [ stepEventValue ,stepEventsIdx ] = findpeaks(traceSigFilter,'MinPeakDistance',200,'MinPeakHeight',50,'Annotate','extents');
                    % filter out-of-range steps
                    stepEventValue = stepEventValue(stepEventsIdx > WIN1 & stepEventsIdx < length(traceSigFilter)-WIN2);
                    stepEventsIdx = stepEventsIdx(stepEventsIdx > WIN1 & stepEventsIdx < length(traceSigFilter)-WIN2);
                    % select steps by energy
                    [ selectedSteps ] = stepSelectionSNR( traceSigFilter, stepEventsIdx, WIN1, WIN2, 3 );
                    stepEventsIdx = stepEventsIdx(selectedSteps);
                    stepEventValue = stepEventValue(selectedSteps);

                    if plotTrace == 1
                        figure;
                        plot(traceSigFilter);hold on;
                        scatter(stepEventsIdx, stepEventValue, 'rV');
                        hold off;
                    end

                    tempMF = 0;
                    mcount = 0;
                    for stepID = 1 : length(stepEventsIdx)
                        % find first peak
                        tempSig = traceSigFilter(stepEventsIdx(stepID)-WIN1+1:stepEventsIdx(stepID)+WIN2);
                        tempThresh = max(tempSig)/1.1;
                        [ tempV ,tempI ] = findpeaks(tempSig,'MinPeakDistance',20,'MinPeakHeight',tempThresh,'Annotate','extents');
                        tempIndex = stepEventsIdx(stepID)-WIN1+1+tempI(1);
                        % extract step
                        stepSig = traceSigFilter(tempIndex-WIN1+1:tempIndex+WIN2);
                        stepSig = signalNormalization(stepSig);
                        [ Y, f, NFFT] = signalFreqencyExtract( stepSig, Fs );
                        Y = Y(f<=cutoffFrequency);
                        f = f(f<=cutoffFrequency);
                        Y = signalNormalization(Y);
                        medianFreq = medianFrequency(Y, f);

                        tempMF = tempMF + medianFreq;
                        mcount = mcount + 1;
                        if plotStep == 1
                            plot(f,Y);hold on;xlim([0,90]);
                            plot([medianFreq, medianFreq],[0,0.05]);
                        end
                        stepSigs = [stepSigs; stepSig'];
                        stepSigsLabel = [stepSigsLabel; speedCount];
                        personIDLabel = [personIDLabel; personID];
                        speedIDLabel = [speedIDLabel; speedID];
                        traceIDLabel = [traceIDLabel; traceID];
                        stepIdxLabel = [stepIdxLabel; tempIndex];
    %                     stepFrequencySet = [stepFrequencySet; stepFrequencyMean];
                    end
                end
            end

            % record for each person
            personModel{personID}.stepSigs = stepSigs;
            personModel{personID}.speedIDLabel = speedIDLabel;
            personModel{personID}.traceIDLabel = traceIDLabel;
            personModel{personID}.stepIdxLabel = stepIdxLabel;
            personModel{personID}.stepFrequencySet = stepFrequencySet;

            % end of a person's training data
            [clusters] = stepSelection( stepSigs, 0); 
            personModel{personID}.clusters = clusters;
            clusterNum = length(clusters);
            % abstract the clusters
            for clusterID = 1 : clusterNum
                stepNum = length(clusters{clusterID});
                if stepNum < 3
                    continue;
                end
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
%                 stepFCluster = [];
                for stepID = 1 : stepNum
                    % feature extraction
                    stepIdx = clusters{clusterID}(stepID);
                    stepSig = stepSigs(stepIdx,:);

                    % frequency domain
                    [ Y, f, NFFT] = signalFreqencyExtract( stepSig, Fs );
                    Y = Y(f<=cutoffFrequency);
                    f = f(f<=cutoffFrequency);
                    Y = signalNormalization(Y);
                    stepPatternTrain = [stepPatternTrain; Y];
                    stepPatternTrainLabel = [stepPatternTrainLabel; personID];
%                     stepFCluster = [stepFCluster; Y];
                end
%                 clusterCharacter{personID, clusterID} = mean(stepFCluster);
    %             figure; plot(clusterCharacter{personID, clusterID});
            end
        end
    end
    
    svmstruct = svmtrain(stepPatternTrainLabel, stepPatternTrain, '-s 0 -t 2 -b 1');
    
    %% testing phase
    if testingFlag == 1
        stepPatternTest = [];
        stepPatternTestLabel = [];
        stepPatternTestSpeed = [];
        stepPatternTestTrace = [];
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

                        stepPatternTest =[stepPatternTest; Y'];
                        stepPatternTestLabel = [stepPatternTestLabel; personID];
                        stepPatternTestSpeed = [stepPatternTestSpeed; speedID];
                        stepPatternTestTrace = [stepPatternTestTrace; traceID];
                    end
                end
            end
        end
        [predicted_label, accuracy, decision_values] = svmpredict(stepPatternTestLabel, stepPatternTest, svmstruct,'-b 1');
        maxDeci = max(decision_values,[],2);
        maxDeciRatio = sum(maxDeci > 0.5)/length(maxDeci)
        
        if analysisFlag == 1
            %% result analysis phase
            % check the step level results
            allStepNum = size(predicted_label,1);
            for i = 1 : numPeople
                for j = 1 : numSpeed
                    % store person speed accuracy
                    PS{i,j} = zeros(numPeople);
                end
            end
            for stepID = 1 : allStepNum
                realID = stepPatternTestLabel(stepID);
                realSpeed = stepPatternTestSpeed(stepID);
                estID = predicted_label(stepID);
                PS{realID,realSpeed}(realID,estID) = PS{realID,realSpeed}(realID,estID) + 1;
            end

            % step level results
            figure;
            allPC = 0;
            allPS = 0;
            allPC8 = 0;
            allPS8 = 0;
            for personID = 1: numPeople
                subplot(numPeople,1,personID);
                allCorrect = 0;
                allStep = 0;
                speedAcc = zeros(numSpeed,1);
                for speedID = speedSequence(testingSpeedID)
        %             for i = 1 : numPeople
        %                 speedAcc(speedID,i) = ...
        %                     PS{personID, speedID}(personID,i)/ ...
        %                     sum(PS{personID, speedID}(personID,:));
        %             end
                    speedAcc(speedID) = ...
                        PS{personID, speedID}(personID,personID)/ ...
                        sum(PS{personID, speedID}(personID,:));       
                    allCorrect = allCorrect + PS{personID, speedID}(personID,personID);
                    allStep = allStep + sum(PS{personID, speedID}(personID,:));
                end
                allPC8 = allPC8 + PS{personID, 8}(personID,personID);
                allPS8 = allPS8 + sum(PS{personID, 8}(personID,:)); 
                allPC = allPC + allCorrect;
                allPS = allPS + allStep;
                allAcc = allCorrect/allStep;
                bar(speedAcc(speedSequence));hold on;
                plot([0.5,8.5],[allAcc,allAcc],'r');
                set(gca,'XtickLabel',{'-3\sigma', '-2\sigma', '-\sigma', '\mu','\sigma','2\sigma', '3\sigma','s'});
                ylim([0,1]);
                xlabel('Speed');
                ylabel('Accuracy');
                title(['Person ' num2str(personID)]);
            end
            allP1 = allPC/allPS
            allP1_8 = allPC8/allPS8


            %% Trace Level: majority vote 
            allStepNum = size(predicted_label,1);
            traceResult = [];
            for i = 1 : numPeople
                for j = 1 : numSpeed
                    resultSet = predicted_label(stepPatternTestLabel == i & stepPatternTestSpeed == j, :);
                    resultTrace = stepPatternTestTrace(stepPatternTestLabel == i & stepPatternTestSpeed == j, :);
                    %                     resultSet = resultSet(resultSet(:,7)>0.9,:);
                    if length(resultSet) == 0
                        continue;
                    end
                    % go through each trace
                    if i == 5  && j == 3
                        traceSet = [6:9];
                    else
                        traceSet = testingTraceID;
                    end
                    for traceID = traceSet
                        traceVote = resultSet(resultTrace==traceID,:);
                        tempResult = mode(traceVote);

        %                 tempResult = mode(traceVote(:,5));
        %                 [~,tempidx] = max(traceVote(:,7));
        %                 tempResult = traceVote(tempidx,5);
                        traceResult = [traceResult; i,j,traceID,tempResult]; 
                    end
                end
            end
            traceResultAll = [traceResultAll; traceResult];
            % trace level results
            figure;
            allPC = 0;
            allPS = 0;
            allPC8 = 0;
            allPS8 = 0;
            for personID = 1: numPeople
                subplot(numPeople,1,personID);
                allCorrect = 0;
                allTrace = 0;
                speedAcc = zeros(numSpeed,1);
                for speedID = speedSequence(testingSpeedID)
                    tempResult = traceResult(traceResult(:,1) == personID & traceResult(:,2) == speedID,4);
        %             for i = 1 : numPeople
        %                 speedAcc(speedID,i) = sum(tempResult == i)/length(tempResult);
        %             end
                    speedAcc(speedID) = sum(tempResult == personID)/length(tempResult);
                    allCorrect = allCorrect + sum(tempResult == personID);
                    allTrace = allTrace + length(tempResult);
                    if speedID == 8
                        allPC8 = allPC8 + sum(tempResult == personID);
                        allPS8 = allPS8 + length(tempResult);
                    end
                end

                allPC = allPC + allCorrect;
                allPS = allPS + allTrace;

                allAcc = allCorrect/allTrace;
                bar(speedAcc(speedSequence));hold on;
                plot([0.5,8.5],[allAcc,allAcc],'r');
                set(gca,'XtickLabel',{'-3\sigma', '-2\sigma', '-\sigma', '\mu','\sigma','2\sigma', '3\sigma','s'});
                ylim([0,1]);
                xlabel('Speed');
                ylabel('Accuracy');
                title(['Person ' num2str(personID)]);
            end
            allP2 = allPC/allPS
            allP2_8 = allPC8/allPS8
        end
        
    end
    resultsSummary = [resultsSummary; allP1, allP2];
    
    save('resultsSVM_part_all.mat','resultsSummary','crossValid','trainingResultAll','traceResultAll');

end
