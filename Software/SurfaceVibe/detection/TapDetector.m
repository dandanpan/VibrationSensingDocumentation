classdef TapDetector < EventDetector
    %TapDetector a detector class for taps

    properties
       minLength 
       
       % samples before event peak to consider as part of the signal
       startMargin
       endMargin
       minAmplitude
    end
    
    methods
        function obj = TapDetector(noiseModel, threshold, startMargin, endMargin, minAmplitude)
           if nargin < 5
              minAmplitude = 0.5; 
           end
           if nargin < 4
              startMargin = 500;
              endMargin = 500;
           end
           obj@EventDetector(noiseModel, threshold); 
           obj.startMargin = startMargin;
           obj.endMargin = endMargin;
           obj.minAmplitude = minAmplitude;
        end
        
        function eventData = extractEvent(obj, data, startIdx, endIdx)
            % extract the suspected event range
            % select one channel to find peaks on
            signalRange = data(startIdx:endIdx, 2);

            % find the local peak in the range
            % this is most likely the initial tap event
            [peak, localPeak] = max(abs(signalRange));

            if peak > obj.minAmplitude
                % index relative to start of entire |signal|
                eventPeakIdx = startIdx + localPeak - 1;

                % extract the signal
                startIdx = max(eventPeakIdx - obj.startMargin, startIdx);
                stopIdx = max(eventPeakIdx + obj.endMargin, endIdx);
                eventData = data(startIdx:stopIdx, :);
            else 
                eventData = [];
            end
            
        end
           
        function event = packEvent(obj, eventData)
            event = TapEvent('', '', eventData); 
        end
        
    end
    
end

