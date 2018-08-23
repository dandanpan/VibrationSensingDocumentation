function [ dist ] = distFreq( freq1, freq2 )
%DISTFREQ Summary of this function goes here
%   Detailed explanation goes here

    dist = sum(abs(freq1 - freq2));
end

