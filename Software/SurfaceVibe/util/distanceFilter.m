function [ updatedPoints ] = distanceFilter( points, confidence, threshold )
%DISTANCEFILTER Summary of this function goes here
%   Detailed explanation goes here
    minConf = min(confidence,[],2);
    [~, maxConfIdx] = max(minConf);
    numPoints = size(points, 1);
    refLoc = points(maxConfIdx,:);
    relativeLoc = zeros(size(points,1),1);
    currentPoint = refLoc;
    for idx = maxConfIdx-1:-1:1
        dist = distPoints(points(idx,:), currentPoint);
        relativeLoc(idx) = dist;
        if dist < threshold/2 % 5 is selected based on the grid radius
            currentPoint = points(idx,:);
        end
    end
    currentPoint = refLoc;
    for idx = maxConfIdx+1:numPoints
        dist = distPoints(points(idx,:), currentPoint);
        relativeLoc(idx) = dist;
        if dist < threshold/2
            currentPoint = points(idx,:);
        end
    end
    updatedPoints = points(relativeLoc < threshold,:);
end

