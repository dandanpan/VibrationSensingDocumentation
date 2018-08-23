clear 
close all
clc

init();
configuration_setup;

%% cluster the steps with time domain distance
load('./dataset/steps.mat');
load('./dataset/step_time_cluster_all_020.mat');
load('./dataset/direction_info.mat');

%% cluster - person analysis (training)
 for personID = 1:10
    for speedID = [1,4,7]
        psIdx = find(directionInfo(:,1) == personID & directionInfo(:,2) == speedSequence(speedID));
        traceNum = max(directionInfo(psIdx,3));
        for traceID = 1:traceNum
            pstIdx = find(directionInfo(:,1) == personID & directionInfo(:,2) == speedID & directionInfo(:,3) == traceID);
            directionPST = directionInfo(pstIdx,4);
            if directionPST == 1
                pstarea1Idx = find(stepInfoAll(:,1) == personID & stepInfoAll(:,2) == speedID ... 
                                & stepInfoAll(:,3) == traceID & (stepInfoAll(:,4) == 1 | stepInfoAll(:,4) == 2 | stepInfoAll(:,4) == 3));
                area1{personID} = [area1{personID}; stepInfoAll(pstarea1Idx,:)];
                pstarea2Idx = find(stepInfoAll(:,1) == personID & stepInfoAll(:,2) == speedID ... 
                                & stepInfoAll(:,3) == traceID & (stepInfoAll(:,4) == 3 | stepInfoAll(:,4) == 4 | stepInfoAll(:,4) == 5));
                area2{personID} = [area2{personID}; stepInfoAll(pstarea2Idx,:)];
                pstarea3Idx = find(stepInfoAll(:,1) == personID & stepInfoAll(:,2) == speedID ... 
                                & stepInfoAll(:,3) == traceID & (stepInfoAll(:,4) == 5 | stepInfoAll(:,4) == 6 | stepInfoAll(:,4) == 7));
                area3{personID} = [area3{personID}; stepInfoAll(pstarea3Idx,:)];
            else
                pstarea1Idx = find(stepInfoAll(:,1) == personID & stepInfoAll(:,2) == speedID ... 
                                & stepInfoAll(:,3) == traceID & (stepInfoAll(:,4) == 7 | stepInfoAll(:,4) == 6 | stepInfoAll(:,4) == 5));
                area1{personID} = [area1{personID}; stepInfoAll(pstarea1Idx,:)];
                pstarea2Idx = find(stepInfoAll(:,1) == personID & stepInfoAll(:,2) == speedID ... 
                                & stepInfoAll(:,3) == traceID & (stepInfoAll(:,4) == 3 | stepInfoAll(:,4) == 4 | stepInfoAll(:,4) == 5));
                area2{personID} = [area2{personID}; stepInfoAll(pstarea2Idx,:)];
                pstarea3Idx = find(stepInfoAll(:,1) == personID & stepInfoAll(:,2) == speedID ... 
                                & stepInfoAll(:,3) == traceID & (stepInfoAll(:,4) == 3 | stepInfoAll(:,4) == 2 | stepInfoAll(:,4) == 1));
                area3{personID} = [area3{personID}; stepInfoAll(pstarea3Idx,:)];
            end
        end
    end
%     figure;
    % plot each person's cluster three area relation
    N = [myBin(area1{personID}(:,5),clusterNum),myBin(area2{personID}(:,5),clusterNum),myBin(area3{personID}(:,5),clusterNum)];
    Nsum = sum(N, 2);
    nIdx{personID} = find(Nsum>3);
    N = N(nIdx{personID},:);
    figure;bar(N);
    title(['area person ' num2str(personID)]);
 end

%% cluster speed analysis
 for personID = 1%:10
    clusterNum = 100;
    speedInfo = [];
    for speedID = 1:8
        psIdx = find(stepInfoAll(:,1) == personID & stepInfoAll(:,2) == speedSequence(speedID));
        person_speed{personID,speedID} = stepInfoAll(psIdx,:);  
        speedInfo = [speedInfo, myBin(person_speed{personID,speedID}(:,6),clusterNum)];
    end
    N = speedInfo(nIdx{personID},:);
    figure;imagesc(N);
    title(['speed person ' num2str(personID)]);
 end


