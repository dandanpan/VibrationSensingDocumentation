function [ peakLoc, peakVal ] = inStepPeakExtraction( stepSig, threshold )
%INSTEPPEAKEXTRACTION Summary of this function goes here
%   Detailed explanation goes here
    if nargin < 2
        threshold = 1/10;
    end
    
    [ maxVal ] = max(abs(stepSig));
    thresholdVal = maxVal * threshold;
    [~,  LOCS1] = findpeaks(stepSig, 'MinPeakHeight',thresholdVal);
    [~,  LOCS2] = findpeaks(-stepSig, 'MinPeakHeight',thresholdVal);
    peakLoc = union(LOCS1, LOCS2);
    peakVal = stepSig(peakLoc);

end

