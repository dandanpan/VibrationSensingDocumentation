classdef FirstPeakTdoaCalculator < TdoaCalculator
    %FirstPeakTdoaCalculator tdoa based on first peak of signals
    
    properties
    end
    
    methods
        
        % calculate
        % given a 1-d vector for time and a matrix of signals
        % compute the tdoa between the given set of signals
        function [tdoa, tdoa2] = calculate(obj, time, signals)
            Fs = 1/(time(2)-time(1));
            % check how many columns
            [~,n] = size(signals);
            lags = zeros(1,n); % storage array
            % find weakest signal

            signalE = zeros(n,1);
            for idx = 1:n
                sig = signals(:,idx);
                signalE(idx) = max(sig);%sum(sig.*sig);
            end
            maxE = max(signalE);
            [~, minI] = min(signalE);
            MPH = max(signals(:,minI))*0.5;%0.75; % iron
            for idx = 1:n
                sig = signals(:,idx);
%                 MPH = max(sig)/6; %tile /8/4/5
                [~,loc] = findpeaks(sig,Fs,'MinPeakHeight',MPH);

                
%             [minE, minI] = min(signalE);
%             MPH = max(signals(:,minI))*0.75; % 0.5;% iron
%             for idx = 1:n
%                 sig = signals(:,idx);
%                 if max(sig) < maxE/4
%                     MPH = max(sig)/4;
%                 else
%                     MPH = max(sig)/8;
%                 end
%                 MPH = max(sig)/8;
%                 MPH = max(sig)/6; %tile
                % get time of first peak for each signal
%                 [~,loc] = findpeaks(sig,Fs,'MinPeakHeight',MPH);
                % debug
%                 findpeaks(sig,Fs,'MinPeakHeight',MPH); hold on;
                
                if length(loc) >=1
                    lags(idx) = loc(1);
                else
                    lags(idx) = -1;
                end
            end
            hold off;
            tdoa = lags;% - min(lags);
            
            lags2 = zeros(1,n); % storage array
            for idx = 1:n
                sig = -signals(:,idx);
                MPH = max(sig)/2;
                % get time of first peak for each signal
                [~,loc] = findpeaks(sig,Fs,'MinPeakHeight',MPH);
                lags(idx) = loc(1);
            end
            
            tdoa2 = lags2;
        end
        
    end
    
end