%% golf ball
ballID = 1;
% pair wise comparison at each location
SelfSimilarity = zeros(1,numLocation);
locRecord = zeros(numLocation, numImpulse);
for locID = 1 : numLocation
    [ pV ,pI ] = findpeaks(Loc{locID,ballID},'MinPeakDistance',500,'MinPeakHeight',100,'Annotate','extents');
    count = 0;
    for impulseID = 1 : numImpulse
        locRecord(locID, impulseID) = pI(impulseID);
        sig1 = Loc{locID,ballID}(pI(impulseID)-WIN1+1:pI(impulseID)+WIN2);
%         figure; plot(sig1);
            
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
            NearbySimilarity(j,locID) = NearbySimilarity(j,locID) + max(abs(xcorr(sig1,sig2)));
        end
    end
end
NearbySimilarity = NearbySimilarity./numImpulse;
for impulseID = 1 : numLocation
    NearbySimilarity(impulseID, impulseID) = SelfSimilarity(impulseID);
end

figure;
imagesc(NearbySimilarity);
colormap(gray);
% grid on;
axis equal;

textStrings = num2str(NearbySimilarity(:),'%0.2f');  %# Create strings from the matrix values
textStrings = strtrim(cellstr(textStrings));  %# Remove any space padding
[x,y] = meshgrid(1:5);   %# Create x and y coordinates for the strings
hStrings = text(x(:),y(:),textStrings(:),...      %# Plot the strings
                'HorizontalAlignment','center');
midValue = mean(get(gca,'CLim'));  %# Get the middle value of the color range
textColors = repmat(NearbySimilarity(:) < midValue,1,3);  %# Choose white or black for the
                                             %#   text color of the strings so
                                             %#   they can be easily seen over
                                             %#   the background color
set(hStrings,{'Color'},num2cell(textColors,2));  %# Change the text colors

set(gca,'XTick',1:5,...                         %# Change the axes tick marks
        'XTickLabel',{'1','2','3','4','5'},...  %#   and tick labels
        'YTick',1:5,...
        'YTickLabel',{'1','2','3','4','5'},...
        'TickLength',[0 0]);

% frequency domain
figure;
for locID = 1 : numLocation
    subplot(numLocation,1,locID)
    for impulseID = 1 : numImpulse
        sig1 = Loc{locID,ballID}(locRecord(locID,impulseID)-WIN1+1:locRecord(locID,impulseID)+WIN2);
        [sig1f, f, NFFT] = signalFreqencyExtract( sig1, Fs );
        plot(f, sig1f);hold on;    
    end
    hold off;
    if locID == 1
        title('Sensor 5, Golf');
    end
end 
