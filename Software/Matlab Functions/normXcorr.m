function [ normXcorr ] = normXcorr( sig1, sig2, plotSig )
%NORMXCORR Summary of this function goes here
%   Detailed explanation goes here
    if nargin < 3
        plotSig = 0;
    end
    
    normSig1 = sig1./sqrt(sum(sig1.^2));
    normSig2 = sig2./sqrt(sum(sig2.^2));
    if plotSig == 1
        figure;
        plot(normSig1);hold on;
        plot(normSig2);hold off;
    end
    
    normXcorr = xcorr(normSig1, normSig2);
end

