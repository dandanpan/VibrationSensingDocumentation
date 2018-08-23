classdef GccPhatTdoaCalculator < TdoaCalculator
    %GCCPHATTDOACALCULATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        freq
    end
    
    methods
        function obj = GccPhatTdoaCalculator(frequency)
           obj.freq= frequency; 
        end
        
        function tdoa = calculate(obj, time, signals)
            Fs = 1/(time(2)-time(1));
            
            % generate a reference signal
            sigref = sin(2*pi*obj.freq*time);
            sigref = SignalNormalization(sigref);
            % check how many columns
            [~,n] = size(signals);
            lags = zeros(1,n); % storage array
            for idx = 1:n
                sig = signals(:,idx);
                sig = SignalNormalization(sig);
                [~, lag] = gccphat(sig,sigref);
                lags(idx) = lag/Fs;
            end
            
            tdoa = lags;
        end
    end
    
end

