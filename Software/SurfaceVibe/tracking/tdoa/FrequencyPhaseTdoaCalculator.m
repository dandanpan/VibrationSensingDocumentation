classdef FrequencyPhaseTdoaCalculator < TdoaCalculator
    %FREQUENCYPHASETDOACALCULATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        freq
    end
    
    methods
        function obj = FrequencyPhaseTdoaCalculator(frequency)
           obj.freq = frequency; 
        end
        
        function tdoa = calculate(obj, time, signals)
            Fs = 1/(time(2)-time(1));
            time = time - time(1);
            % select a reference signal
            sigref = sin(2*pi*obj.freq*time);
            rfft = fft(sigref);
            
            % get the bin-index of frequency we are interested in
            bin = floor((obj.freq * 2)/Fs * length(rfft));
            
            % check how many columns
            [~,n] = size(signals);
            lags = zeros(1,n); % storage array
            
            % generate hamming window
            h = hamming(length(time));
            
            for idx = 1:n
                sig = signals(:,idx) .* h; % apply hamming window
                sig = SignalNormalization(sig);
                
                sfft = fft(sig);
                phase_rad = unwrap(angle(rfft(bin)/angle(sfft(bin))));
                
                lags(idx) = phase_rad;
            end
            tdoa = lags ./ (2*pi*obj.freq);
        end
    end
    
end

