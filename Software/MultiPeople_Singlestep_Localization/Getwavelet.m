function [COEFS,maxScale,totalEnergy] = Getwavelet(signal,isshow)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
wname = 'morl';

Fs=25600;
dt=1/Fs;
scales = (1:1024);
if isshow==1
    COEFS = cwtft(signal,'scales',scales,'wavelet',wname,'plot');
else
    COEFS = cwtft(signal,'scales',scales,'wavelet',wname);
end

wEnergy = real(COEFS.cfs).^2;
    totalEnergy = sum(squeeze(wEnergy), 2);
%     imagesc(COEFS.cfs);
        
%       figure;
%       plot(totalEnergy)
      bandEnergy = [];
    [~, maxScale] = max(totalEnergy);
    
end

