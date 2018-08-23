function [ TDoAs, peakTime, peakVal ] = TDoAExtraction2( signals, sensorSet, draw )
%TDOAEXTRACTION Summary of this function goes here
%   cluster the peaks
    if nargin < 3
        draw = 0;
    end
    subWindowSize = 0.02;
    sensorNum = length(sensorSet);
    TDoAs = [];
    if draw == 1
        figure;
    end
    
    peakValSum = [];
    for baseSensorID = 1:sensorNum
        stepSig = signals{sensorSet(baseSensorID)}(:,2);
        [ peakLoc{baseSensorID}, peakVal{baseSensorID} ] = inStepPeakExtraction( stepSig, 1/3 );
        peakTime{baseSensorID} = signals{sensorSet(baseSensorID)}(peakLoc{baseSensorID},1);
        peakValSum = [peakValSum, max(abs(peakVal{baseSensorID}))];
%         if length(peakLoc{baseSensorID}) > peakNum
%             peakNum = length(peakLoc{baseSensorID});
%             peakIdx = baseSensorID;
%         end
    end
    
%     [~, refID] = max(peakValSum);
%     firstRefPeakVal = peakVal{baseSensorID}(1);
%     firstRefPeakLoc = peakLoc{baseSensorID}(1);
%     for baseSensorID = 1:sensorNum
%         
%     end
    
    % match the rest of the sensor peaks find min sum error^2
%     peakNum = length(peakLoc{refID});
%     peakLocs = zeros(sensorNum, peakNum);
%     peakVals = zeros(sensorNum, peakNum);
%     for baseSensorID = 1:sensorNum
%         % calcuate the position: mean error
%         minPeakDiff = 10000;
%         for peakID = 1:peakNum
%             comparePeaks = peakLoc{baseSensorID}
%         end
%     end
    
    
    for baseSensorID = 1:sensorNum
        if draw == 1
            plot(signals{sensorSet(baseSensorID)}(:,1), signals{sensorSet(baseSensorID)}(:,2));hold on;
            plot(signals{sensorSet(baseSensorID)}(peakLoc{baseSensorID},1), peakVal{baseSensorID},'rv');hold on;
        end 
    end
    if draw == 1
        hold off;
    end
    
    %% test 
%     x = []; y = [];l = [];
%     for i = 1:4
%         x = [x; peakLoc{i}];
%         y = [y; peakVal{i}];
%         l = [l; ones(size(peakVal{i})).*i];
%     end
%     [ xNorm ] = featureNorm( x );
%     [ yNorm ] = featureNorm( y );
%     [ clusters, nodeContainsLeave ] = hClustering( [x, y], 0, 0.002 );
% %     figure;
% %     for i = 1:length(clusters)
% %         scatter(x(clusters{i}),y(clusters{i}));hold on;
% %     end
% %     hold off;
%     clusters
    
end

