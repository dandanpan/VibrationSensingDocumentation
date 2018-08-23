function [ sigEnergy ] = signalEnergy( sig )
%SIGNALENERGY Summary of this function goes here
%   Detailed explanation goes here
    sigEnergy = sum(sig.*sig);

end

