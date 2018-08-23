function [ outputSig ] = myDownSample( signal, reduceLen )
%MYDOWNSAMPLE Summary of this function goes here
%   Detailed explanation goes here
    outputSig = signal;
    deltaIdx = floor(length(signal)/reduceLen);
    outputSig(deltaIdx:deltaIdx:end) = [];

end

