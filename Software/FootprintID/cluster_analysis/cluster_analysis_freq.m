clear 
close all
clc

init();    
configuration_setup;

stepSigs = [];
stepSigsLabel = [];   
personIDLabel = [];   
speedIDLabel = [];    
traceIDLabel = []; 

for personID = 1 : numPeople
    personID
    clear P;
    load(['./dataset/P' num2str(personID) '.mat']);

    
    stepIdxLabel = [];
    traceSigs = [];
    traceSigsLabel = [];
    traceCount = 0;
    speedCount = 0;
    Signals = P{personID}.Sen{sensorID}.S;

    %% self selected speed 8
    for speedID = 1:numSpeed
        speedID
        traces = Signals{speedID};
        for traceID = 1:5%size(traces,1)
            traceID
            
            traceSig = traces{traceID,1};
            traceSigFilter = signalDenoise(traceSig, 50);

            [ stepEventValue ,stepEventsIdx ] = findpeaks(traceSigFilter,'MinPeakDistance',200,'MinPeakHeight',50,'Annotate','extents');
            stepFrequency = (stepEventsIdx(2:end) - stepEventsIdx(1:end-1))./Fs;

            % filter out-of-range steps
            stepEventValue = stepEventValue(stepEventsIdx > WIN1 & stepEventsIdx < length(traceSigFilter)-WIN2);
            stepEventsIdx = stepEventsIdx(stepEventsIdx > WIN1 & stepEventsIdx < length(traceSigFilter)-WIN2);
            % select steps by energy
            [ selectedSteps ] = stepSelectionSNR( traceSigFilter, stepEventsIdx, WIN1, WIN2, 1.5 );
            stepEventsIdx = stepEventsIdx(selectedSteps);
            stepEventValue = stepEventValue(selectedSteps);

            for stepID = 1 : length(stepEventsIdx)
                % find first peak
                tempSig = traceSigFilter(stepEventsIdx(stepID)-WIN1+1:stepEventsIdx(stepID)+WIN2);
                tempThresh = max(tempSig)/1.1;
                [ tempV ,tempI ] = findpeaks(tempSig,'MinPeakDistance',20,'MinPeakHeight',tempThresh,'Annotate','extents');
                tempIndex = stepEventsIdx(stepID)-WIN1+1+tempI(1);
                % extract step
                stepSig = traceSigFilter(tempIndex-WIN1+1:tempIndex+WIN2);
                stepSig = signalNormalization(stepSig);

                stepSigs = [stepSigs; stepSig'];
                personIDLabel = [personIDLabel; personID];
                speedIDLabel = [speedIDLabel; speedID];
                traceIDLabel = [traceIDLabel; traceID];
                stepIdxLabel = [stepIdxLabel; tempIndex];
            end
        end
    end
end

 % end of a person's training data
[clusters, nodeContainsLeave, Z, Y] = stepSelectionFD( stepSigs, 0, 0.1, Fs);

save('cluster_speed8.mat','clusters','stepSigs','personIDLabel','speedIDLabel','traceIDLabel','stepIdxLabel', ... 
    'nodeContainsLeave', 'Z', 'Y');
%% post processing for clusters

init();    
configuration_setup;
load('cluster_overall_t015.mat');

clusterNum = length(clusters);
speedSequence = [7,6,5,1,2,3,4,8];
clusterSummary = zeros(numPeople*(numSpeed+1),clusterNum);
for clusterID = 1 : clusterNum
    clusterSet = clusters{clusterID};
    for clusterEleID = 1:length(clusterSet)
        eleID = clusterSet(clusterEleID);
        matchID = (personIDLabel(eleID)-1)*(numSpeed+1)+speedSequence(speedIDLabel(eleID));
        clusterSummary(matchID,clusterID) = clusterSummary(matchID,clusterID) + 1;
    end
end
clusterSummary([(numSpeed+1):(numSpeed+1):end],:) = -1;
figure;imagesc(clusterSummary');

%% sparse pattern extraction




