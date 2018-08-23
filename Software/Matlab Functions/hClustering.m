function [ clusters, nodeContainsLeave ] = hClustering( eventFeatures, draw, distanceThreshold )
%STEPSELECTION Summary of this function goes here
%   Detailed explanation goes here
    if nargin == 1
        draw = 0;
        distanceThreshold = 0.02;
    elseif nargin == 2
        distanceThreshold = 0.02;
    end
    eventNum = size(eventFeatures, 1);
    distanceMatrix = zeros(eventNum);
    clusters = cell(1);
    clusterCount = 1;
%     distanceThreshold = 0.16;
    Y = [];
    for stepID = 1 : eventNum
        for compareID = stepID + 1 : eventNum
            stepSig1 = eventFeatures(stepID,:);
            stepSig2 = eventFeatures(compareID,:);
            temp = sum((stepSig1-stepSig2).^2);
            distanceMatrix(stepID, compareID) = temp;
            distanceMatrix(compareID, stepID) = temp;
            Y = [Y, temp];
        end
    end
    Z = linkage(Y, 'average');
    I = inconsistent(Z);
    if draw == 1
        dendrogram(Z);
    end
    linkNum = size(Z,1);
    leaveStatus = [1:eventNum];
    nodeStatus = [eventNum+1:eventNum+linkNum; zeros(1,linkNum)];
    nodeContainsLeave = cell(1,linkNum);
    for i = 1 : linkNum
        if ismember(Z(i,1),leaveStatus) && ismember(Z(i,2),leaveStatus)
            nodeStatus(2,i) = 2;
            nodeContainsLeave{i} = [Z(i,1), Z(i,2)];
%             if Z(i,3) > distanceThreshold 
%                 clusters{clusterCount} = nodeContainsLeave{i};
%                 clusterCount = clusterCount + 1;
%             end
        elseif ismember(Z(i,1),leaveStatus) 
            % find the last node location
            [~,loc] = find(nodeStatus(1,:)==Z(i,2));
            nodeStatus(2,i) = 1+nodeStatus(2,loc);
            nodeContainsLeave{i} = [nodeContainsLeave{loc}, Z(i,1)];
            if Z(i,3) > distanceThreshold && Z(loc,3) < distanceThreshold
                clusters{clusterCount} = nodeContainsLeave{loc};
                clusterCount = clusterCount + 1;
            end
        else
            [~,loc1] = find(nodeStatus(1,:)==Z(i,1));
            [~,loc2] = find(nodeStatus(1,:)==Z(i,2));
            nodeStatus(2,i) = nodeStatus(2,loc1)+nodeStatus(2,loc2);
            nodeContainsLeave{i} = [nodeContainsLeave{loc1}, nodeContainsLeave{loc2}];
            if Z(i,3) > distanceThreshold && Z(loc1,3) < distanceThreshold && Z(loc2,3) < distanceThreshold
                clusters{clusterCount} = nodeContainsLeave{loc1};
                clusterCount = clusterCount + 1;
                clusters{clusterCount} = nodeContainsLeave{loc2};
                clusterCount = clusterCount + 1;
            elseif Z(i,3) > distanceThreshold && Z(loc1,3) < distanceThreshold
                clusters{clusterCount} = nodeContainsLeave{loc1};
                clusterCount = clusterCount + 1;
            elseif Z(i,3) > distanceThreshold && Z(loc2,3) < distanceThreshold
                clusters{clusterCount} = nodeContainsLeave{loc2};
                clusterCount = clusterCount + 1;
            end
        end
        
    end
    if isempty(clusters{1})
        clusters{1} = leaveStatus;
    end

end


