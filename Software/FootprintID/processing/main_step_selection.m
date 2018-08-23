% clear
close all
clc

load('data.mat');

mPeakThreshold = 3;
WIN1 = 250;
WIN2 = 250;
stepSelectionNum = 3;

%% case 1: frequency 95, sensor 1
for traceID = 1 : length(P1{1}.F1L1)
    % detect steps
    mPeak = max(P1{1}.F1L1{traceID,1})./mPeakThreshold;
    [ stepEventValue ,stepEventsIdx ] = findpeaks(P1{1}.F1L1{traceID,1},'MinPeakDistance',1000*60/85/2 ,'MinPeakHeight',mPeak,'Annotate','extents');
    
    figure; plot(P1{1}.F1L1{traceID,1});hold on;
    for stepID = 1 : length(stepEventsIdx)
        scatter(stepEventsIdx(stepID),stepEventValue(stepID),'rV');
    end
    hold off;
    
    % select steps
    figure;
    selectedSteps = stepSelection(P1{1}.F1L1{traceID,1}, stepEventsIdx, WIN1, WIN2, stepSelectionNum);
%     fprintf(['  ---- trace ' num2str(traceID) ' ----']);
%     selectedSteps
    
    
end