function [ similarity ] = signalSimilarity( sig1, sig2 )
%SIGNALSIMILARITY Summary of this function goes here
%   Detailed explanation goes here
    normSig1 = signalNormalization(sig1);
    normSig2 = signalNormalization(sig2);
    similarity = max(xcorr(normSig1, normSig2));
end

