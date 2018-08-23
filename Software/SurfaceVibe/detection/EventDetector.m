classdef EventDetector < handle
    %EVENTDETECTOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % the noise model to compare against
        noiseModel
        
        % the sigma distance from the mean to say
        % that a window has an event
        threshold
    end
    
    methods
        
        % constructor
        function obj = EventDetector(noiseModel, threshold)
            if nargin == 0
               error('Must provide a noise model!'); 
            end
            obj.noiseModel = noiseModel;
            obj.threshold = threshold;
        end
        
        % sweep through signals (vertical array or matrix)
        function [events, energyWindows] = sweep(obj, data)
            events = [];
            windowSize = obj.noiseModel.windowSize;
            
            % the first column of data is the time info
            % extract only the signal components
            signal = data(:, 2:end);

            % state machine states
            % 0 when previous frame is noise, 
            % 1 when previous frame is part of an event
            state = 0;
            
            % generate list of window start indices
            % each window is of size |windowSize|
            % and has an offset of |windowSize/2| from
            % the last window start
            startIdxs = 1:(windowSize/2):(length(signal)-1);
            
            % remove last 2 indices to make sure we don't go over the 
            % edge of the noise signal
            startIdxs = startIdxs(1:end-2);
            
            % number of windows to process
            n = length(startIdxs);
            
            energyWindows = zeros(n,1);
            
            % remove dc component
            mu = mean(signal);
            for idx = 1:length(mu)
               signal(:,idx) = signal(:,idx) - mu(idx);
            end
            
            for idx = 1:n
                wStartIdx = startIdxs(idx);
                window = signal(wStartIdx:wStartIdx + windowSize, :);
                windowEnergy = sum(sum(window.*window));
                energyWindows(idx) = windowEnergy;
                if abs(windowEnergy - obj.noiseModel.mu) < obj.noiseModel.sigma * obj.threshold
                    % this window is noise
                    
                    % if previous window was part of an event, 
                    % do extraction
                    if state == 1
                        eventEndIdx = wStartIdx;
                        eventData = obj.extractEvent(data, eventStartIdx, eventEndIdx);
                        
                        if size(eventData, 1) > 0
                            event = obj.packEvent(eventData); 
                            events = [events event];
                        end
                    end
                    
                    % reset state to noise window
                    state = 0;
                else
                    % this window is part of a potential event
                    % mark step start if previous window was noise
                    if state == 0
                        state = 1; 
                        eventStartIdx = wStartIdx;
                    end
                end
                
            end
            
        end
        
        function eventData = extractEvent(obj, data, startIdx, endIdx)
            % nothing special
            eventData = data(startIdx:endIdx, :);
        end
        
        function event = packEvent(obj, eventData)
            event = Event('', '', eventData); 
        end
    end
    
end

