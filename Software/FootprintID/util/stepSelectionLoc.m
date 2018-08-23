function [ selectedSteps ] = stepSelectionLoc( traceSig, stepIdx, win1, win2 )
%STEPSELECTION Summary of this function goes here
%   Detailed explanation goes here
    stepNum = length(stepIdx);
    stepEnergy = zeros(length(stepIdx),1);
    
    for stepID = 1 : stepNum
        if stepIdx(stepID)+win2 <= length(traceSig)
            stepSig = traceSig(stepIdx(stepID)-win1+1:stepIdx(stepID)+win2);
        else
            stepSig = traceSig(stepIdx(stepID)-win1-win2+1:end);
        end
        stepEnergy(stepID) = sum(stepSig.*stepSig);
    end
    
    % find the continuous 7 steps with highest signal energy
    groupStepEnergy = [];
   for stepIdx = 1:stepNum-6
        groupStepEnergy = [groupStepEnergy, sum(stepEnergy(stepIdx:stepIdx+6))];
   end
   [~, pI] = max(groupStepEnergy);
   selectedSteps = pI:pI+6;
end


