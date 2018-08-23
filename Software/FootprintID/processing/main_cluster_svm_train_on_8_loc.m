clear 
close all
clc

numPeople = 10;
resultsSummary = [];
trainingResultAll = [];
traceResultAll = [];
matrixAll = zeros(numPeople);
crossValid = 1;
portionID = 1;
cookieStep = [];
trainingTime = [];
trainingSize = [];
save('results_cv8_portion.mat','resultsSummary','crossValid',...
    'trainingResultAll','traceResultAll','trainingTime',...
    'matrixAll','cookieStep','numPeople','portionID','trainingSize');

for portionID = 7%1 : 9
    for crossValid = 1 : 5
        save('results_cv8_portion.mat','resultsSummary','crossValid',...
            'trainingResultAll','traceResultAll','trainingTime',...
            'matrixAll','cookieStep','numPeople','portionID','trainingSize');
        clear
        load('results_cv8_portion.mat');

        configuration_setup;
        addpath('./libsvm-master/matlab/');

        temp = [crossValid:crossValid+portionID-1];
        trainingTraceID = temp(temp < 10);
        temp(temp < 10) = [];
        temp = temp - 9;
        trainingTraceID = [trainingTraceID, temp]
        allTraceID = [1:10];
        
        testingTraceID = allTraceID(~ismember(allTraceID,trainingTraceID))

        trainingFlag = 1;
        testingFlag = 1;
        analysisFlag = 1;
        cookieTest = 1;
        trainingSpeedID = [8];
        testingSpeedID = [8];

        if trainingFlag == 1
            time1 = tic;
            %% training phase
            trainingFeatures = [];
            trainingLabels = [];
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
                for speedID = speedSequence(trainingSpeedID)%speedID = 8;
                    traces = Signals{speedID};
                    if personID == 5 && speedID == 3
                        trainingTraceID = trainingTraceID(trainingTraceID~=10);
                    end
                    for traceID = trainingTraceID
                        traceSig = traces{traceID,1};
                        traceSigFilter = signalDenoise(traceSig, 50);

                        [ stepEventValue ,stepEventsIdx ] = findpeaks(traceSigFilter,'MinPeakDistance',200,'MinPeakHeight',50,'Annotate','extents');
                        stepFrequency = (stepEventsIdx(2:end) - stepEventsIdx(1:end-1))./Fs;
                        stepFrequency = stepFrequency(stepFrequency<1);
                        stepFrequencyMean = mean(stepFrequency);

                        % filter out-of-range steps
                        stepEventValue = stepEventValue(stepEventsIdx > WIN1 & stepEventsIdx < length(traceSigFilter)-WIN2);
                        stepEventsIdx = stepEventsIdx(stepEventsIdx > WIN1 & stepEventsIdx < length(traceSigFilter)-WIN2);
                        % select steps by energy
                        [ selectedSteps ] = stepSelectionSNR( traceSigFilter, stepEventsIdx, WIN1, WIN2, 1 );
                        stepEventsIdx = stepEventsIdx(selectedSteps);
                        stepEventValue = stepEventValue(selectedSteps);
                        trainingSize = [trainingSize, length(selectedSteps)];

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
                            stepFrequencySet = [stepFrequencySet; stepFrequencyMean];
                        end
                    end
                end

                % end of a person's training data
                [clusters] = stepSelection( stepSigs, 0);
                clusterNum = length(clusters);
                % abstract the clusters
                for clusterID = 1 : clusterNum
                    stepNum = length(clusters{clusterID});
                    % signal not aligned by the shape 
                    % therefore only look at the frequency domain for the first level
                    % clustering

                    %% check the shift error
                    whiteList = [];
                    if stepNum > 5
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
                        whiteList = [1];
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
                        if stepIdxLabel(stepIdxInCluster) - offset + WIN2 > length(traceSigFilter)
                            tempSig = traceSigFilter(end-399:end);
                        else
                            tempSig = traceSigFilter(stepIdxLabel(stepIdxInCluster) - offset - WIN1+1 : ...
                                                stepIdxLabel(stepIdxInCluster) - offset + WIN2); 
                        end
                        stepSigs(stepIdxInCluster,:) = signalNormalization(tempSig);
                    end

                    %% within a cluster processing
                    for stepID = 1 : stepNum
                        % feature extraction
                        stepIdx = clusters{clusterID}(stepID);
                        stepSig = stepSigs(stepIdx,:);
                        freq = stepFrequencySet(stepIdx);
                        % frequency domain
                        [ Y, f, NFFT] = signalFreqencyExtract( stepSig, Fs );
                        Y = Y(f<=cutoffFrequency);
                        f = f(f<=cutoffFrequency);
                        Y = signalNormalization(Y);
                        %% speed as pattend
    %                     trainingFeatures = [trainingFeatures; Y];
                        trainingFeatures = [trainingFeatures; freq./8, Y];
                        trainingLabels = [trainingLabels; personID];% * 100 + clusterID];
                    end
                end
            end

            % tune parameter ?
            accBase = 0;
            gc = 0;
            for gi = [0.1,0.5,1,3,5,7,9]
                tempStruct = svmtrain(trainingLabels, trainingFeatures, ['-s 0 -t 2 -b 1 -g ' num2str(gi) ' -c 100']);
                [predicted_label, accuracy, decision_values] = svmpredict(trainingLabels, trainingFeatures, tempStruct,'-b 1');
    %                 fprintf(['gi=' num2str(gi) ', acc=' num2str(accuracy(1)) '\n']);
                if accuracy(1) > accBase
                    svmstruct = tempStruct;
                    accBase = accuracy(1);
                    gc = gi;
                end
            end
            gc
    %         svmstruct = svmtrain(trainingLabels, trainingFeatures, '-s 0 -t 2 -b 1 -g 10 -c 1000');
            time2 = tic;
        end
        trainingTime = [trainingTime, time2-time1];

        if testingFlag == 1
        %% testing phase
            stepPatternTest = [];
            stepPatternTestLabel = [];
            stepPatternTestSpeed = [];
            stepPatternTestTrace = [];

            trainingResult = [];
            for personID = 1 : numPeople
                load(['../dataset/P' num2str(personID) '.mat']);
                Signals = P{personID}.Sen{sensorID}.S;

                for speedID = speedSequence
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
                        stepFrequency = stepFrequency(stepFrequency<1);
                        stepFrequencyMean = mean(stepFrequency);

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

                            %% speed as pattend
    %                         stepPatternTest =[stepPatternTest; Y'];
                            stepPatternTest =[stepPatternTest; stepFrequencyMean./8, Y'];
                            stepPatternTestLabel = [stepPatternTestLabel; personID];
                            stepPatternTestSpeed = [stepPatternTestSpeed; speedID];
                            stepPatternTestTrace = [stepPatternTestTrace; traceID];
                        end
                    end

                end
            end
        end
        [predicted_label, accuracy, decision_values] = svmpredict(stepPatternTestLabel, stepPatternTest, svmstruct,'-b 1');
    %     predicted_label = floor(predicted_label./100);
        acc = sum(predicted_label == stepPatternTestLabel)./length(predicted_label)

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
            trainingResultAll = [trainingResultAll;[stepPatternTestLabel, stepPatternTestSpeed, predicted_label]];

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
                        traceSet = testingTraceID(testingTraceID~=10);
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

        accuracyStep = -1;
        accuracyStep14 = -1;
        accuracyTrace = -1;
        accuracy14Trace = -1;
        if cookieTest == 1
            load('../dataset/cookie.mat');

            stepPatternTest = [];
            stepPatternTestLabel = [];
            stepPatternTestTrace = [];
            traceNum = length(cookie);
            %% start training on all different speed
            for traceID = 1:traceNum
                traceSig = cookie{traceID};
                traceSig = traceSig - mean(traceSig);
                traceSigFilter = signalDenoise(traceSig, 50);

                [ stepEventValue ,stepEventsIdx ] = findpeaks(traceSigFilter,'MinPeakDistance',200,'MinPeakHeight',50,'Annotate','extents');
                stepFrequency = (stepEventsIdx(2:end) - stepEventsIdx(1:end-1))./Fs;
                stepFrequency = stepFrequency(stepFrequency<1);
                stepFrequencyMean = mean(stepFrequency);

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

                    %% speed as pattend
    %               stepPatternTest =[stepPatternTest; Y'];
                    stepPatternTest =[stepPatternTest; stepFrequencyMean./8, Y'];
                    stepPatternTestLabel = [stepPatternTestLabel; cookieGT(ceil(traceID/2))];
                    stepPatternTestTrace = [stepPatternTestTrace; traceID];
                end
            end
            [predicted_label, accuracy, decision_values] = svmpredict(stepPatternTestLabel, stepPatternTest, svmstruct,'-b 1');
    %         predicted_label = floor(predicted_label./100);
            [ matrixResult ] = calConfusionMatrix( stepPatternTestLabel, predicted_label, numPeople )
            cookieStep = [cookieStep; [stepPatternTestLabel, predicted_label, max(decision_values,[],2), stepPatternTest(:,1).*8]];
            SC14 = 0;
            SA14 = 0;
            for si = 1 : 4
                SC14 = SC14 + matrixResult(si,si);
                SA14 = SA14 + sum(matrixResult(si,:));
            end
            accuracyStep = accuracy(1)/100;
            accuracyStep14 = SC14/SA14

            %% cookie trial 
            allStepNum = size(predicted_label,1);
            traceResult = [];
            for i = 1 : traceNum
                traceVote = predicted_label(stepPatternTestTrace == i , :);
                tempResult = mode(traceVote);
                traceResult = [traceResult; cookieGT(ceil(i/2)),tempResult, tempResult == cookieGT(ceil(i/2))]; 

            end
            accuracyTrace = sum(traceResult(:,3))/length(traceResult(:,3))

            [ matrixResult ] = calConfusionMatrix( traceResult(:,1), traceResult(:,2), numPeople )
            SC14 = 0;
            SA14 = 0;
            for si = 1 : 4
                SC14 = SC14 + matrixResult(si,si);
                SA14 = SA14 + sum(matrixResult(si,:));
            end
            accuracy14Trace = SC14/SA14

            matrixAll = matrixAll + matrixResult;

        end

        resultsSummary = [resultsSummary; allP1, allP2, accuracyStep, accuracyStep14, accuracyTrace, accuracy14Trace];
        save('results_cv8_portion.mat','resultsSummary','crossValid',...
            'trainingResultAll','traceResultAll','trainingTime',...
            'matrixAll','cookieStep','numPeople','portionID','trainingSize');
    end
    resultsSummary

    close all
    %% plot all
    allStepNum = size(trainingResultAll,1);
    for i = 1 : numPeople
        for j = 1 : numSpeed
            % store person speed accuracy
            PS{i,j} = zeros(numPeople);
        end
    end
    for stepID = 1 : allStepNum
        realID = trainingResultAll(stepID,1);
        realSpeed = trainingResultAll(stepID,2);
        estID = trainingResultAll(stepID,3);
        PS{realID,realSpeed}(realID,estID) = PS{realID,realSpeed}(realID,estID) + 1;
    end

    % step level results
    figure;
    allPC = 0;
    allPS = 0;
    allPC8 = 0;
    allPS8 = 0;
    for personID = 1: numPeople
        subplot(numPeople/2,2,personID);
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


    % trace level
    figure;
    allPC = 0;
    allPS = 0;
    allPC8 = 0;
    allPS8 = 0;
    for personID = 1: numPeople
        subplot(numPeople/2,2,personID);
        allCorrect = 0;
        allTrace = 0;
        speedAcc = zeros(numSpeed,1);
        for speedID = speedSequence(testingSpeedID)
            tempResult = traceResultAll(traceResultAll(:,1) == personID & traceResultAll(:,2) == speedID,4);
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

    if cookieTest == 1
        %% cookie confusion
        matrixAll = matrixAll./40;
        figure;
        imagesc(matrixAll);
        colormap(gray);
        % grid on;
        axis equal;

        textStrings = num2str(matrixAll(:),'%0.2f');  %# Create strings from the matrix values
        textStrings = strtrim(cellstr(textStrings));  %# Remove any space padding
        [x,y] = meshgrid(1:numPeople);   %# Create x and y coordinates for the strings
        hStrings = text(x(:),y(:),textStrings(:),...      %# Plot the strings
                        'HorizontalAlignment','center');
        midValue = mean(get(gca,'CLim'));  %# Get the middle value of the color range
        textColors = repmat(matrixAll(:) < midValue,1,3);  %# Choose white or black for the
                                                     %#   text color of the strings so
                                                     %#   they can be easily seen over
                                                     %#   the background color
        set(hStrings,{'Color'},num2cell(textColors,2));  %# Change the text colors

        set(gca,'XTick',1:6,...                         %# Change the axes tick marks
                'XTickLabel',{'1','2','3','4','5','6'},...  %#   and tick labels
                'YTick',1:6,...
                'YTickLabel',{'1','2','3','4','5','6'},...
                'TickLength',[0 0]);

         %% check the step confidence
         mean(cookieStep(cookieStep(:,1) ~= 5,3))
         mean(cookieStep(cookieStep(:,1) == 5,3))
         mean(cookieStep(:,4))
    end
end
mean(resultsSummary)
trainingSize
% resultCase = [];
% for i = 1 : 5 : 45
%     eachCase = mean(resultsSummary(i:i+4,:));
%     resultCase = [resultCase; eachCase([1,2,5,6])];
% end
% 
% figure;
% plot(resultCase);
