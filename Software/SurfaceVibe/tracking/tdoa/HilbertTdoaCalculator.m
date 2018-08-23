classdef HilbertTdoaCalculator < TdoaCalculator
    %HILBERTTDOACALCULATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        freq
        windowed
    end
    
    methods
        function obj = HilbertTdoaCalculator(frequency, windowed)
            if nargin < 2
               windowed = false; 
            end
           obj.freq = frequency; 
           obj.windowed = windowed;
        end
        
        function tdoa = calculate(obj, time, signals)
            Fs = 1/(time(2)-time(1));
            time = time - time(1);
            % select a reference signal
            sigref = sin(2*pi*obj.freq*time);            
            sigref = SignalNormalization(sigref);
            
            % check how many columns
            [~,n] = size(signals);
            lags = zeros(length(time),n); % storage array
            hRef = hilbert(sigref);        
           
            for idx = 1:n
                sig = signals(:,idx);
                sig = SignalNormalization(sig);
                subplot(3,3,4);
                hold on;
                plot(time,sig);

                %% find the hilbert transform
                hSig = hilbert(sig);
                hSig = hSig - mean(hSig);
                %% find the phase shift switch
                % find the envelope of the signal
%                 cutOffset = 10;
%                 [PCK,LOC] = findpeaks(sig);
%                 [~,shiftSpot] = findpeaks(-PCK);
%                 % organize the detected chunks
%                 if ~isempty(shiftSpot)
%                     validIdx{idx} = [1:LOC(max(1,shiftSpot(1)-cutOffset))];
%                     for chunkIdx = 1:length(shiftSpot)-1
%                         validIdx{idx} = [validIdx{idx}, LOC(min(shiftSpot(chunkIdx)+cutOffset,length(LOC))):LOC(min(shiftSpot(chunkIdx+1)-cutOffset,length(LOC)))];
%                     end 
%                     validIdx{idx} = [validIdx{idx}, LOC(min(shiftSpot(end)+cutOffset,length(LOC))):length(sig)];
%                 else
%                     validIdx{idx} = [1:length(sig)];
%                 end
                    
                subplot(3,3,[2 3]);
                hold on;
                plot(time,angle(hSig));
                
                phase_rad = unwrap(angle(hRef) - angle(hSig));
                
                lags(:,idx) = phase_rad;
            end
            
            tdoa = lags;
            return;
            
            refIdx = validIdx{1};
            for sIdx = 2:n
                refIdx = intersect(refIdx, validIdx{sIdx});
            end
            % find cutting points
            cuttingPoints = find(diff(refIdx) > 100);
            if ~isempty(cuttingPoints)
                vIdxGroup{1} = [1:refIdx(cuttingPoints(1))];
                for vIdx = 1:length(cuttingPoints)-1
                    vIdxGroup{vIdx+1} = [refIdx(cuttingPoints(vIdx)+1):refIdx(cuttingPoints(vIdx+1))];
                end
                vIdxGroup{length(cuttingPoints)+1} = [refIdx(cuttingPoints(end)+1:end)];
                
            else
                vIdxGroup{1} = refIdx;
            end
            vGroupNum = length(vIdxGroup);
            blackList = [];
            for vIdx = 1:vGroupNum
                if length(vIdxGroup{vIdx}) < 500
                    blackList = [blackList, vIdx];
                end
            end
            vIdxGroup(blackList) = [];
            
            vGroupNum = length(vIdxGroup);
            
            for vIdx = 1:vGroupNum
                ref = lags(vIdxGroup{vIdx},1);
                ref = ref - mean(ref);
                vGroupSig{vIdx} = [ref];
                for sIdx = 2:4
                    sig = lags(vIdxGroup{vIdx},sIdx);
                    sig = sig - mean(sig);
                    sigPlusPi = sig + pi;
                    sigMinusPi = sig - pi;
                    
                    diffArea = sum(abs(ref-sig));
                    diffAreaPlusPi = sum(abs(ref-sigPlusPi));
                    diffAreaMinusPi = sum(abs(ref-sigMinusPi));
                    
                    [~, daIdx] = min([diffArea, diffAreaPlusPi, diffAreaMinusPi]);
                    if daIdx == 1
                        vGroupSig{vIdx} = [vGroupSig{vIdx}, sig];
                    elseif daIdx == 2
                        vGroupSig{vIdx} = [vGroupSig{vIdx}, sigPlusPi];
                    elseif daIdx == 3
                        vGroupSig{vIdx} = [vGroupSig{vIdx}, sigMinusPi];
                    end
                    
                end
            end
            
            %% find phase jump location
            %% adjust cycles based on a reference
            % they should not be farther than +/- pi from the reference
            
%             for otherIdx = 1:4
%                 ref = lags(:,1);
%                 other = lags(:,otherIdx);
%                 
%                 ref = ref - mean(ref);
%                 other = other - mean(other);
%                 
%                 otherPlusPi = other+pi;
%                 otherMinusPi = other-pi;
%                 
%                 others = [otherPlusPi-ref other-ref otherMinusPi-ref];
%                 [~,otherErrors] = min(abs(others),[],2);
%                 
%                 for i = 1:length(otherErrors)
%                    lags(i,otherIdx) = others(i,otherErrors(i)) + ref(i); 
%                 end
%             end

            ref = lags(:,1);
            ref = ref - mean(ref);
            for otherIdx = 1:4
                other = lags(:,otherIdx);
                lags(:,otherIdx) = other - mean(other);
                
                % find shared area
                
            end

            subplot(3,3,4);
            hold on;
            plot(time,sigref);
            
            subplot(3,3,[2 3]);
            hold on;
            plot(time,angle(hRef));
            
            tdoa = [];
            for vIdx = 1:length(vGroupSig)
%                 figure;plot(vGroupSig{vIdx});
                tdoa = [tdoa; vGroupSig{vIdx}];
            end
            
%             tdoa = lags;
        end
    end
    
end

