function [ windowEnergy ] = windowEnergyArray( rawSig, Fs, windowSize, slidingSize )
%WINDOWENERGYARRAY Summary of this function goes here
%   Detailed explanation goes here
    
    if nargin < 2
        Fs = 6500;
        windowSize = Fs/5;
        slidingSize = windowSize/2;
    elseif nargin < 3
        windowSize = Fs/5;
        slidingSize = windowSize/2;
    elseif nargin < 4
        slidingSize = windowSize/2;
    end
    
    rawSigLen = length(rawSig);
    windowEnergy = zeros(ceil(rawSigLen/slidingSize),2);
    for idx = 1:slidingSize:rawSigLen-windowSize
        windowEnergy(ceil(idx/slidingSize),1) = rawSig(idx,1);
        windowEnergy(ceil(idx/slidingSize),2) = sum(rawSig(idx:min(idx+windowSize-1,end),2).*rawSig(idx:min(idx+windowSize-1,end),2));
    end

end

