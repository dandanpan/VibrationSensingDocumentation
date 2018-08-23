classdef GainVaryingFilter < handle
    %GAINVARYINGFILTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        samplingFreq
        bands
        bandCount
    end
    
    methods
         function obj = GainVaryingFilter(Fs)
            obj.samplingFreq = Fs;
            obj.bandCount = 0;
         end
         
         function addBand(obj, start, stop, order, gain)
            if nargin < 5
               gain = 1; 
            end
            idx = obj.bandCount+1;
            obj.bands{idx} = {[start stop], order, gain};
            obj.bandCount = idx;
         end
        
         function filteredData = filter(obj, data)
            % the first column of data is the time info
            % filter only the signal components
            dimen = size(data);
            filteredData = zeros(dimen);
            
            % copy over the time data
            filteredData(:,1) = data(:,1);
            
            % for each band, filter the original signal and multiply by the
            % gain. Then accumulate the data into filteredData
            for bIdx = 1:obj.bandCount
               bandData = zeros(dimen); % leave time as zero
               band = obj.bands{bIdx};
               
               % construct the band filter
               cutOffs = band{1};
               order = band{2};
               gain = band{3};
               [b,a] = butter(order, cutOffs/(obj.samplingFreq/2), 'bandpass');
               
               for col = 2:dimen(2)
                    signal = data(:,col);
                    % remove DC component
                    signal = signal - mean(signal);
                    bandData(:,col) = gain .* filter(b,a,signal);
               end
               
               filteredData = filteredData + bandData;
            end
            
        end
    end
    
end

