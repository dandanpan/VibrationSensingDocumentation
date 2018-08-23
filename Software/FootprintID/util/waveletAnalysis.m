function [ COEFS, maxScale, maxBandScale, totalEnergy ] = waveletAnalysis(signal, bandWidth, scales, wavelet)
    COEFS = cwtft(signal,'scales',scales,'wavelet',wavelet);
    wEnergy = COEFS.cfs.^2;
    totalEnergy = sum(squeeze(wEnergy), 2);
    bandEnergy = [];
    for i = 1 : length(totalEnergy)-bandWidth;
        bandEnergy = [bandEnergy, sum(totalEnergy(i:i+bandWidth-1))];
    end
    [~, maxScale] = max(totalEnergy);
    [~, maxBandScale] = max(bandEnergy);
end