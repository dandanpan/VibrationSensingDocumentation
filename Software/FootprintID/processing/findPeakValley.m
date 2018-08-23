function [ allV, allI ] = findPeakValley( sig, minPeakDistance, minPeakHeight, minPeakProminence)
%FINDPEAKVALLEY Summary of this function goes here
%   Detailed explanation goes here
    [ peakV ,peakI ] = findpeaks(sig,'MinPeakDistance',minPeakDistance,'MinPeakHeight',minPeakHeight, 'MinPeakProminence', minPeakProminence,'Annotate','extents');
    if min(sig) >= 0
        inverseSig = -sig - min(-sig);
    else 
        inverseSig = -sig;
    end
    [ valleyV ,valleyI ] = findpeaks(inverseSig,'MinPeakDistance',minPeakDistance,'MinPeakHeight',minPeakHeight,'MinPeakProminence', minPeakProminence,'Annotate','extents');
    allV = [peakV sig(valleyI)];
    allI = [peakI valleyI];
    [~,iorder] = sort(allI);
    allI = allI(iorder);
    allV = allV(iorder);
end

