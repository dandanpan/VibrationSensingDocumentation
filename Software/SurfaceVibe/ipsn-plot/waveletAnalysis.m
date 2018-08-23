function [ COEFS, maxScale, totalEnergy, maxBandScale ] = waveletAnalysis( signal, bandWidth, scales, wname )
%WAVELETANALYSIS Summary of this function goes here
%   Detailed explanation goes here
    if nargin < 3
        wname = 'mexh';
    end
    if nargin < 4
        scales = (1:256);
    end
    COEFS = cwtft(signal,'scales',scales,'wavelet',wname,'plot');
    wEnergy = COEFS.cfs.^2;
    totalEnergy = sum(squeeze(wEnergy), 2);
    
%     figure;
%     subplot(2,1,1);
%     imagesc(COEFS.cfs);
%     subplot(2,1,2);
%     plot(totalEnergy);
    
    bandEnergy = [];
    for i = 1 : length(totalEnergy)-bandWidth
        bandEnergy = [bandEnergy, sum(totalEnergy(i:i+bandWidth-1))];
    end
    [~, maxScale] = max(totalEnergy);
    [~, maxBandScale] = max(bandEnergy);
    
%     figure;
%     imagesc(COEFS.cfs);hold on;
%     plot([1,size(COEFS.cfs,2)],[maxBandScale,maxBandScale],'r');hold off;
%     
%     figure;
%     subplot(2,1,1);plot(signal);
%     subplot(2,1,2);plot(COEFS.cfs(maxScale,:));
    
    
end

