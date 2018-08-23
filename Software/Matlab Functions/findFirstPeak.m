function [ firstPeakIdx ] = findFirstPeak( signal, minHeight )
%FINDFIRSTPEAK Summary of this function goes here
%   Detailed explanation goes here
% 
%     deltaSig = signal(2:end)-signal(1:end-1);
%     inPeak = 0;
%     peakStart = 0;
%     peakEnd = 0;
%     
%     for i = 1 : length(deltaSig)
%         if deltaSig(i) > minHeight/3 && inPeak == 0
%             inPeak = 1;
%             peakStart = i;
%         elseif inPeak == 1 && deltaSig(i) < -minHeight/3
%             inPeak = 0;
%             peakEnd = i;
%             break;
%         end
%     end
%     firstPeakIdx = round((peakEnd+peakStart)/2);
    
    for i = 5 : length(signal)-5
        if (signal(i) - signal(i-2) > 0 &&...
           signal(i-2) - signal(i-4) > 0 &&...
           signal(i+2) - signal(i) < 0 &&...
           signal(i+4) - signal(i+2) < 0 &&...
           signal(i) > minHeight) || ...
            (signal(i) - signal(i-2) > 100 &&...
           signal(i-2) - signal(i-4) > 100 &&...
           abs(signal(i+2) - signal(i)) < 2 &&...
           abs(signal(i+4) - signal(i+2)) < 2 &&...
           signal(i) > minHeight) || ...
           (signal(i) - signal(i-2) > 0 &&...
           signal(i-2) - signal(i-4) > 0 &&...
           signal(i) >= 490)
            firstPeakIdx = i;
            break;
        end
    end
    
    
    
%     for i = 5 : length(signal)-5
%         if (signal(i) - signal(i-2) > 0 &&...
%            signal(i-2) - signal(i-4) > 0 &&...
%            signal(i+2) - signal(i) < 0 &&...
%            signal(i+4) - signal(i+2) < 0 &&...
%            signal(i) > minHeight)
%             firstPeakIdx = i;
%             break;
%         end
%         if  (signal(i) - signal(i-2) > 50 &&...
%            signal(i-2) - signal(i-4) > 50 &&...
%            abs(signal(i+2) - signal(i)) < 2 &&...
%            abs(signal(i+4) - signal(i+2)) < 2 &&...
%            signal(i) > minHeight) 
%              endIdx = 1000;
%              for j = 4:2:1000
%                 if (signal(i+j+2) - signal(i+j)) < -50
%                     endIdx = j;
%                     break;
%                 end
%             end
%                 
%             firstPeakIdx = round((i+endIdx)/2);
%             break;
%         end
%         if (signal(i) - signal(i-2) > 0 &&...
%            signal(i-2) - signal(i-4) > 0 &&...
%            signal(i) >= 490)
%             firstPeakIdx = i;
%             break;
%         end
%     end
end

