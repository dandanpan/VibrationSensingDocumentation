function [ idx ] = locateWindowByTime( timeSeries, targetTime)
%LOCATEWINDOWBYTIME Summary of this function goes here
%   Detailed explanation goes here
    deltaT = abs(timeSeries - targetTime);
    [~, idx] = min(deltaT);
end

