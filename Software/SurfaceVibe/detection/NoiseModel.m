classdef NoiseModel < handle
    %NOISEMODEL Creates a gaussian noise model from a noise sample
    
    properties
        mu
        sigma
        windowSize
    end
    
    methods
        
        function obj = NoiseModel(noiseSample, windowSize)
            if nargin < 2
                % default window size
                windowSize = 500; 
            end
            if nargin < 1
                error('Must provide a noise sample!');
            end
            
            % assumes the noise model is only signal data
            % can either be a single vertical array
            % or a vertical matrix of several signals
            
            obj.windowSize = windowSize;
            obj.build(noiseSample);
        end
        
        function build(obj, data)
            % the first column of data is the time info
            % extract only the signal components
            noiseSample = data(:, 2:end);
            
            % generate list of window start indices
            % each window is of size |obj.windowSize|
            % and has an offset of |obj.windowSize/2| from
            % the last window start
            startIdxs = 1:(obj.windowSize/2):(length(noiseSample)-1);
            
            % remove last 2 indices to make sure we don't go over the 
            % edge of the noise signal
            startIdxs = startIdxs(1:end-2);

            % generate storage array for window energy
            % we expect a total of |n| windows
            n = length(startIdxs);
            eV = zeros(n,1);
            
            % remove DC component
            m = mean(noiseSample);
            for idx = 1:length(m)
               noiseSample(:,idx) = noiseSample(:,idx) - m(idx);
            end
            
            % go through each window
            for idx = 1:n
                wStartIdx = startIdxs(idx);
                % extract the window (windowSize rows, all columns)
                window = noiseSample(wStartIdx:wStartIdx + obj.windowSize, :);
                
                % get the total energy for this window and save
                e = sum(sum(window.*window));
                eV(idx) = e;
            end

            % generate the gaussian noise model
            [obj.mu,obj.sigma] = normfit(eV);
        end
    end
    
end

