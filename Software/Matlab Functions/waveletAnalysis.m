function [ COEFS, maxScale, maxBandScale ] = waveletAnalysis( signal, bandWidth )
%WAVELETANALYSIS Summary of this function goes here
%   Detailed explanation goes here
    wname = 'mexh';
    scales = (1:256);
    COEFS = cwtft(signal,'scales',scales,'wavelet',wname);
    wEnergy = COEFS.cfs.^2;
    totalEnergy = sum(squeeze(wEnergy), 2);
%     imagesc(COEFS.cfs);
%     plot(totalEnergy);
    bandEnergy = [];
    for i = 1 : length(totalEnergy)-bandWidth;
        bandEnergy = [bandEnergy, sum(totalEnergy(i:i+bandWidth-1))];
    end
    [~, maxScale] = max(totalEnergy);
    [~, maxBandScale] = max(bandEnergy);
    
%     imagesc(COEFS.cfs);hold on;
%     plot([1,size(COEFS.cfs,2)],[maxBandScale,maxBandScale],'r');hold off;
    
end

