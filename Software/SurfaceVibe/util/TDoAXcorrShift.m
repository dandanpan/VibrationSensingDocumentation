function [ lagDiff, lagVal, candidateLag, candidateVal ] = TDoAXcorrShift( refsig, sig )
%TDOAXCORRSHIFT Summary of this function goes here
%   Detailed explanation goes here
    [cor, lag] = xcorr(sig,refsig);
    [PKS,LOCS,W,P] = findpeaks(cor);
    [c,I] = max(PKS);
    lagDiff = LOCS(I);
    lagVal = c;
    candidateLag = [];
    candidateVal = [];
end

