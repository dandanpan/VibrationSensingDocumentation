%% tennis ball
ballID = 2;
% pair wise comparison at each location
SelfSimilarity = zeros(1,numLocation);
locRecord = zeros(numLocation, numImpulse);
for locID = 1 : numLocation
    [ pV ,pI ] = findpeaks(Loc{locID,ballID},'MinPeakDistance',500,'MinPeakHeight',100,'Annotate','extents');
    count = 0;
    for impulseID = 1 : numImpulse
        sig1 = Loc{locID,ballID}(pI(impulseID)-WIN1+1:pI(impulseID)+WIN2);
        locRecord(locID, impulseID) = pI(impulseID);
        for j = impulseID + 1 : numImpulse
            sig2 = Loc{locID,ballID}(pI(j)-WIN1+1:pI(j)+WIN2);
            sig1 = signalNormalization(sig1);
            sig2 = signalNormalization(sig2);
            SelfSimilarity(locID) = SelfSimilarity(locID) + ...
                max(abs(xcorr(sig1,sig2)));
            count = count + 1;
        end
    end
    SelfSimilarity(locID) = SelfSimilarity(locID)./count;
end
figure;
plot(SelfSimilarity);

% pair wise comparison at different location near by a sensor
NearbySimilarity = zeros(numLocation);
for impulseID = 1 : numImpulse
    for locID = 1 : numLocation
        for j = locID + 1 : numLocation
            sig1 = Loc{locID,ballID}(locRecord(locID,impulseID)-WIN1+1:locRecord(locID,impulseID)+WIN2);
            sig2 = Loc{j,ballID}(locRecord(j,impulseID)-WIN1+1:locRecord(j,impulseID)+WIN2);
            sig1 = signalNormalization(sig1);
            sig2 = signalNormalization(sig2);
            NearbySimilarity(locID,j) = NearbySimilarity(locID,j) + max(abs(xcorr(sig1,sig2)));
        end
    end
end
NearbySimilarity = NearbySimilarity./numImpulse;

figure;
imagesc(NearbySimilarity);
colormap(gray);
grid on;

% frequency domain
figure;
for locID = 1 : numLocation
    subplot(numLocation,2,locID*2-1);
    for impulseID = 1 : numImpulse
        sig1 = Loc{locID,ballID}(locRecord(locID,impulseID)-WIN1+1:locRecord(locID,impulseID)+WIN2);
        plot([1:length(sig1)]./Fs, sig1);hold on;
    end
    hold off;
    title(['Sensor 3, ' num2str((locID-3)*2) 'ft, Time Domain']);
    xlim([0,0.13]);
    ylim([-500, 500]);
    
    subplot(numLocation,2,locID*2);
    for impulseID = 1 : numImpulse
        sig1 = Loc{locID,ballID}(locRecord(locID,impulseID)-WIN1+1:locRecord(locID,impulseID)+WIN2);
        [sig1f, f, NFFT] = signalFreqencyExtract( sig1, Fs );
        plot(f, sig1f);hold on;    
    end
    hold off;
    title(['Sensor 3, ' num2str((locID-3)*2) 'ft, Frequency Domain']);
    xlim([0,200]);
    ylim([0, 50]);
end 
