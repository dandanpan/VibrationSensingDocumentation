function [ timestamp ] = plot_by_time( signals, Fs )
%PLOT_BY_TIME Summary of this function goes here
%   Detailed explanation goes here
    if nargin < 2
        Fs = 10000;
    end
    
    timestamp = [1:length(signals)];
    timestamp = timestamp./Fs;
    
    plot(timestamp, signals);

end

