function [ distance ] = eDist( sig1, sig2 )
%EDIST calculates the eclidean distance between sig1 and sig2
%   sig1 and sig2 are 1xN matrix
    diffSig = sig1-sig2;
    distance = sqrt(sum(diffSig.^2));

end

