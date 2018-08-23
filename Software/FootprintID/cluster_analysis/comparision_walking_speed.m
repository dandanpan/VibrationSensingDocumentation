clear all
close all
clc

init();
numPeople = 10;
sensorID = 7;
scales = 1:1024;
Fs = 1000;

for personID = 1:2%numPeople
    load(['./dataset/P' num2str(personID) '.mat']);
    Signals = P{personID}.Sen{sensorID}.S;

    for speedID = 1:7
        traces = Signals{speedID};
        traceNum = size(traces, 1);
        for traceID = 1%traceNum
            traceSig = traces{traceID,1};
            %% extract noise sample
            if personID == 1 && speedID == 1 && traceID == 1
                noiseSample = traceSig(10000:15000);
                [ Y1, f1, ~] = signalFreqencyExtract( traceSig, Fs );
                figure;plot(f1,Y1);
                [ Y2, f2, ~] = signalFreqencyExtract( noiseSample, Fs );
                hold on;plot(f2,Y2);
            end
            %% low pass filter on traceSig
            [ Y, f, ~] = signalFreqencyExtract( traceSig, Fs );
            figure;plot(f,Y);
            Wn = 40/(Fs/2);
            [b,a] = butter(9,Wn,'low');
            traceSig = filter(b,a,traceSig);
            [ Y, f, ~] = signalFreqencyExtract( traceSig, Fs );
            hold on;plot(f,Y);
            hold on;plot(f2,Y2);
            
            traceSigFilter = signalDenoise(traceSig, 50);
            
            
            [ stepEventValue ,stepEventsIdx ] = findpeaks(traceSigFilter,'MinPeakDistance',200,'MinPeakHeight',50,'Annotate','extents');
            figure;
            plot(traceSig);hold on;
            scatter(stepEventsIdx, traceSig(stepEventsIdx),'rv');
            title(['personID: ' num2str(personID) ' speedID: ' num2str(speedID) ' traceID: ' num2str(traceID) ]);

                        
            stepEnergyArray = zeros(length(stepEventsIdx),1);
            for stepID = 1:length(stepEventsIdx)
                stepIdxSet = stepEventsIdx(stepID)-150:stepEventsIdx(stepID)+250;
                stepSig = traceSig(stepIdxSet);
                stepEnergyArray(stepID) = sum(stepSig.*stepSig);
                %% wavelet decomposition
%                 [ COEFS, ~, ~ ] = waveletAnalysis(stepSig, 1, scales, 'mexh');
%                 for filterScaleIdx = 19:21
%                     stepSigFiltered = waveletFilter(COEFS, filterScaleIdx);
%                     plot(stepIdxSet, stepSigFiltered.*100);
%                 end
            end 
            %% select three continuous step signal with highest sig energy
            % this indicates least structural variation
            maxEnergyIdx = -1;
            maxEnergyVal = -1;
            for stepID = 2:length(stepEventsIdx)-1
                if sum(stepEnergyArray(stepID-1:stepID+1)) > maxEnergyVal
                    maxEnergyVal = sum(stepEnergyArray(stepID-1:stepID+1));
                    maxEnergyIdx = stepID;
                end
            end
            
            %% extract info from the selected three steps
            for sI = -1:1
                stepIdxSet = stepEventsIdx(maxEnergyIdx+sI)-50:stepEventsIdx(maxEnergyIdx+sI)+200;
                stepSig = alignByFirstPeak(traceSig,stepEventsIdx(maxEnergyIdx+sI),100,200);
                [ Y, f, ~] = signalFreqencyExtract( stepSig, Fs );
                nsc = 50;
                nov = 25;
                nff = max(1024,2^nextpow2(nsc));
                t = spectrogram(stepSig,hamming(nsc),nov,nff);
                
                figure;
                subplot(3,1,1);plot(stepSig);                
                subplot(3,1,2);plot(f,Y);
                subplot(3,1,3);imagesc(real(t));ylim([0,100]);
                title(['personID: ' num2str(personID) ' speedID: ' num2str(speedID) ' traceID: ' num2str(traceID) ' stepID: ' num2str(sI) ]);
            end
            
        end
    end

    
end

