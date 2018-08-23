function [ normalizedSig ] = signalNormalization( signal )
    
    signalEnergy= sqrt(sum(signal.*signal)); 
    normalizedSig = signal./signalEnergy;
    
end

