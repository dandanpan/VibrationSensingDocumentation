close all

init();

s = Surface([40 40]);
s.addSensor(0,0);
s.addSensor(1,0);
s.addSensor(0,1);
s.addSensor(1,1);
tdoaCalc = FirstPeakTdoaCalculator();
% first peak setting MPH = max(sig)/5;
% prepare renderer
velocity = 7000;
localizer = PairLocalizer(s, [1,1,1,1,1,1].*velocity);
slocalizer = Localizer(s, [1,1,1,1].*velocity);
    
load('cement24-swipe.mat');
wFilter = WaveletFilter();
wFilter.noiseMaxScale=30;
            
% Base frequency
f = 156;
P = 1/f;
Ps = floor(P*Fs);
wSize = 5*Ps;

bFilter = GainVaryingFilter(Fs);
bFilter.addBand(f-1,f+1,2,1);
bFilter.addBand(2*f-1,2*f+1,3,0.75);

for dirIdx = 1%1:8
    
    increaseWindow = [];
    for eIdx = 1%:length(events{dirIdx})
        e = events{dirIdx}(eIdx);
        if dirIdx == 1 && eIdx == 7
            e.data(1:11500,:) = [];
        end
        rawSig = e.data;
        eProfile = [];
        energyIdx = [];
        for swIdx = 1:Fs/100:length(rawSig)-Fs/100
            tempWinEnergy = [];
            for senIdx = 2:5
                tempE = sqrt(sum(rawSig(swIdx+1:swIdx+Fs/100,senIdx).^2));
                tempWinEnergy = [tempWinEnergy, tempE];
            end
            eProfile = [eProfile, sum(tempWinEnergy)];
            energyIdx = [energyIdx, swIdx];
            if swIdx > 1 && eProfile(end)-eProfile(end-1) > .5
                increaseWindow = [increaseWindow, swIdx];
                break;
            end
        end
%         e.plot();
%         hold on;
%         plot(energyIdx./Fs, eProfile./10); 
%         plot([increaseWindow(end), increaseWindow(end)]./Fs,[0,1],'r');
%         hold off;
        
        initSig = rawSig(increaseWindow(end)-Fs/100:increaseWindow(end)+2*Fs/100,:);
        filteredInit = wFilter.filter(initSig);
        filteredInit(1:100,:) = [];
        oneTdoa = [];
        MPH = max(filteredInit(:,2))/4;
        [p,i] = findpeaks(filteredInit(:,2),'MinPeakHeight',MPH,'Annotate','extents');hold on;
        oneTdoa = [oneTdoa, i(1)];
        MPH = max(filteredInit(:,3))/4;
        [p,i] = findpeaks(filteredInit(:,3),'MinPeakHeight',MPH,'Annotate','extents');hold on;
        oneTdoa = [oneTdoa, i(1)];
        MPH = max(filteredInit(:,4))/4;
        [p,i] = findpeaks(filteredInit(:,4),'MinPeakHeight',MPH,'Annotate','extents');hold on;
        oneTdoa = [oneTdoa, i(1)];
        MPH = max(filteredInit(:,5))/4;
        [p,i] = findpeaks(filteredInit(:,5),'MinPeakHeight',MPH,'Annotate','extents');hold off;
        oneTdoa = [oneTdoa, i(1)];
        
%         figure;plot(filteredInit(:,2:5));
        histTdoa = oneTdoa - oneTdoa(1);
        onePoint = localizer.resolve(oneTdoa./Fs);
        
        renderer = SurfaceRenderer(s);
        renderer.plot();
    
        renderer.addPoints(onePoint);
        
        e.data(1:increaseWindow(end)+2*Fs/100,:) = [];
        e.filter(bFilter);
        wholeSig = e.getSignals();
        allTdoas = [];
        allPoints = [];
        for swIdx = 1:wSize:length(wholeSig)-2*wSize
            % for each window, calculate the tdoa based on history
            % reference to sensor1
            tdoaCandi{1} = [0];
            refsig = wholeSig(swIdx+1:swIdx+wSize,1);
            for sIdx = 2:4
                sig = wholeSig(swIdx+1:swIdx+wSize,sIdx);
                [~,~,candiLag, candiVal] = TDoAMinShift( refsig, sig );
                tdoaCandi{sIdx} = [candiLag; candiVal'];
            end
            %% summarize all combination
            tdoaComb = []; tdoaConf = [];
            for sIdx = 1:size(tdoaCandi{2},2)
                for sIdx2 = 1:size(tdoaCandi{3},2)
                    for sIdx3 = 1:size(tdoaCandi{4},2)
                        tdoaComb = [tdoaComb; 0, tdoaCandi{2}(1,sIdx),tdoaCandi{3}(1,sIdx),tdoaCandi{4}(1,sIdx)];
                        tdoaConf = [tdoaConf; 1, tdoaCandi{2}(2,sIdx),tdoaCandi{3}(2,sIdx),tdoaCandi{4}(2,sIdx)];
                    end
                end
            end
            points = slocalizer.resolve(tdoaComb./Fs);
            allPoints = [allPoints; points];
%             renderer.addPoints(points);
%             for pIdx = 1:length(points)
%                 
%             end
            %% select TDoA closes to old one
%             tdoas = [0];
%             for sIdx = 2:4
%                 maxDiff = 10000; minTdoa = -1;
%                 for tIdx = 1:size(tdoaCandi{sIdx},2)
%                     diff = tdoaCandi{sIdx}(1,tIdx) - histTdoa(tIdx);
%                     if abs(diff) < maxDiff
%                         maxDiff = diff;
%                         minTdoa = tIdx;
%                     end
%                 end
%                 tdoas = [tdoas tdoaCandi{sIdx}(1,minTdoa)];
%             end
%             allTdoas = [allTdoas; tdoas];        
            
        end
%         points = slocalizer.resolve(allTdoas./Fs);
        renderer.addPoints(allPoints);
    end
end
