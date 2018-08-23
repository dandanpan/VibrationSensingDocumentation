clear all
close all
clc

load('./results_part_all.mat');
configuration_setup;

%% result analysis phase
% check the step level results
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
    estID = trainingResultAll(stepID,5);
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
    for speedID = speedSequence
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
    for speedID = speedSequence
        tempResult = traceResultAll(traceResultAll(:,1) == personID & traceResultAll(:,2) == speedID,4);
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

mean(resultsSummary)