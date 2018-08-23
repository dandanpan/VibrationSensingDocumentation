function [clusterSummary, stepClusterID] = clusterVisualization(clusters,numPeople,speedIDLabel, personIDLabel,stepNum)

    clusterNum = length(clusters);
    stepClusterID = zeros(stepNum,1);
    speedSequence = [7,6,5,1,2,3,4,8];
    numSpeed = length(speedSequence);
    clusterSummary = zeros(numPeople*(numSpeed+1),clusterNum);
    for clusterID = 1 : clusterNum
        clusterSet = clusters{clusterID};
        for clusterEleID = 1:length(clusterSet)
            eleID = clusterSet(clusterEleID);
            stepClusterID(eleID) = clusterID;
            matchID = (personIDLabel(eleID)-1)*(numSpeed+1)+speedSequence(speedIDLabel(eleID));
            clusterSummary(matchID,clusterID) = clusterSummary(matchID,clusterID) + 1;
        end
    end
    clusterSummary([(numSpeed+1):(numSpeed+1):end],:) = -1;
end