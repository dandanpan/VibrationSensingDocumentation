configuration_setup;

for personID = 1 : numPeople
    load(['../dataset/P' num2str(personID) '.mat']);
    
    stepSigs = [];
    stepSigsLabel = [];   
    personIDLabel = [];   
    speedIDLabel = [];    
    traceIDLabel = []; 
    stepIdxLabel = [];
    speedCount = 0;
    for speedID = speedSequence 
        speedCount = speedCount + 1;
        Signals = P{personID}.Sen{sensorID}.S;
        traces = Signals{speedID};
        trainingTraceID = [1:5];
        for traceID = trainingTraceID
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
    clusterNum = length(clusters);
    for clusterID = 1 : clusterNum
        SpecAll = zeros(64,400);
        stepNum = length(clusters{clusterID});
        %% check the shift error
        whiteList = [];
        if stepNum > 3
            for i = 1 : stepNum
                for j = i+1 : stepNum
                    stepIdx1 = clusters{clusterID}(i);
                    stepSig1 = stepSigs(stepIdx1,:);
                    stepIdx2 = clusters{clusterID}(j);
                    stepSig2 = stepSigs(stepIdx2,:);
                    stepSig1 = signalNormalization(stepSig1);
                    stepSig2 = signalNormalization(stepSig2);
                    [temp, shift] = max((xcorr(stepSig1,stepSig2)));
                    if abs(shift-400) < 2
                        whiteList = [whiteList, i,j];
                    end      
                end
            end
        else
            whiteList = 1;
        end
        whiteList = unique(whiteList);
        stepSigWhiteIdx = clusters{clusterID}(whiteList(1));
        stepSigWhite = stepSigs(stepSigWhiteIdx,:);
        stepSigWhite = signalNormalization(stepSigWhite);
        blackList = [1 : stepNum];
        blackList(blackList == whiteList(1)) = [];
        for bidx = 1 : length(blackList) 
            blackNum = blackList(bidx);
            stepIdxInCluster = clusters{clusterID}(blackNum);
            stepSigBlack = stepSigs(stepIdxInCluster,:);
            stepSigBlack = signalNormalization(stepSigBlack);
            [temp, shift] = max((xcorr(stepSigWhite,stepSigBlack)));
            if abs(shift-400) > 2
               a = 0; 
            end
            traceSig = Signals{speedIDLabel(stepIdxInCluster)}{traceIDLabel(stepIdxInCluster),1};
            traceSigFilter = signalDenoise(traceSig, 50);
            offset = shift - 400;
            tempSig ...
                = traceSigFilter(stepIdxLabel(stepIdxInCluster) - offset - WIN1+1 : ...
                                    stepIdxLabel(stepIdxInCluster) - offset + WIN2); 
            stepSigs(stepIdxInCluster,:) = signalNormalization(tempSig);
        end
        
        %% within a cluster processing
        stepTCluster = [];
        stepFCluster = [];
        for stepID = 1 : stepNum
            % feature extraction
            stepIdx = clusters{clusterID}(stepID);
            stepSig = stepSigs(stepIdx,:);
            % time domain
            stepTCluster = [stepTCluster; stepSig];
            % frequency domain
            [ Y, f, NFFT] = signalFreqencyExtract( stepSig, Fs );
            Y = Y(f<=cutoffFrequency);
            f = f(f<=cutoffFrequency);
            Y = signalNormalization(Y);
            stepFCluster = [stepFCluster; Y];
            % time-frequency domain    
            level = 6;
            wpt = wpdec(stepSig,level,'bior3.7'); 
            [Spec,Time,Freq] = wpspectrum(wpt, Fs);
            SpecAll = SpecAll + Spec;
        end
        SpecAll = SpecAll ./stepNum;
        % sym8, bior3.7
        figure;
        subplot(3,1,1);
        plot(stepTCluster');
        title(['Person' num2str(personID) ', Cluster' num2str(clusterID)]);
        subplot(3,1,2);
        plot(stepFCluster');
        subplot(3,1,3);
        imagesc(SpecAll);    
    end
end
