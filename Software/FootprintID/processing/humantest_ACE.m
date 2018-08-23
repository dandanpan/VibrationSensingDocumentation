speedSequence = [7,6,5,1,2,3,4,8];
figure;
for speedID = 8%1 : numSpeed
%     subplot(numSpeed,1,speedID);
    traces = Signals{speedSequence(speedID)};
    for traceID = 1 : length(traces)
        traceSig = traces{traceID,1};
        traceSigFilter = signalDenoise(traceSig, 50);
        [ stepEventValue ,stepEventsIdx ] = findpeaks(traceSigFilter,'MinPeakDistance',200,'MinPeakHeight',50,'Annotate','extents');
         stepFrequency = (stepEventsIdx(2:end) - stepEventsIdx(1:end-1))./Fs;
        [ selectedSteps ] = stepSelection( traceSigFilter, stepEventsIdx, WIN1, WIN2, 3 );
        stepEventsIdx = stepEventsIdx(selectedSteps);
        stepEventValue = stepEventValue(selectedSteps);
        tempMF = 0;
        mcount = 0;
        for stepID = 1 : length(stepEventsIdx)
            stepSig = traceSigFilter(stepEventsIdx(stepID)-WIN1+1:stepEventsIdx(stepID)+WIN2);
            stepSig = signalNormalization(stepSig);
            [ Y, f, NFFT] = signalFreqencyExtract( stepSig, Fs );
            medianFreq = medianFrequency(Y, f);
            tempMF = tempMF + medianFreq;
            mcount = mcount + 1;
            plot(f,Y);hold on;xlim([0,90]);
            plot([medianFreq, medianFreq],[0,0.05]);
        end
        medianFrequencySet(speedID, personID) = medianFrequencySet(speedID, personID) + tempMF;
        stepFrequency = stepFrequency(stepFrequency<1);
        stepFrequencySet(speedID, personID) = mean(stepFrequency);
%         figure; plot(traceSigFilter);hold on;
%         for stepID = 1 : length(stepEventsIdx)
%             scatter(stepEventsIdx(stepID),stepEventValue(stepID),'rV');
%             plot([stepEventsIdx(stepID)-WIN1, stepEventsIdx(stepID)-WIN1],[-100,100],'r');
%             plot([stepEventsIdx(stepID)+WIN2, stepEventsIdx(stepID)+WIN2],[-100,100],'g');
%         end
%         hold off;
       
%         figure;
%         plot(traceSig);hold on;
%         traceSigFilter = signalDenoise(traceSig, 50);
%         plot(traceSigFilter);hold off;
         
    end
    hold off;
    title(['personID' num2str(personID) 'speedID' num2str(speedID)]);

    medianFrequencySet(speedID, personID) = medianFrequencySet(speedID, personID)/length(traces);
%     xlim([0,80]);
end
