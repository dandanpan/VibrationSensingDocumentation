function [ stepSig, newStepIdx ] = alignByFirstPeak( traceSig, detectedStepIdx, win1, win2 )
%ALIGNBYFIRSTPEAK Summary of this function goes here
%   Detailed explanation goes here
    tempStepSig = traceSig(detectedStepIdx-win1:detectedStepIdx+win2);
    MPH = max(tempStepSig)*0.4;
    [ ~ , peakIdx ] = findpeaks(tempStepSig,'MinPeakDistance',20,'MinPeakHeight',MPH,'Annotate','extents');
    if peakIdx(1) < win1+1
        % need to update first peak 
        newStepIdx = detectedStepIdx-win1+peakIdx;
    else
        newStepIdx = detectedStepIdx;
    end
    stepSig = traceSig(newStepIdx-win1:newStepIdx+win2);
end

