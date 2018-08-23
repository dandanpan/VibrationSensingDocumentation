classdef MultiBandFilter
    %MULTIBANDFILTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        samplingFreq
        bands
        order
    end
    
    methods
        function obj = MultiBandFilter(Fs, bands, order)
            obj.samplingFreq = Fs;
            obj.bands = bands;
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
            H = [];
            for m = 1:size(obj.bands,1)
                band = obj.bands(m,:);
                [b,a] = butter(obj.order, [band(1), band(2)]/(obj.samplingFreq/2), 'bandpass');
                H = [H dfilt.df2t(b,a)];
            end
            Hpar=dfilt.parallel(H);

            % filter the signals
            for col = 2:dimen(2)
                signal = data(:,col);
                % remove DC component
                signal = signal - mean(signal);
                filteredData(:,col) = filter(Hpar,signal);
            end
        end
    end
    
end

