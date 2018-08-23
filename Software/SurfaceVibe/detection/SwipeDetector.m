classdef SwipeDetector < EventDetector
    %SwipeDetector a detector class for swipes

    properties
       minLength 
    end
    
    methods
        function obj = SwipeDetector(noiseModel, threshold, minLength)
           if nargin < 3
              minLength = 20 * noiseModel.windowSize; 
           end
           obj@EventDetector(noiseModel, threshold); 
           obj.minLength = minLength;
        end
        
        function eventData = extractEvent(obj, data, startIdx, endIdx)
            
            % this is only a valid swipe if length is greater than 
            if (endIdx - startIdx) < obj.minLength
               eventData = []; 
            else 
               eventData = data(startIdx:endIdx, :); % extract the whole signal
               
               % smoothen out the signal
%                for sIdx = 2:size(eventData,2)
%                   eventData(:,sIdx) = smooth(eventData(:,sIdx),20); 
%                end
               
            end
        end
        
        function event = packEvent(obj, eventData)
            event = SwipeEvent('', '', eventData); 
        end
        
    end
    
end

