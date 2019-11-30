function [ firstPeakIdx, firstPeakVal ] = SelectPossiblePeaks( signal, threshold )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    % find highest peak value
    % calculate minimum peak value threshold based on that
    [maxVal, maxIdx] = max(abs(signal));
%     figure;
%     plot(abs(signal));
    firstPeakIdx=[];
    alpha=0.8;
    thresholdVal =maxVal * threshold;
    num_peaks_remain=1;
%     while length(firstPeakIdx)<num_peaks_remain
%         [LOCS1_value,  LOCS1] = findpeaks(signal, 'MinPeakHeight',thresholdVal);
%         [LOCS2_value,  LOCS2] = findpeaks(-signal, 'MinPeakHeight',thresholdVal);
%         [value,pos]=sort(LOCS1_value,'descend');
%         LOCS1=LOCS1(pos);
%          [value,pos]=sort(LOCS2_value,'descend');
%          LOCS2=LOCS2(pos);
%          LOCS2=[];
%         if ~isempty([LOCS1'; LOCS2'])
%              firstPeakIdx = [LOCS1(1:min(2,length(LOCS1)))'; LOCS2(1:min(2,length(LOCS2)))'];
% %               firstPeakIdx = LOCS1(1:min(num_peaks_remain,length(LOCS1)))';
%              firstPeakIdx=LOCS1';
%         else
%             firstPeakIdx = maxIdx;
%         end
%         firstPeakVal = signal(firstPeakIdx);
%         thresholdVal = alpha*thresholdVal;
%     end
    
    firstPeakIdx = maxIdx;
    firstPeakVal = signal(firstPeakIdx);
    firstPeakIdx=sort(firstPeakIdx,'descend');
    %firstPeakIdx=firstPeakIdx(1:num_peaks_remain);
end

