classdef BandPassFilter
    %BANDPASSFILTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        samplingFreq
        startFreq
        stopFreq
        order
    end
    
    methods
        
        function obj = BandPassFilter(Fs, start, stop, order)
            obj.samplingFreq = Fs;
            obj.startFreq = start;
            obj.stopFreq = stop;
            obj.order = order;
        end
        
        function filteredData = filter(obj, data)
            % the first column of data is the time info
            % filter only the signal components
            dimen = size(data);
            filteredData = zeros(dimen);
            
            % copy over the time data
            filteredData(:,1) = data(:,1);
            
            % build the filter
            [b,a] = butter(obj.order, [obj.startFreq, obj.stopFreq]/(obj.samplingFreq/2), 'bandpass');
            
            % filter the signals
            for col = 2:dimen(2)
                signal = data(:,col);
                % remove DC component
                signal = signal - mean(signal);
                filteredData(:,col) = filter(b,a,signal);
            end
        end
        
    end
    
end

