function [ maxN, maxNIdx ] = maxN( array, N )
%MAXN Summary of this function goes here
%   Detailed explanation goes here
    [sortedX,sortingIndices] = sort(array,'descend');
    maxN = sortedX(1:N);
    maxNIdx = sortingIndices(1:N);
end

