function [ fNorm ] = featureNorm( features )
%FEATURENORM Summary of this function goes here
%   Detailed explanation goes here
    fMin = min(features);
    fMax = max(features);
    fNorm = (features - fMin)./(fMax-fMin);

end

