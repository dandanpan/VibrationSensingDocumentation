function [ firstPeakIdx, firstPeakVal ] = firstPeakExtraction( signal, threshold )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    % find highest peak value
    % calculate minimum peak value threshold based on that
    [maxVal, maxIdx] = max(abs(signal));
    thresholdVal = maxVal * threshold;
    [~,  LOCS1] = findpeaks(signal, 'MinPeakHeight',thresholdVal);
    [~,  LOCS2] = findpeaks(-signal, 'MinPeakHeight',thresholdVal);
    if ~isempty([LOCS1; LOCS2])
        firstPeakIdx = min([LOCS1; LOCS2]);
    else
        firstPeakIdx = maxIdx;
    end
    firstPeakVal = signal(firstPeakIdx);
end

