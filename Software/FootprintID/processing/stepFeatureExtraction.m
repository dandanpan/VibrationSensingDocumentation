function [ features ] = stepFeatureExtraction( stepSig, draw, TorF )
%STEPFEATUREEXTRACTION Summary of this function goes here
%   stepSig is the input vibration signal of a single footstep events
%   draw indicates whether the visualization need to be achieve in function
%   TorF indicates the time or frequency domain features
%   TorF = 1 for time domain
%   TorF = 2 for frequency domain

    if nargin == 1
        draw = 0;
        TorF = 1;
    end
    features = [];
    cutoffFrequency = 200;
%     figure; 
    if TorF == 1
        %% time domain feature
        tempThresh = max(stepSig)/4;
        [ tempV ,tempI ] = findPeakValley(stepSig,10,tempThresh,tempThresh/3);
%         [ peakV ,peakI ] = findpeaks(stepSig,'MinPeakDistance',10,'MinPeakHeight',tempThresh, 'MinPeakProminence', tempThresh/3,'Annotate','extents');
%         [ valleyV ,valleyI ] = findpeaks(-stepSig,'MinPeakDistance',10,'MinPeakHeight',tempThresh,'MinPeakProminence', tempThresh/3,'Annotate','extents');
%         tempV = [peakV valleyV];
%         tempI = [peakI valleyI];
%         [~,iorder] = sort(tempI);
%         tempI = tempI(iorder);
%         tempV = tempV(iorder);
        [~, maxI] = max(abs(tempV));
        tempI = tempI(maxI:end);
        tempV = tempV(maxI:end);
        if length(tempV) > 1
            P = polyfit(tempI,tempV,1);
            x = [1, 400];
            yfit = P(1)*x+P(2);
        end
        if draw == 1
            subplot(3,1,1);
            plot(stepSig);hold on;
            for i = 1 : length(tempI);
                scatter(tempI, tempV, 'rV');
            end
            if length(tempV) > 1
                plot(x,yfit);
            end
            hold off;
        end
    elseif TorF == 2
    
        %% frequency domain feature
        [ Y, f, NFFT] = signalFreqencyExtract( stepSig, 1000 );
        Y = Y(f<=cutoffFrequency);
        f = f(f<=cutoffFrequency);
        Y = signalNormalization(Y);
        YCum = Y;
        for iY = 2 : length(Y)
            YCum(iY) = YCum(iY) + YCum(iY-1);
        end
        
        tempThresh = max(Y)/5;
        [ peakV ,peakI ] = findPeakValley(Y,2,tempThresh,tempThresh/2);
%         [ peakV ,peakI, W,P ] = findpeaks(Y,'MinPeakDistance',2,'MinPeakHeight',tempThresh,'MinPeakProminence', tempThresh/2,'Annotate','extents');
        features = [peakV ,peakI];
        if draw == 1
            subplot(3,1,2);
%             findpeaks(Y,'MinPeakHeight',tempThresh,'MinPeakProminence', tempThresh/2,'Annotate','extents');
%             plot(f,Y);hold on;
            plot(f,Y);hold on;

            for i = 1 : length(peakI);
                scatter(f(peakI), peakV, 'rV');
            end
            hold off;
        end
    elseif TorF == 3
        % try different features
        
    end
    
    
end

