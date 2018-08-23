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
    
load('cement24-swipe.mat');
wFilter = WaveletFilter();
wFilter.noiseMaxScale=30;
            

% Base frequency
f = 832;
P = 1/f;
Ps = floor(P*Fs);
wSize = 4*Ps;
svelocity = 5;
slocalizer = PairLocalizer(s, [1,1,1,1,1,1].*svelocity);
hilbertTdoa = HilbertTdoaCalculator(f);

bFilter = GainVaryingFilter(Fs);
bFilter.addBand(f-1,f+1,3,1);


for dirIdx = 1%1:8
    
    increaseWindow = [];
    for eIdx = 1:length(events{dirIdx})
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
        onePoint = localizer.resolve(oneTdoa./Fs);
        
        renderer = SurfaceRenderer(s);
        renderer.plot();
    
        renderer.addPoints(onePoint);
        
        e.data(1:increaseWindow(end)+2*Fs/100,:) = [];
        e.filter(bFilter);
        tdoas = e.getTdoa(hilbertTdoa);
        for sIdx = 1:4
            tdoas(:,sIdx) = tdoas(:,sIdx) - mean(tdoas(:,sIdx));
        end
        tdoas=downsample(tdoas,500);
        points = slocalizer.resolve(tdoas);
        renderer.addPoints(points);
        
%         figure;
%         plot(tdoas);
%         hold on;
%         plot(rawSig(increaseWindow(end)+2*Fs/100:end,2:5).*10);
%         hold on;
%         plot(e.data(:,2:5));
        
    end
end
