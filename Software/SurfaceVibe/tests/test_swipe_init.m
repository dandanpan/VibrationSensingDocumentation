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
    
load('data/drive/dataset/cement24-swipe.mat');
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
        
        h=figure();
        title(num2str(dirIdx, 'Direction %d'));
                
        e = events{dirIdx}(eIdx);
        if dirIdx == 1 && eIdx == 7
            e.data(1:11500,:) = [];
        end
        subplot(3,3,1);
        e.plot(0,h);
        
        [ onePoint, initIdx, e ] = initPartExtract( e, Fs, wFilter, localizer );
        increaseWindow = [increaseWindow, initIdx];
        [ selectedBand ] = bandSelection( e, 600, Fs );
        
        hilbertTdoa = HilbertTdoaCalculator(selectedBand);
        bFilter = GainVaryingFilter(Fs);
        bFilter.addBand(selectedBand-1,selectedBand+1,3,1);
        e.filter(bFilter);
        
        %plot the filtered signal
        subplot(3,3,1);
        e.plot(0,h);

        tdoas = e.getTdoa(hilbertTdoa);

        resultSet{eIdx} = tdoas;

        tdoas = resultSet{eIdx};
        % remove first 5000 samples and remove mean component
        time = e.getTime();
        time = time - time(1);
        pIndices = 1:length(time);

        tdoas = tdoas(5000:end-5000,:);
        pIndices = pIndices(5000:end-5000);
        tdoas(:,1) =  smooth(tdoas(:,1) - mean(tdoas(:,1)),100);
        tdoas(:,2) =  smooth(tdoas(:,2) - mean(tdoas(:,2)),100);
        tdoas(:,3) =  smooth(tdoas(:,3) - mean(tdoas(:,3)),100);
        tdoas(:,4) =  smooth(tdoas(:,4) - mean(tdoas(:,4)),100);
        tdoas = downsample(tdoas,500);
        pIndices = downsample(pIndices,500);
        pTime = time(pIndices);

        % plot the points over the raw signal
        subplot(3,3,1);
        hold on;
        scatter(pTime , zeros(size(pTime)), [], linspace(1,10,length(pTime)));

        subplot(3,3,4);
        hold on;
        scatter(pTime , zeros(size(pTime)), [], linspace(1,10,length(pTime)));

        subplot(3,3,[2 3]);
        hold on;
        scatter(pTime , zeros(size(pTime)), [], linspace(1,10,length(pTime)));

        % plot the tdoas
        subplot(3,3,7);
        plot(pTime, tdoas);
        hold on;
        scatter(pTime , zeros(size(pTime)), [], linspace(1,10,length(pTime)));

%                 subplot(rows,cols,rIdx);
        renderer = SurfaceRenderer(s);
        subplot(3,3,[5 6 8 9]);
        renderer.plot(h);renderer.addPoints(onePoint);
        points = slocalizer.resolve(tdoas);
        renderer.addPoints(points);
        title([num2str(eIdx, 'Swipe %d ') num2str(dirIdx, 'Direction %d ') num2str(selectedBand, 'Band %d')]);
    end
end
