function [ stepSig ] = stepExtractionMultiTrace( traces )
%STEPEXTRACTIONMULTITRACE Summary of this function goes here
%   Detailed explanation goes here
    stepSig = [];
    traceNum = length(traces);
    for traceID = 1 : traceNum
        traceSig = traces{traceID,1};
        traceSigFilter = signalDenoise(traceSig, 50);
        
        [ stepEventValue ,stepEventsIdx ] = findpeaks(traceSigFilter,'MinPeakDistance',200,'MinPeakHeight',50,'Annotate','extents');
        [ selectedSteps ] = stepSelectionSNR( traceSigFilter, stepEventsIdx, WIN1, WIN2, 3 );
        stepEventsIdx = stepEventsIdx(selectedSteps);
        stepEventValue = stepEventValue(selectedSteps);
        stepNum = length(stepEventIdx);
        for stepID = 1 : stepNum
            stepSigSingle = traceSigFilter(stepEventsIdx(stepID)-WIN1+1:stepEventsIdx(stepID)+WIN2);
            stepSig = [stepSig; stepSigSingle];
        end
    end

end

