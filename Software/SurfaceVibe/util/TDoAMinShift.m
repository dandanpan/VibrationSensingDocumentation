function [ lagDiff, lagVal, candidateLag, candidateVal ] = TDoAMinShift( refsig, sig )
%TDOAMINSHIFT Summary of this function goes here
%   Detailed explanation goes here

    [cor, lag] = xcorr(sig,refsig);
    [PKS,LOCS,W,P] = findpeaks(cor);
    % find nearby peaks
    [c,I] = max(PKS);
    candidateShift = LOCS(max(I-1,1):min(I+1,length(LOCS)));
    candidateVal = PKS(max(I-1,1):min(I+1,length(LOCS)));
    candidateLag = lag(candidateShift);
    
    % select peaks around
    [cc, II] = min(abs(candidateLag));
    lagDiff = candidateLag(II);
    lagVal = candidateVal(II);
    
    

end

