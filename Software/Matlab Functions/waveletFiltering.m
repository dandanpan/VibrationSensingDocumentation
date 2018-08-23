function [ reconstructedSig ] = waveletFiltering( COEFS, maxScale )
%WAVELETFILTERING Summary of this function goes here
%   Detailed explanation goes here
    sigMask = zeros(size(COEFS.cfs));
    sigMask(maxScale,:) = ones(length(maxScale),size(COEFS.cfs,2));
    
    COEFS.cfs = sigMask.*COEFS.cfs;
    reconstructedSig = icwtft(COEFS);
end

