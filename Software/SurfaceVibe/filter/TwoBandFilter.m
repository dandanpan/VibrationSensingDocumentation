classdef TwoBandFilter
    %TWOBANDFILTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        samplingFreq
        startFreq1
        stopFreq1
        startFreq2
        stopFreq2
        order
    end
    
    methods
         function obj = TwoBandFilter(Fs, start1, stop1, start2, stop2, order)
            obj.samplingFreq = Fs;
            obj.startFreq1 = start1;
            obj.stopFreq1 = stop1;
            obj.startFreq2 = start2;
            obj.stopFreq2 = stop2;
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
            [b1,a1] = butter(obj.order, [obj.startFreq1, obj.stopFreq1]/(obj.samplingFreq/2), 'bandpass');
            [b2,a2] = butter(obj.order, [obj.startFreq2, obj.stopFreq2]/(obj.samplingFreq/2), 'bandpass');

            H1 = dfilt.df2t(b1,a1);
            H2 = dfilt.df2t(b2,a2);
            Hpar=dfilt.parallel(H1,H2);

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

