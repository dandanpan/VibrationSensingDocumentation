configuration_setup;
%% person 1,2,4

for personID = [1,2,4]
    load(['./dataset/P' num2str(personID) '.mat']);
    stepSigs = [];
    stepSigsLabel = [];   
    personIDLabel = [];   
    speedIDLabel = [];    
    traceIDLabel = []; 
    stepIdxLabel = [];
    traceSigs = [];
    traceSigsLabel = [];
    traceCount = 0;
    speedCount = 0;
    for speedID = speedSequence
        speedCount = speedCount + 1;
        Signals = P{personID}.Sen{sensorID}.S;
        traces = Signals{speedID};
        traceNum = length(traces);
        for traceID = 1 : traceNum
            traceSig = traces{traceID,1};
            traceSigFilter = signalDenoise(traceSig, 50);
            
            [ stepEventValue ,stepEventsIdx ] = findpeaks(traceSigFilter,'MinPeakDistance',200,'MinPeakHeight',50,'Annotate','extents');
            % filter out-of-range steps
            stepEventValue = stepEventValue(stepEventsIdx > WIN1 & stepEventsIdx < length(traceSigFilter)-WIN2);
            stepEventsIdx = stepEventsIdx(stepEventsIdx > WIN1 & stepEventsIdx < length(traceSigFilter)-WIN2);
            % select steps by energy
            [ selectedSteps ] = stepSelectionSNR( traceSigFilter, stepEventsIdx, WIN1, WIN2, 3 );
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
                stepSigsLabel = [stepSigsLabel; speedCount];
                personIDLabel = [personIDLabel; personID];
                speedIDLabel = [speedIDLabel; speedID];
                traceIDLabel = [traceIDLabel; traceID];
                stepIdxLabel = [stepIdxLabel; tempIndex];
            end
        end
    end
    
    % end of a person's training data
    [clusters] = stepSelection( stepSigs, 0);
    pCluster{personID} = clusters
%     clusterNum = length(clusters);
%     speedCount = 0;
%     for speedID = speedSequence(8) 
%         traces = P{personID}.Sen{sensorID}.S{speedID};
%         traceNum = length(traces);
%         figure;
%         for traceID = 7:8% 1:traceNum
%             
%             traceSig = traces{traceID,1};
%             traceSigFilter = signalDenoise(traceSig, 50);
%             subplot(2, 1, traceID-6);
% 
% %             subplot(traceNum, 1, traceID);
%             axis tight;
%             if traceID == 7
%                 plot([1:length(traceSig(5000:10000))]./Fs,traceSig(5000:10000));hold on;
%             else
%                 plot([1:length(traceSig(8000:13000))]./Fs,traceSig(8000:13000));hold on;
%             end
%         end
%         
%         for clusterID = 1 : clusterNum
%             % check each cluster's location
%             % find the steps in each cluster 
%             stepNum = length(clusters{clusterID});
%             maskStep = zeros(1, length(stepIdxLabel));
%             for stepID = 1 : stepNum
%                 stepIdx = clusters{clusterID}(stepID);
%                 maskStep(stepIdx) = 1;
%             end
%             maskSpeed = (speedIDLabel == speedID);
%             for traceID = 7:8 %1:traceNum
%                 maskTrace = (traceIDLabel == traceID);
%                 traceSig = traces{traceID,1};
% %                 subplot(traceNum, 1, traceID);
%                 subplot(2, 1, traceID-6);
% 
%                 mask = find(maskStep.*maskSpeed'.*maskTrace');
%                 if length(mask)>0
%                     stepIdx = stepIdxLabel(mask);
%                     stepVal = traceSig(stepIdx);
%                     if traceID == 7
%                         offsetT = 5;
%                     else
%                         offsetT = 8;
%                     end
%                     
%                     if clusterID == 2
%                         scatter(stepIdx./Fs-offsetT,stepVal+20,'rv');
%                     elseif clusterID == 3
%                         scatter(stepIdx./Fs-offsetT,stepVal+20,'gv');
%                     elseif clusterID == 5
%                         scatter(stepIdx./Fs-offsetT,stepVal+20,'kv');
%                     end
%                     
% 
%                 end
%             end
%         end
%         hold off;
%     end
end
