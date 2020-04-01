clear all;
close all
clc;

%% Calibrating verlocity and scale
load('./classroom_no_base_localization_Tennis.mat');
scaleValue = 7;
velocityValue = 0.0004;
bandWidth = 5;
sensorNum = 4;
firstPeakThreshold = 0.2;
    
errorList = [];
for stepID = 1:length(Local_sig)
    stepID
    for i = 1:sensorNum
        [ COEFS, maxScale, maxBandScale ] = waveletAnalysis( Local_sig{stepID}.sig{i}, bandWidth );
        [ Local_sig{stepID}.filSig{i} ] = waveletFiltering( COEFS, scaleValue);
    end

    [TDoA12] = pairwiseTDoA(Local_sig{stepID}.filSig{1},Local_sig{stepID}.filSig{2},Local_sig{stepID}.ts{1},Local_sig{stepID}.ts{2},firstPeakThreshold);
    [TDoA23] = pairwiseTDoA(Local_sig{stepID}.filSig{2},Local_sig{stepID}.filSig{3},Local_sig{stepID}.ts{2},Local_sig{stepID}.ts{3},firstPeakThreshold);
    [TDoA14] = pairwiseTDoA(Local_sig{stepID}.filSig{1},Local_sig{stepID}.filSig{4},Local_sig{stepID}.ts{1},Local_sig{stepID}.ts{4},firstPeakThreshold);

    sensorLoc{1} = Local_sig{stepID}.Sloc1;
    sensorLoc{2} = Local_sig{stepID}.Sloc2;
    sensorLoc{3} = Local_sig{stepID}.Sloc3;
    sensorLoc{4} = Local_sig{stepID}.Sloc4;

    TDoAPairs = [1,2,TDoA12;
                 2,3,TDoA23;
                 1,4,TDoA14];

    [ location ] = locationEstFromTDoA( TDoAPairs, sensorLoc, [1:4], velocityValue);
    locationID = (Local_sig{stepID}.groundtruth(2)+4)/2;
    errorList = [errorList, norm(Local_sig{stepID}.groundtruth-location')];
end
errorList  