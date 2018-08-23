function [ stepLevelAcc, traceLevelAcc, traceCLevelAcc ] = accCal( estLabel, gtLabel, numInTrace )
%ACCCAL Summary of this function goes here
%   Detailed explanation goes here
    stepNum = length(estLabel);
    stepLevelAcc = sum(estLabel==gtLabel)/length(gtLabel);
    
    traceGT = [];
    traceEst = [];
    traceCEst = [];
    for i = 1:numInTrace:stepNum
        gt = mean(gtLabel(i:i+numInTrace-1));
        tEst = majorityVote(estLabel(i:i+numInTrace-1),ones(1,numInTrace));
        tCEst = estLabel(i+ceil(numInTrace/2)-1)
        traceGT = [traceGT, gt];
        traceCEst = [traceCEst, tCEst];
        traceEst = [traceEst, tEst];
    end

    traceLevelAcc = sum(traceEst==traceGT)/length(traceGT);
    traceCLevelAcc = sum(traceCEst==traceGT)/length(traceGT);
    
end

