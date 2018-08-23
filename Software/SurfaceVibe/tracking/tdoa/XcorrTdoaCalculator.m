classdef XcorrTdoaCalculator < TdoaCalculator
    %XCORRTDOACALCULATOR TDoA computation using xcorr
    
    properties
    end
    
    methods
        function tdoa = calculate(~, time, signals)
            Fs = 1/(time(2)-time(1));
            
            % select a reference signal
            sigref = signals(:,1);
            sigref = SignalNormalization(sigref);
            % check how many columns
            [~,n] = size(signals);
            lags = zeros(1,n); % storage array
            for idx = 1:n
                sig = signals(:,idx);
                sig = SignalNormalization(sig);
                [cor, lag] = xcorr(sig,sigref);
                
                %% original code
%                 [~,I] = max(abs(cor));
%                 lagDiff = lag(I);
                 
                %% extract shift from cross correlation results
                [PKS,LOCS,W,P] = findpeaks(cor, 'MinPeakProminence', max(cor)/8);
                [c,I] = max(PKS);
                candidateShift = LOCS(I-1:I+1);
                candidateLag = lag(candidateShift);
                [cc, II] = min(abs(candidateLag));
                lagDiff = candidateLag(II);
                
                %% convert sample lag into time
                lags(idx) = lagDiff/Fs;
            end
            tdoa = lags;
%             tdoa = lags - min(lags);
        end
    end
    
end

