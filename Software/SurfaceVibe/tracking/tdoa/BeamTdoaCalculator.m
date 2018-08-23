classdef BeamTdoaCalculator < TdoaCalculator
    %BEAMTDOACALCULATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function tdoa = calculate(obj, time, signals)
            Fs = 1/(time(2)-time(1));
            % check how many columns
            [~,n] = size(signals);
            lags = zeros(1,n); % storage array
            % find the signal with highest energy
            sigEnergy = zeros(1,n);
            for idx = 1:n
                sig = signals(:,idx);
                sigEnergy(idx) = sum(sig.*sig);
            end
            % highest energy signal as reference signal
            [~,refIdx] = max(sigEnergy);
            [~,badIdx] = min(sigEnergy);
            sigref = signals(:,refIdx);
            MPH = max(sigref)/5;
            [~,loc] = findpeaks(sigref,'MinPeakHeight',MPH);
            figure;plot(sigref);
            hold on;
            plot([loc(1),loc(1)],[-0.02,0.02]);hold on;
            logref = loc(1);
            % find 
            for idx = 1:n
                sig = signals(max(1,logref-150):min(logref+100,length(signals)),idx);
                [~,shift] = max(sig);
%                 if shift == 1 || shift == length(sig)
%                     lags(idx) = NaN;
%                 else
%                     lags(idx) = shift-251;
%                 end
                lags(idx) = shift-151;
                plot(signals(:,idx));
                plot([loc(1)+lags(idx),loc(1)+lags(idx)],[-0.02,0.02]);
            end
%             hold off;
            tdoa = lags;% - min(lags);
            tdoa = tdoa./Fs;
%             tdoa(badIdx) = NaN;
        end
    end
    
end

