clear 
close all
clc
resultsSummary = [];
trainingResultAll = [];
traceResultAll = [];
crossValid = 1;
save('results_part_all.mat','resultsSummary','crossValid','trainingResultAll','traceResultAll');

for crossValid = 1 : 4
    save('results_part_all.mat','resultsSummary','crossValid','trainingResultAll','traceResultAll');
    clear
    load('results_part_all.mat');

    configuration_setup;

    trainingTraceID = [crossValid:crossValid+6];
    allTraceID = [1:10];
    testingTraceID = allTraceID(~ismember(allTraceID,trainingTraceID));
    plotTrace = 0;
    plotStep = 0;

    trainingFlag = 1;
    testingFlag = 1;
    analysisFlag = 1;
    
    for investigateSpeed = 1 : 8
        trainingSpeedID = [investigateSpeed];
        testingSpeedID = [investigateSpeed];
    

        if trainingFlag == 1
            %% training phase
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

                        % frequency domain
                        [ Y, f, NFFT] = signalFreqencyExtract( stepSig, Fs );
                        Y = Y(f<=cutoffFrequency);
                        f = f(f<=cutoffFrequency);
                        Y = signalNormalization(Y);
                        stepFCluster = [stepFCluster; Y];
                    end
                    clusterCharacter{personID, clusterID} = mean(stepFCluster);
        %             figure; plot(clusterCharacter{personID, clusterID});
                end
            end
        end

        %% testing phase
        if testingFlag == 1
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

                            %% matching for people/cluster
                            matchMaker = [];
                            for i = 1 : numPeople
                                for j = 1 : size(clusterCharacter, 2)
                                    if length(clusterCharacter{i,j}) > 0
        %                                 tempMatch = max(xcorr(Y,clusterCharacter{i,j}));
                                        tempMatch = 1 - sum((Y'-clusterCharacter{i,j}).*(Y'-clusterCharacter{i,j}));
                                        matchMaker = [matchMaker; i,j,tempMatch];
                                    end
                                end
                            end

                            % find top 1 and see the speed influence
                            [~, mostSimilarCluster] = max(matchMaker(:,3));
                            trainingResult = [trainingResult; personID,speedID,traceID,-1,matchMaker(mostSimilarCluster,:)];
                        end
                    end
                end
            end
        end

        if analysisFlag == 1;
            %% result analysis phase
            % check the step level results
            allStepNum = size(trainingResult,1);
            for i = 1 : numPeople
                for j = 1 : numSpeed
                    % store person speed accuracy
                    PS{i,j} = zeros(numPeople);
                end
            end
            for stepID = 1 : allStepNum
                realID = trainingResult(stepID,1);
                realSpeed = trainingResult(stepID,2);
                estID = trainingResult(stepID,5);
                PS{realID,realSpeed}(realID,estID) = PS{realID,realSpeed}(realID,estID) + 1;
            end

            % step level results
            figure;
            allPC = 0;
            allPS = 0;
            for personID = 1: numPeople
                if personID == 0
                    subplot(numPeople,1,personID);
                    allCorrect = 0;
                    halfCorrect = 0;
                    allStep = 0;
                    speedAcc = zeros(numSpeed,1);
                    halfAcc = zeros(numSpeed,1);
                    for speedID = speedSequence(testingSpeedID)
                        speedAcc(speedID) = ...
                            PS{personID, speedID}(personID,personID)/ ...
                            sum(PS{personID, speedID}(personID,:));
                        halfAcc(speedID) = ...
                            PS{personID, speedID}(personID,3)/ ...
                            sum(PS{personID, speedID}(personID,:));
                        allCorrect = allCorrect + PS{personID, speedID}(personID,personID);
                        halfCorrect = halfCorrect + PS{personID, speedID}(personID,3);
                        allStep = allStep + sum(PS{personID, speedID}(personID,:));
                    end
                    allPC = allPC + allCorrect;
                    allPS = allPS + allStep;
                    allAcc = allCorrect/allStep;
                    bar([speedAcc(speedSequence), halfAcc(speedSequence)]);hold on;
                    plot([0.5,8.5],[allAcc,allAcc],'r');
                    set(gca,'XtickLabel',{'-3\sigma', '-2\sigma', '-\sigma', '\mu','\sigma','2\sigma', '3\sigma','s'});
                    ylim([0,1]);
                    xlabel('Speed');
                    ylabel('Accuracy');
                    title(['Person ' num2str(personID)]);
                else
                    subplot(numPeople,1,personID);
                    allCorrect = 0;
                    allStep = 0;
                    speedAcc = zeros(numSpeed,1);
                    for speedID = speedSequence(testingSpeedID)
                        speedAcc(speedID) = ...
                            PS{personID, speedID}(personID,personID)/ ...
                            sum(PS{personID, speedID}(personID,:));
                        allCorrect = allCorrect + PS{personID, speedID}(personID,personID);
                        allStep = allStep + sum(PS{personID, speedID}(personID,:));
                    end
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
            end
            allP1 = allPC/allPS

            % majority vote 
            allStepNum = size(trainingResult,1);
            traceResult = [];
            for i = 1 : numPeople
                for j = 1 : numSpeed
                    resultSet = trainingResult(trainingResult(:,1) == i & trainingResult(:,2) == j, :);
                    % go through each trace
                    if i == 5  && j == 3
                        traceSet = testingTraceID(testingTraceID~=10);
                    else
                        traceSet = testingTraceID;
                    end
                    for traceID = traceSet
                        traceVote = resultSet(resultSet(:,3)==traceID,:);

                        tempResult = mode(traceVote(:,5));%*100+traceVote(:,6));

            %             [~,tempIdx] = max(traceVote(:,7));
            %             tempResult = traceVote(tempIdx,5);

                        traceResult = [traceResult; i,j,traceID,tempResult]; 
                    end
                end
            end

            % trace level results
            figure;
            allPC = 0;
            allPS = 0;

            for personID = 1: numPeople
                if personID == 0
                    subplot(numPeople,1,personID);
                    allCorrect = 0;
                    halfCorrect = 0;
                    allTrace = 0;
                    speedAcc = zeros(numSpeed,1);
                    halfAcc = zeros(numSpeed,1);
                    for speedID = speedSequence(testingSpeedID)
                        tempResult = traceResult(traceResult(:,1) == personID & traceResult(:,2) == speedID,4);
                        speedAcc(speedID) = sum(floor(tempResult) == personID)/length(tempResult);
                        halfAcc(speedID) = sum(floor(tempResult) == 3)/length(tempResult);
                        allCorrect = allCorrect + sum(floor(tempResult) == personID);
                        halfCorrect = halfCorrect + sum(floor(tempResult) == 3);
                        allTrace = allTrace + length(tempResult);
                    end
                    allPC = allPC + allCorrect;
                    allPS = allPS + allTrace;

                    allAcc = allCorrect/allTrace;
                    halfCorrect = halfCorrect/allTrace;
                    bar([speedAcc(speedSequence), halfAcc(speedSequence)]);hold on;
                    plot([0.5,8.5],[allAcc,allAcc],'r');
                    set(gca,'XtickLabel',{'-3\sigma', '-2\sigma', '-\sigma', '\mu','\sigma','2\sigma', '3\sigma','s'});
                    ylim([0,1]);
                    xlabel('Speed');
                    ylabel('Accuracy');
                    title(['Person ' num2str(personID)]);
                else
                    subplot(numPeople,1,personID);
                    allCorrect = 0;
                    allTrace = 0;
                    speedAcc = zeros(numSpeed,1);
                    for speedID = speedSequence(testingSpeedID)
                        tempResult = traceResult(traceResult(:,1) == personID & traceResult(:,2) == speedID,4);
                        speedAcc(speedID) = sum(floor(tempResult) == personID)/length(tempResult);
                        allCorrect = allCorrect + sum(floor(tempResult) == personID);
                        allTrace = allTrace + length(tempResult);
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
            end
            allP2 = allPC/allPS

        end
        resultsSummary = [resultsSummary; allP1, allP2];
        trainingResultAll = [trainingResultAll;trainingResult];
        traceResultAll = [traceResultAll; traceResult];
        save('results_part_all.mat','resultsSummary','crossValid','trainingResultAll','traceResultAll');

    end
end

resultsSummary


close all
if analysisFlag == 1;
    %% result analysis phase
    % check the step level results
    allStepNum = size(trainingResult,1);
    for i = 1 : numPeople
        for j = 1 : numSpeed
            % store person speed accuracy
            PS{i,j} = zeros(numPeople);
        end
    end
    for stepID = 1 : allStepNum
        realID = trainingResult(stepID,1);
        realSpeed = trainingResult(stepID,2);
        estID = trainingResult(stepID,5);
        PS{realID,realSpeed}(realID,estID) = PS{realID,realSpeed}(realID,estID) + 1;
    end

    % step level results
    figure;
    allPC = 0;
    allPS = 0;
    for personID = 1: numPeople
        if personID == 0
            subplot(numPeople,1,personID);
            allCorrect = 0;
            halfCorrect = 0;
            allStep = 0;
            speedAcc = zeros(numSpeed,1);
            halfAcc = zeros(numSpeed,1);
            for speedID = speedSequence
                speedAcc(speedID) = ...
                    PS{personID, speedID}(personID,personID)/ ...
                    sum(PS{personID, speedID}(personID,:));
                halfAcc(speedID) = ...
                    PS{personID, speedID}(personID,3)/ ...
                    sum(PS{personID, speedID}(personID,:));
                allCorrect = allCorrect + PS{personID, speedID}(personID,personID);
                halfCorrect = halfCorrect + PS{personID, speedID}(personID,3);
                allStep = allStep + sum(PS{personID, speedID}(personID,:));
            end
            allPC = allPC + allCorrect;
            allPS = allPS + allStep;
            allAcc = allCorrect/allStep;
            bar([speedAcc(speedSequence), halfAcc(speedSequence)]);hold on;
            plot([0.5,8.5],[allAcc,allAcc],'r');
            set(gca,'XtickLabel',{'-3\sigma', '-2\sigma', '-\sigma', '\mu','\sigma','2\sigma', '3\sigma','s'});
            ylim([0,1]);
            xlabel('Speed');
            ylabel('Accuracy');
            title(['Person ' num2str(personID)]);
        else
            subplot(numPeople,1,personID);
            allCorrect = 0;
            allStep = 0;
            speedAcc = zeros(numSpeed,1);
            for speedID = speedSequence
                speedAcc(speedID) = ...
                    PS{personID, speedID}(personID,personID)/ ...
                    sum(PS{personID, speedID}(personID,:));
                allCorrect = allCorrect + PS{personID, speedID}(personID,personID);
                allStep = allStep + sum(PS{personID, speedID}(personID,:));
            end
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
    end
    allP1 = allPC/allPS

    % majority vote 
    allStepNum = size(trainingResult,1);
    traceResult = [];
    for i = 1 : numPeople
        for j = 1 : numSpeed
            resultSet = trainingResultAll(trainingResultAll(:,1) == i & trainingResultAll(:,2) == j, :);
            % go through each trace
            if i == 5  && j == 3
                traceSet = testingTraceID(testingTraceID~=10);
            else
                traceSet = testingTraceID;
            end
            for traceID = traceSet
                traceVote = resultSet(resultSet(:,3)==traceID,:);

                tempResult = mode(traceVote(:,5));%*100+traceVote(:,6));

    %             [~,tempIdx] = max(traceVote(:,7));
    %             tempResult = traceVote(tempIdx,5);

                traceResult = [traceResult; i,j,traceID,tempResult]; 
            end
        end
    end

    % trace level results
    figure;
    allPC = 0;
    allPS = 0;

    for personID = 1: numPeople
        if personID == 0
            subplot(numPeople,1,personID);
            allCorrect = 0;
            halfCorrect = 0;
            allTrace = 0;
            speedAcc = zeros(numSpeed,1);
            halfAcc = zeros(numSpeed,1);
            for speedID = speedSequence
                tempResult = traceResult(traceResult(:,1) == personID & traceResult(:,2) == speedID,4);
                speedAcc(speedID) = sum(floor(tempResult) == personID)/length(tempResult);
                halfAcc(speedID) = sum(floor(tempResult) == 3)/length(tempResult);
                allCorrect = allCorrect + sum(floor(tempResult) == personID);
                halfCorrect = halfCorrect + sum(floor(tempResult) == 3);
                allTrace = allTrace + length(tempResult);
            end
            allPC = allPC + allCorrect;
            allPS = allPS + allTrace;

            allAcc = allCorrect/allTrace;
            halfCorrect = halfCorrect/allTrace;
            bar([speedAcc(speedSequence), halfAcc(speedSequence)]);hold on;
            plot([0.5,8.5],[allAcc,allAcc],'r');
            set(gca,'XtickLabel',{'-3\sigma', '-2\sigma', '-\sigma', '\mu','\sigma','2\sigma', '3\sigma','s'});
            ylim([0,1]);
            xlabel('Speed');
            ylabel('Accuracy');
            title(['Person ' num2str(personID)]);
        else
            subplot(numPeople,1,personID);
            allCorrect = 0;
            allTrace = 0;
            speedAcc = zeros(numSpeed,1);
            for speedID = speedSequence
                tempResult = traceResult(traceResult(:,1) == personID & traceResult(:,2) == speedID,4);
                speedAcc(speedID) = sum(floor(tempResult) == personID)/length(tempResult);
                allCorrect = allCorrect + sum(floor(tempResult) == personID);
                allTrace = allTrace + length(tempResult);
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
    end
    allP2 = allPC/allPS

end
