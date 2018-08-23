function [ Y, f ] = frequencyAnalysis( signal, Fs )
%FREQUENCYANALYSIS Summary of this function goes here
%   Detailed explanation goes here
    [ Y, f ] = signalFreqencyExtract( signal, Fs );
    figure;
    plot(f,Y);
end

