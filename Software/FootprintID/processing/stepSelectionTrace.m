function [ selectedSteps ] = stepSelectionTrace( traceSig, stepIdx, win1, win2, stepSelectionNum, draw )
%STEPSELECTION Summary of this function goes here
%   Detailed explanation goes here
    if nargin == 5
        draw = 0;
    end
    stepNum = length(stepIdx);
    distanceMatrix = zeros(stepNum);
    Y = [];
    for stepID = 1 : stepNum
        for compareID = stepID + 1 : stepNum
            stepSig1 = traceSig(stepIdx(stepID)-win1+1:stepIdx(stepID)+win2);
            stepSig2 = traceSig(stepIdx(compareID)-win1+1:stepIdx(compareID)+win2);
            stepSig1 = signalNormalization(stepSig1);
            stepSig2 = signalNormalization(stepSig2);
            temp = max(abs(xcorr(stepSig1,stepSig2)));
            distanceMatrix(stepID, compareID) = temp;
            distanceMatrix(compareID, stepID) = temp;
            Y = [Y, 1-temp];
        end
    end
    Z = linkage(Y, 'average');
    I = inconsistent(Z);
    if draw == 1
        dendrogram(Z);
    end
    linkNum = size(Z,1);
    leaveStatus = [1:stepNum];
    nodeStatus = [stepNum+1:stepNum+linkNum; zeros(1,linkNum)];
    nodeContainsLeave = cell(1,linkNum);
    for i = 1 : linkNum
        if ismember(Z(i,1),leaveStatus) && ismember(Z(i,2),leaveStatus)
            nodeStatus(2,i) = 2;
            nodeContainsLeave{i} = [Z(i,1), Z(i,2)];
        elseif ismember(Z(i,1),leaveStatus) 
            % find the last node location
            [~,loc] = find(nodeStatus(1,:)==Z(i,2));
            nodeStatus(2,i) = 1+nodeStatus(2,loc);
            nodeContainsLeave{i} = [nodeContainsLeave{loc}, Z(i,1)];
        else
            [~,loc1] = find(nodeStatus(1,:)==Z(i,1));
            [~,loc2] = find(nodeStatus(1,:)==Z(i,2));
            nodeStatus(2,i) = nodeStatus(2,loc1)+nodeStatus(2,loc2);
            nodeContainsLeave{i} = [nodeContainsLeave{loc1}, nodeContainsLeave{loc2}];
        end
    end
    for i = 2 : linkNum
        if (nodeStatus(2,i) >= stepSelectionNum)
            selectedSteps = nodeContainsLeave{i};
            break;
        end
    end
end


