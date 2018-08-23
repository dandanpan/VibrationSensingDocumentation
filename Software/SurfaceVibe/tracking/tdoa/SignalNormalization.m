function [ normSig ] = SignalNormalization( inputSig )
%SIGNALNORMALIZATION Summary of this function goes here
%   Detailed explanation goes here
    sigEnergy = sum(inputSig.*inputSig);
    normSig = inputSig./sqrt(sigEnergy);
end

