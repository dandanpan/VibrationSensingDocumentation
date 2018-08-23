function [ FilterSE ] = SEWaveletFilter( SESignal, dScale, fScale )
%SEWAVELETFILTER filter on Step Event (SE) signal SESignal
%   SESignal is a 2xN matrix where (:,1) is timestamp (:,2) is signal
%   dScale is the decomposition scale, default value is (1:256)
%   fScale is the filter scale

    [ COEFS ] = waveletAnalysis( SESignal(:,2), 1, dScale );
    [ reconstructedSig ] = waveletFiltering( COEFS, fScale );
    
    FilterSE = [SESignal(:,1), reconstructedSig'];

end

