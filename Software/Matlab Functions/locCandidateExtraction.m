function [ locCandi ] = locCandidateExtraction( peakCandi, sensorLoc, sensorSet, velocity )
%LOCCANDIDATEEXTRACTION Summary of this function goes here
%   Detailed explanation goes here
    if nargin < 4
        velocity = 1100;
    end
    locCandi = [];
    sensorNum = length(sensorSet);
    for gID = 1:sensorNum:size(peakCandi,1)
        peakSetInfo = peakCandi(gID:gID+sensorNum-1,:);
        [ TDoAPairs ] = tdoaFromPeakSet( peakSetInfo, sensorSet );
        [ location ] = locationEstFromTDoA( TDoAPairs, sensorLoc, sensorSet, velocity );
        locCandi = [locCandi, location];
    end
end

