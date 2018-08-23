classdef WaveletFilter < handle
    %WAVELETFILTER A filter using wavelet analysis

    properties
        noiseMaxScale
        windowSize
        scales
        wavelet
    end

    methods

        function obj = WaveletFilter(windowSize, scales, wavelet)
            if nargin < 3
               wavelet = 'mexh';
            end
            if nargin < 2
                scales = (1:1024);
            end
            if nargin < 1
               windowSize = 5000;
            end
            obj.windowSize = windowSize;
            obj.scales = scales;
            obj.wavelet = wavelet;
            obj.noiseMaxScale = 50;
        end

        function setNoiseSample(obj, noiseSample)
            n = size(noiseSample,2)-1;
            s = zeros(n,1);
            parfor idx = 1:n
              signal = noiseSample(:,idx+1);
              [ ~, maxScale, ~, totalEnergy ] = waveletAnalysis(signal, obj.windowSize, obj.scales, obj.wavelet);
              s(idx) = maxScale;
              figure;plot(totalEnergy);title(num2str(idx));
            end
            obj.noiseMaxScale = round(mean(s));
        end

        function filteredData = filter(obj, data)
            % the first column of data is the time info
            % filter only the signal components
            dimen = size(data);
            filteredData = zeros(dimen);

            % copy over the time data
            filteredData(:,1) = data(:,1);

            % filter the signals
            parfor col = 2:dimen(2)
                signal = data(:,col);

                % remove DC component
                signal = signal - mean(signal);

                [ COEFS, ~, ~ ] = waveletAnalysisTemplate(signal, obj.windowSize, obj.scales, obj.wavelet);
                % shijia -- used to be just waveletAnalysis in the plot
                % folder
                signal = waveletFilterTemplate(COEFS, obj.noiseMaxScale);
                filteredData(:,col) = signal;
            end
        end

    end

end
