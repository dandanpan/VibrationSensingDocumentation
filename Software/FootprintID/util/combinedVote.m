function [ maxPro ] = combinedVote( stepVote, weights, traceVote, distance, entropy )
%COMBINEDVOTE Summary of this function goes here
%   Detailed explanation goes here
    histTable = zeros(10,1); % 10 is the number of classes
    for stepIdx = 1:length(stepVote)
        if ~isempty(distance(traceVote == stepVote(stepIdx)))
            histTable(stepVote(stepIdx)) = histTable(stepVote(stepIdx)) + 1 + distance(traceVote == stepVote(stepIdx));
        else
            histTable(stepVote(stepIdx)) = histTable(stepVote(stepIdx)) + 1;
        end
    end
    [maxVal, maxPro] = max(histTable);
    
%     if find(histTable == maxVal) > 1
%         maxWeight = -1;
%         for i = 1:length(majorityList)
%             weightTotal = sum(weights(voteCopy==majorityList(i)));
%             if weightTotal > maxWeight
%                 maxWeight = weightTotal;
%                 result = majorityList(i);
%             end
%         end
%     else
%         
%     end

end

