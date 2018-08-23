function [ selectedIdx ] = stepWindowSelection( stepEnergyArray, windowSize )
%STEPWINDOWSELECTION Summary of this function goes here
%   Detailed explanation goes here
    stepNum = length(stepEnergyArray);
    if stepNum <= windowSize
        selectedIdx = 1:stepNum;
    else
        averageStepEnergy = zeros(stepNum-windowSize+1,1);
        for i = 1:stepNum-windowSize+1
            averageStepEnergy(i) = mean(stepEnergyArray(i:i+windowSize-1));
        end
        [~, startIdx] = max(averageStepEnergy);
        selectedIdx = startIdx:startIdx+windowSize-1; 
    end
end

