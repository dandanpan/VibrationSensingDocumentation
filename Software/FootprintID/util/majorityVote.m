function [ result ] = majorityVote( votes, weights )
%MAJORITYVOTE Summary of this function goes here
%   Detailed explanation goes here
    majorityChosen = 0;
    majorityNum = -1;
    majorityList = [];
    voteCopy = votes;
    
    % select the values 
    while ~isempty(votes)
        mostFreq = mode(votes);
        if find(votes==mostFreq) >= majorityNum
            majorityList = [majorityList, mostFreq];
            votes(votes== mostFreq) = [];
        else
            break;
        end
    end
    
    if length(majorityList) > 1
        maxWeight = -1;
        for i = 1:length(majorityList)
            weightTotal = sum(weights(voteCopy==majorityList(i)));
            if weightTotal > maxWeight
                maxWeight = weightTotal;
                result = majorityList(i);
            end
        end
    else
        result = majorityList;
    end

end

