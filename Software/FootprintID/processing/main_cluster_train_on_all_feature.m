trainingPhaseFlag = 0;
testingPhaseFlag = 1;
analyzeResultFlag = 1;
%% training phase
if trainingPhaseFlag == 1
    configuration_setup;
    trainingTraceID = [1:5];
    allTraceID = [1:10];
    testingTraceID = allTraceID(~ismember(allTraceID,trainingTraceID));

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
        for speedID = speedSequence %1 : numSpeed
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
            figure; plot(clusterCharacter{personID, clusterID});
        end
    end
end

% %% testing phase
% if testingPhaseFlag == 1
% %     addpath('./libsvm-master/matlab');
%     trainingResult = [];
%     for personID = 1 : numPeople
%         load(['../dataset/P' num2str(personID) '.mat']);
%         Signals = P{personID}.Sen{sensorID}.S;
% 
%         for speedID = speedSequence
%             traces = Signals{speedID};
% 
%             %% start training on all different speed
%             for traceID = testingTraceID
%                 fprintf(['trace ' num2str(traceID) '\n']);
%                 if traceID > length(traces)
%                     continue;
%                 end
%                 traceSig = traces{traceID,1};
%                 traceSigFilter = signalDenoise(traceSig, 50);
% 
%                 [ stepEventValue ,stepEventsIdx ] = findpeaks(traceSigFilter,'MinPeakDistance',200,'MinPeakHeight',50,'Annotate','extents');
%                 stepFrequency = (stepEventsIdx(2:end) - stepEventsIdx(1:end-1))./Fs;
%                 stepFrequency = stepFrequency(stepFrequency<1);
%                 stepFrequencyMean = mean(stepFrequency);
%                 % filter out-of-range steps
%                 stepEventValue = stepEventValue(stepEventsIdx > WIN1 & stepEventsIdx < length(traceSigFilter)-WIN2);
%                 stepEventsIdx = stepEventsIdx(stepEventsIdx > WIN1 & stepEventsIdx < length(traceSigFilter)-WIN2);
%                 % select steps by energy
%                 [ selectedSteps ] = stepSelectionSNR( traceSigFilter, stepEventsIdx, WIN1, WIN2, 3 );
%                 stepEventsIdx = stepEventsIdx(selectedSteps);
%                 stepEventValue = stepEventValue(selectedSteps);
% 
%                 for stepID = 1 : length(stepEventsIdx)
%                     % find first peak
%                     tempSig = traceSigFilter(stepEventsIdx(stepID)-WIN1+1:stepEventsIdx(stepID)+WIN2);
%                     tempThresh = max(tempSig)/1.1;
%                     [ tempV ,tempI ] = findpeaks(tempSig,'MinPeakDistance',20,'MinPeakHeight',tempThresh,'Annotate','extents');
%                     tempIndex = stepEventsIdx(stepID)-WIN1+1+tempI(1);
%                     % extract step
%                     stepSig = traceSigFilter(tempIndex-WIN1+1:tempIndex+WIN2);
%                     stepSig = signalNormalization(stepSig);
% 
% %                     % frequency domain
% %                     [ Y, f, NFFT] = signalFreqencyExtract( stepSig, Fs );
% %                     Y = Y(f<=cutoffFrequency);
% %                     f = f(f<=cutoffFrequency);
% %                     Y = signalNormalization(Y);
% 
%                     %% matching for people/cluster
%                     matchMaker = [];
%                     for i = 1 : numPeople
%                         for j = 1 : size(clusterCharacter, 2)
%                             if length(clusterCharacter{i,j}) > 0
%                                 tempMatch = max(xcorr(Y,clusterCharacter{i,j}));
%                                 matchMaker = [matchMaker; i,j,tempMatch];
%                             end
%                         end
%                     end
% 
%                     % find top 5 and look at details
%                     [soredXcorrV, soredXcorrI]= sort(matchMaker(:,3),'descend');
%                     threshold = (max(soredXcorrV)-min(soredXcorrV))/2+min(soredXcorrV);
%                     soredXcorrI = soredXcorrI(soredXcorrV > threshold);
%                     soredXcorrV = soredXcorrV(soredXcorrV > threshold);
% %                     soredXcorrV = soredXcorrV(1:clusterSelectNum);
% %                     soredXcorrI = soredXcorrI(1:clusterSelectNum);
%                     selectedClusters = matchMaker(soredXcorrI,:);
%                     
%                     %% train a small scaled classifier on selected clusters
%                     % gather all steps
%                     selectedStepsFeature = [];
%                     selectedStepsLabel = [];
%                     clusterSimilaritySet = [];
%                     for i = 1 : clusterSelectNum
%                         personLabel = selectedClusters(i,1);
%                         clusterLabel = selectedClusters(i,2);
%                         clusterSimilarity = selectedClusters(i,3);
%                         sCluster = personModel{personLabel}.clusters{clusterLabel};
%                         for j = 1 : length(sCluster)
%                             selectedStep = personModel{personLabel}.stepSigs(sCluster(j),:);
%                             selectedSpeed = personModel{personLabel}.stepFrequencySet(sCluster(j));
%                             singleStepFeature = [selectedSpeed];
% %                             level = 6;
% %                             wpt = wpdec(selectedStep,level,'bior3.7'); 
% %                             [Spec,Time,Freq] = wpspectrum(wpt, Fs);
% %                             % select scale 45:64 
% %                             for k = 45:64
% %                                 scaleBand = Spec(k,:);
% %                                 singleStepFeature = [singleStepFeature, spectrumFeatures( scaleBand )];
% %                             end
%                             selectedStepsFeature = [selectedStepsFeature; singleStepFeature];
%                             selectedStepsLabel = [selectedStepsLabel; personLabel*20+clusterLabel ];
%                         end
%                         clusterSimilaritySet = [clusterSimilaritySet, clusterSimilarity];
%                     end
%                     %% extract features for the selected step
%                     testFeature = [];
%                     testFeature = [testFeature, stepFrequencyMean];
% %                     level = 6;
% %                     wpt = wpdec(stepSig,level,'bior3.7'); 
% %                     [Spec,Time,Freq] = wpspectrum(wpt, Fs);
% %                     % select scale 45:64 
% %                     for k = 45:64
% %                         scaleBand = Spec(k,:);
% %                         testFeature = [testFeature, spectrumFeatures( scaleBand )];
% %                     end
%                     testLabel = stepLearning(selectedStepsFeature, selectedStepsLabel, testFeature, clusterSimilaritySet);
%                     trainingResult = [trainingResult; personID, speedID, traceID, -1, testLabel];
%                 end
%             end
% 
%         end
%     end
%     save('trainingResult.mat','trainingResult');
% end

%% testing phase
if testingPhaseFlag == 1
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

if analyzeResultFlag == 1
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
        estID = floor(trainingResult(stepID,5)/20);
        PS{realID,realSpeed}(realID,estID) = PS{realID,realSpeed}(realID,estID) + 1;
    end

    % step level results
    figure;
    for personID = 1: numPeople
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
        allAcc = allCorrect/allStep;
        bar(speedAcc);hold on;
        plot([0.5,8.5],[allAcc,allAcc],'r');
        set(gca,'XtickLabel',{'-3\sigma', '-2\sigma', '-\sigma', '\mu','\sigma','2\sigma', '3\sigma','s'});
        ylim([0,1]);
        xlabel('Speed');
        ylabel('Accuracy');
        title(['Person ' num2str(personID)]);
    end

    % majority vote 
    allStepNum = size(trainingResult,1);
    traceResult = [];
    for i = 1 : numPeople
        for j = 1 : numSpeed
            resultSet = trainingResult(trainingResult(:,1) == i & trainingResult(:,2) == j, :);
            % go through each trace
            if i == 5  && j == 3
                traceSet = [6:9];
            else
                traceSet = testingTraceID;
            end
            for traceID = traceSet
                traceVote = resultSet(resultSet(:,3)==traceID,:);

                tempResult = mode(traceVote(:,5));

    %             [~,tempIdx] = max(traceVote(:,7));
    %             tempResult = traceVote(tempIdx,5);

                traceResult = [traceResult; i,j,traceID,tempResult]; 
            end
        end
    end

    % trace level results
    figure;
    for personID = 1: numPeople
        subplot(numPeople,1,personID);
        allCorrect = 0;
        allTrace = 0;
        speedAcc = zeros(numSpeed,1);
        for speedID = speedSequence
            tempResult = traceResult(traceResult(:,1) == personID & traceResult(:,2) == speedID,4);
            speedAcc(speedID) = sum(tempResult == personID)/length(tempResult);
            allCorrect = allCorrect + sum(tempResult == personID);
            allTrace = allTrace + length(tempResult);
        end
        allAcc = allCorrect/allTrace;
        bar(speedAcc);hold on;
        plot([0.5,8.5],[allAcc,allAcc],'r');
        set(gca,'XtickLabel',{'-3\sigma', '-2\sigma', '-\sigma', '\mu','\sigma','2\sigma', '3\sigma','s'});
        ylim([0,1]);
        xlabel('Speed');
        ylabel('Accuracy');
        title(['Person ' num2str(personID)]);
    end
end


