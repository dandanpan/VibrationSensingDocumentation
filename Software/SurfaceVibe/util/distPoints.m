function [ distBetweenPoints ] = distPoints( point1, point2 )
%DISTPOINTS Summary of this function goes here
%   Detailed explanation goes here
    distBetweenPoints = sqrt(sum((point2-point1).^2));
end

