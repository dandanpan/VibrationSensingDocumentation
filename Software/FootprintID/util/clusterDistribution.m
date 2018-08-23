function [ clusterDistr ] = clusterDistribution( clusters,numPeople,speedIDLabel, personIDLabel )
%CLUSTERDISTRIBUTION Summary of this function goes here
%   Detailed explanation goes here
    stepNum = length(personIDLabel);
    clusterNum = length(clusters);
    stepClusterID = zeros(stepNum,1);
    speedSequence = [7,6,5,1,2,3,4,8];
    numSpeed = length(speedSequence);
    clusterDistr = zeros(numPeople*(numSpeed+1),clusterNum);
    for clusterID = 1 : clusterNum
        clusterSet = clusters{clusterID};
        for clusterEleID = 1:length(clusterSet)
            eleID = clusterSet(clusterEleID);
            stepClusterID(eleID) = clusterID;
            matchID = (personIDLabel(eleID)-1)*(numSpeed+1)+speedSequence(speedIDLabel(eleID));
            clusterDistr(matchID,clusterID) = clusterDistr(matchID,clusterID) + 1;
        end
    end
    clusterDistr([(numSpeed+1):(numSpeed+1):end],:) = -1;


end

