function [ normSig ] = stepSignalNormalization( signal )
%STEPSIGNALNORMALIZATION Summary of this function goes here
%   Detailed explanation goes here
    energySig = sum(signal.*signal);
    normSig = signal./sqrt(energySig);
end

