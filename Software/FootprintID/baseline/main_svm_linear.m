clear 
close all
clc

init();
resultsSummary = cell(5);
gSet = [0.001,0.01,0.1,1,10];%5
cSet = [1 10 100 1000 10000];%4
trainingSpeedID = [8];
testingSpeedID = [8];
trainingResultAll = [];
traceResultAll = [];
crossValid = 1;
gID = 1;
cID = 1;
save('baseline_svm_linear.mat','resultsSummary','crossValid',...
    'trainingResultAll','traceResultAll','trainingSpeedID',...
    'testingSpeedID','gSet','cSet','gID','cID');
for gID = 1 : 5
    for cID = 1 : 5
        for crossValid = 1 : 4
            save('baseline_svm_linear.mat','resultsSummary','crossValid', ...
                'trainingResultAll','traceResultAll','trainingSpeedID',...
                'testingSpeedID','gSet','cSet','gID','cID');
            clear
            load('baseline_svm_linear.mat');

            configuration_setup;
            addpath('./libsvm-master/matlab/');
            
            trainingTraceID = [crossValid:crossValid+6];
            allTraceID = [1:10];
            testingTraceID = allTraceID(~ismember(allTraceID,trainingTraceID));

            trainingFlag = 1;
            testingFlag = 1;
            analysisFlag = 1;

            if trainingFlag == 1
                % training phase
                stepPatternTrainLabel = [];
                stepPatternTrain = [];
                for personID = 1 : numPeople
                    load(['./dataset/P' num2str(personID) '.mat']);

                    stepSigs = [];
                    stepSigsLabel = [];   
                    personIDLabel = [];   
                    speedIDLabel = [];    
                    traceIDLabel = []; 
                    stepIdxLabel = [];
                    traceSigs = [];
                    traceSigsLabel = [];
                    traceCount = 0;
                    speedCount = 0;
                    Signals = P{personID}.Sen{sensorID}.S;

                    speedID = 8;
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
                            
                            % frequency domain
                            [ Y, f, NFFT] = signalFreqencyExtract( stepSig, Fs );
                            Y = Y(f<=cutoffFrequency);
                            f = f(f<=cutoffFrequency);
                            Y = signalNormalization(Y);
                            stepPatternTrain = [stepPatternTrain; Y'];
                            stepPatternTrainLabel = [stepPatternTrainLabel; personID];
                            
                        end
                    end
                end
            end

            svmstruct = svmtrain(stepPatternTrainLabel, stepPatternTrain, ['-s 0 -t 0 -b 1 -g ' num2str(gSet(gID)) ' -c ' num2str(cSet(cID)) ]);

            if testingFlag == 1
            %% testing phase
                stepPatternTest = [];
                stepPatternTestLabel = [];
                stepPatternTestSpeed = [];
                stepPatternTestTrace = [];
                trainingResult = [];
                for personID = 1 : numPeople
                    load(['./dataset/P' num2str(personID) '.mat']);
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

            end
            
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
                allPC8 = 0;
                allPS8 = 0;
                for personID = 1: numPeople
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
                    allPC8 = allPC8 + PS{personID, 8}(personID,personID);
                    allPS8 = allPS8 + sum(PS{personID, 8}(personID,:)); 
                    allAcc = allCorrect/allStep;
                end
                stepLevelAccuracy = allPC8/allPS8;


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
%                         if i == 5  && j == 3
%                             traceSet = testingTraceID(testingTraceID~=10);
%                         else
%                             traceSet = testingTraceID;
%                         end
                        for traceID = testingTraceID%traceSet
                            traceVote = resultSet(resultTrace==traceID,:);
                            tempResult = mode(traceVote);
                            traceResult = [traceResult; i,j,traceID,tempResult]; 
                        end
                    end
                end
                traceResultAll = [traceResultAll; traceResult];
                % trace level results
                allPC8 = 0;
                allPS8 = 0;
                for personID = 1: numPeople
                    allCorrect = 0;
                    allTrace = 0;
                    speedAcc = zeros(numSpeed,1);
                    for speedID = speedSequence(testingSpeedID)
                        tempResult = traceResult(traceResult(:,1) == personID & traceResult(:,2) == speedID,4);
                        speedAcc(speedID) = sum(tempResult == personID)/length(tempResult);
                        allCorrect = allCorrect + sum(tempResult == personID);
                        allTrace = allTrace + length(tempResult);
                        if speedID == 8
                            allPC8 = allPC8 + sum(tempResult == personID);
                            allPS8 = allPS8 + length(tempResult);
                        end
                    end
                    allAcc = allCorrect/allTrace;
                end
                traceLevelAccuracy = allPC8/allPS8;
            
            end
            
            resultsSummary{gID,cID} = [resultsSummary{gID,cID}; stepLevelAccuracy, traceLevelAccuracy];
            save('baseline_svm_linear.mat','resultsSummary','crossValid', ...
                'trainingResultAll','traceResultAll','gSet','cSet','gID','cID');
        end
    end
end