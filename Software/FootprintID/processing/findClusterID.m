function [ result ] = findClusterID( clusters, stepID )
%FINDCLUSTERID Summary of this function goes here
%   Detailed explanation goes here
    result = -1;
    for clusterID = 1 : length(clusters)
        if ismember(stepID,clusters{clusterID}) == 1
            result = clusterID;
            break;
        end 
    end
end

