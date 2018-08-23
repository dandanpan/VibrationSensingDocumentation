function [ direction, s3PeakIdx, s7PeakIdx ] = getDirection( sigS3, sigS7 )
%GETDIRECTION Summary of this function goes here
%   if the person walk from Sensor 3 to Sensor 7
%   then the direction is 1
%   else the direction is -1
    Fs = 1000;
    windowLen = Fs*3; 
    sigLenS3 = length(sigS3);
    sigLenS7 = length(sigS7);
    windowNumS3 = floor((sigLenS3-windowLen/2)/windowLen);
    windowNumS7 = floor((sigLenS7-windowLen/2)/windowLen);
    windowNum = min(windowNumS3, windowNumS7);
%     wEnergyS3 = zeros(windowNum,1);
%     wEnergyS7 = zeros(windowNum,1);
%     for idx = 1:windowNum
%         windowIdx = [windowLen*(idx-1)+1:windowLen*idx];
%         windowS3 = sigS3(windowIdx);
%         windowS7 = sigS7(windowIdx);
%         wEnergyS3(idx) = sum(windowS3.*windowS3);
%         wEnergyS7(idx) = sum(windowS7.*windowS7);
%     end
    % find relative peak location
    [~, s3Peak] = max(sigS3);
    s3PeakIdx = s3Peak;%(s3Peak + 1)*windowLen/2;
    [~, s7Peak] = max(sigS7);
    s7PeakIdx = s7Peak;%(s7Peak + 1)*windowLen/2;
    if s3Peak <= s7Peak
        direction = 1;
    else 
        direction = -1;
    end
end

