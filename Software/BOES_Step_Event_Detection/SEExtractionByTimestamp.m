function [ stepSig ] = SEExtractionByTimestamp( rawSig, peakLoc, win1, win2 )
% this function extracts Step Event (SE) signal from the rawSig
%   rawSig is a 2xN matrix
%   rawSig(:,1) is the timestamp, 
%   rawSig(:,2) is the signal
%   peakLoc is the peak timestamp
%   win1 is the length of the time before peak
%   win2 is the length of the time after peak
    
    rawTimestamp = rawSig(:,1);
    startTimestamp = peakLoc - win1;
    stopTimestamp = peakLoc + win2;
    [~,startIdx] = min(abs(rawTimestamp - startTimestamp));
    [~,stopIdx] = min(abs(rawTimestamp - stopTimestamp));
    
    stepSig = rawSig(startIdx:stopIdx,:);
    

end

