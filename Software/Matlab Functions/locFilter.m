function [ reliableCandi ] = locFilter( locCandi )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    candidateNum = size(locCandi,2);
    blackList = [];
    for candiID = 1:candidateNum
        if locCandi(1,candiID) < 0.1 || locCandi(1,candiID) > 4.9 || locCandi(2,candiID) < -10 || locCandi(2,candiID) > 40
            blackList = [blackList, candiID];
        end
    end
    reliableCandi = locCandi;
    reliableCandi(:,blackList) = [];
end

