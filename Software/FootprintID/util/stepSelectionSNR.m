function [ selectedSteps ] = stepSelectionSNR( traceSig, stepIdx, win1, win2, stepSelectionThresh )
%STEPSELECTION Summary of this function goes here
%   Detailed explanation goes here
    stepNum = length(stepIdx);
    [maxValue, mIndex] = max(traceSig);
    selectedSteps = [];
    if stepSelectionThresh > 1
        for stepID = 1 : stepNum
    %         stepSig = traceSig(stepIdx(stepID)-win1+1:stepIdx(stepID)+win2);
            if stepIdx(stepID)+win2 <= length(traceSig)
                stepSig = traceSig(stepIdx(stepID)-win1+1:stepIdx(stepID)+win2);
            else
                stepSig = traceSig(stepIdx(stepID)-win1-win2+1:end);
            end
            if max(stepSig) > maxValue/stepSelectionThresh;
                selectedSteps = [selectedSteps stepID];
            end
        end
    else
        for stepID = 1 : stepNum
    %         stepSig = traceSig(stepIdx(stepID)-win1+1:stepIdx(stepID)+win2);
            if stepIdx(stepID)+win2 <= length(traceSig)
                stepSig = traceSig(stepIdx(stepID)-win1+1:stepIdx(stepID)+win2);
            else
                stepSig = traceSig(stepIdx(stepID)-win1-win2+1:end);
            end
            if max(stepSig) >= maxValue/stepSelectionThresh;
                selectedSteps = [selectedSteps stepID];
                break;
            end
        end
%         selectedSteps = traceSig(mIndex-win1+1:mIndex+win2);
    end
   
   
end


