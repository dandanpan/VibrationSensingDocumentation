function [ ratio ] = signalEnergyRatio( sigEnergy1, sigEnergy2 )
%SIGNALENERGYRATIO Summary of this function goes here
%   Detailed explanation goes here
    ratio = sigEnergy1/sigEnergy2;
    if ratio < 1
        ratio = 1/ratio;
    end

end

