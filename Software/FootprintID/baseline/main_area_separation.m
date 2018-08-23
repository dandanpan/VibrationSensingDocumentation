clear 
close all
clc

init();
configuration_setup;

%% cluster the steps with time domain distance
load('./dataset/steps.mat');
load('./dataset/step_time_cluster_all_020.mat');
load('./dataset/direction_info.mat');

stepInfoAll = [personIDLabel, speedIDLabel, traceIDLabel, stepIDLabel, zeros(length(personIDLabel),1)];

%% cluster ID assigned
clusterNum = length(clustersTime);
clusterEntropy = zeros(clusterNum,1);
for clusterID = 1:clusterNum
    clusterIdx = clustersTime{clusterID};
    clusterSigs = stepSigs(clusterIdx,:);
    clusterPatterns = stepPattern(clusterIdx,:);
    stepInfoAll(clusterIdx,5) = clusterID;
end

%% cluster area analysis
 for personID = 1:10
    area{1,personID} = [];
    area{2,personID} = [];
    area{3,personID} = [];
    area{4,personID} = [];
    area{5,personID} = [];
    for speedID = 1:8
        psIdx = find(directionInfo(:,1) == personID & directionInfo(:,2) == speedID);
        traceNum = max(directionInfo(psIdx,3));
        for traceID = 1:traceNum
            pstIdx = find(directionInfo(:,1) == personID & directionInfo(:,2) == speedID & directionInfo(:,3) == traceID);
            directionPST = directionInfo(pstIdx,4);
            if directionPST == 1
                pstarea1Idx = find(stepInfoAll(:,1) == personID & stepInfoAll(:,2) == speedID ... 
                                & stepInfoAll(:,3) == traceID & (stepInfoAll(:,4) == 1 | stepInfoAll(:,4) == 2 | stepInfoAll(:,4) == 3));
                area{1,personID} = [area{1,personID}; stepInfoAll(pstarea1Idx,:), pstarea1Idx];
                pstarea2Idx = find(stepInfoAll(:,1) == personID & stepInfoAll(:,2) == speedID ... 
                                & stepInfoAll(:,3) == traceID & (stepInfoAll(:,4) == 2 | stepInfoAll(:,4) == 3 | stepInfoAll(:,4) == 4));
                area{2,personID} = [area{2,personID}; stepInfoAll(pstarea2Idx,:), pstarea2Idx];
                pstarea3Idx = find(stepInfoAll(:,1) == personID & stepInfoAll(:,2) == speedID ... 
                                & stepInfoAll(:,3) == traceID & (stepInfoAll(:,4) == 3 | stepInfoAll(:,4) == 4 | stepInfoAll(:,4) == 5));
                area{3,personID} = [area{3,personID}; stepInfoAll(pstarea3Idx,:), pstarea3Idx];
                pstarea4Idx = find(stepInfoAll(:,1) == personID & stepInfoAll(:,2) == speedID ... 
                                & stepInfoAll(:,3) == traceID & (stepInfoAll(:,4) == 4 | stepInfoAll(:,4) == 5 | stepInfoAll(:,4) == 6));
                area{4,personID} = [area{4,personID}; stepInfoAll(pstarea4Idx,:), pstarea4Idx];
                pstarea5Idx = find(stepInfoAll(:,1) == personID & stepInfoAll(:,2) == speedID ... 
                                & stepInfoAll(:,3) == traceID & (stepInfoAll(:,4) == 5 | stepInfoAll(:,4) == 6 | stepInfoAll(:,4) == 7));
                area{5,personID} = [area{5,personID}; stepInfoAll(pstarea5Idx,:), pstarea5Idx];
            else
                pstarea1Idx = find(stepInfoAll(:,1) == personID & stepInfoAll(:,2) == speedID ... 
                                & stepInfoAll(:,3) == traceID & (stepInfoAll(:,4) == 7 | stepInfoAll(:,4) == 6 | stepInfoAll(:,4) == 5));
                area{1,personID} = [area{1,personID}; stepInfoAll(pstarea1Idx,:), pstarea1Idx];
                pstarea2Idx = find(stepInfoAll(:,1) == personID & stepInfoAll(:,2) == speedID ... 
                                & stepInfoAll(:,3) == traceID & (stepInfoAll(:,4) == 6 | stepInfoAll(:,4) == 5 | stepInfoAll(:,4) == 4));
                area{2,personID} = [area{2,personID}; stepInfoAll(pstarea2Idx,:), pstarea2Idx];
                pstarea3Idx = find(stepInfoAll(:,1) == personID & stepInfoAll(:,2) == speedID ... 
                                & stepInfoAll(:,3) == traceID & (stepInfoAll(:,4) == 5 | stepInfoAll(:,4) == 4 | stepInfoAll(:,4) == 3));
                area{3,personID} = [area{3,personID}; stepInfoAll(pstarea3Idx,:), pstarea3Idx];
                pstarea4Idx = find(stepInfoAll(:,1) == personID & stepInfoAll(:,2) == speedID ... 
                                & stepInfoAll(:,3) == traceID & (stepInfoAll(:,4) == 4 | stepInfoAll(:,4) == 3 | stepInfoAll(:,4) == 2));
                area{4,personID} = [area{4,personID}; stepInfoAll(pstarea4Idx,:), pstarea4Idx];
                pstarea5Idx = find(stepInfoAll(:,1) == personID & stepInfoAll(:,2) == speedID ... 
                                & stepInfoAll(:,3) == traceID & (stepInfoAll(:,4) == 3 | stepInfoAll(:,4) == 2 | stepInfoAll(:,4) == 1));
                area{5,personID} = [area{5,personID}; stepInfoAll(pstarea5Idx,:), pstarea5Idx];
            end
        end
    end
%     figure;
    % plot each person's cluster three area relation
    N = [myBin(area{1,personID}(:,5),clusterNum),myBin(area{3,personID}(:,5),clusterNum),myBin(area{5,personID}(:,5),clusterNum)];
    Nsum = sum(N, 2);
    nIdx{personID} = find(Nsum>3);
    N = N(nIdx{personID},:);
    figure;bar(N);
    title(['area person ' num2str(personID)]);
 end

%% cluster speed analysis
 for personID = 1:10
    speedInfo = [];
    for speedID = 1:8
        psIdx = find(stepInfoAll(:,1) == personID & stepInfoAll(:,2) == speedSequence(speedID));
        person_speed{personID,speedID} = stepInfoAll(psIdx,:);  
        speedInfo = [speedInfo, myBin(person_speed{personID,speedID}(:,5),clusterNum)];
    end
    N = speedInfo(nIdx{personID},:);
    figure;imagesc(N);
    title(['speed person ' num2str(personID)]);
 end

save('./dataset/area_step.mat','area');
