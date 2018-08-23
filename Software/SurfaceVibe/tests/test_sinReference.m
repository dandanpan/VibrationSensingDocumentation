close all;

init();

s = Surface([40 40]);
s.addSensor(0,0);
s.addSensor(1,0);
s.addSensor(0,1);
s.addSensor(1,1);


dataSets{1} = 'tile1';
dataSets{2} = 'tile2';
dataSets{3} = 'tile3';
dataSets{4} = 'panel40';
dataSets{5} = 'stone24';
dataSets{6} = 'tile16';
dataSets{7} = 'cement24';
dataSets{8} = 'wood24';

for dSet = 8%1:length(dataSets)
        directory = ['data/drive/20160906/' dataSets{dSet} '-dampened'];
        
    for direction = 0:7
        filename = [dataSets{dSet} num2str(direction,'-swipe%05d.txt')];
        d = DataLoader(filename, directory);

        windowSize = 10000;
        % Build a noise model
        data = d.getData();
        nModel = NoiseModel(data(1:80000,:), windowSize);

        t1 = data(1,1);
        t2 = data(2,1);
        Fs = 1/(t2-t1);

        threshold = 3;
        minLength = 3 * windowSize;
        detector = SwipeDetector(nModel, threshold, minLength);
        
        for band = 40% [400:5:420]% [470 480 490 500 510 520 530]%[125 250 400 500]
            events = detector.sweep(data);
            
            % Base frequency
            f = band;
            P = 1/f;
            Ps = floor(P*Fs);
            wSize = 4*Ps;
            velocity = 15;

            localizer = PairLocalizer(s, [1,1,1,1,1,1].*velocity);
            
            xcorrTdoa = XcorrTdoaCalculator();
            phatTdoa = GccPhatTdoaCalculator(f);
            hilbertTdoa = HilbertTdoaCalculator(f,true);
            fTdoa = FrequencyPhaseTdoaCalculator(f);
            tdoaCalc = WindowedTdoaCalculator(hilbertTdoa, wSize);

            bFilter = GainVaryingFilter(Fs);
            bFilter.addBand(f-1,f+1,3,1);

            scrsz = get(groot,'ScreenSize');            
            nEvents = length(events);
            resultSet = cell(nEvents,1);
            
            % extract data
%             parfor eIdx = 1:nEvents
%                 e = events(eIdx);
%                 e.filter(bFilter);
%                 tdoas = e.getTdoa(hilbertTdoa);
% 
%                 resultSet{eIdx} = tdoas;
%             end
%             
            folderName = sprintf('data/OrganizedData/Results/%s', dataSets{dSet});
            mkdir(folderName);
            fName = sprintf('%s-Band_%d-Direction_%d', dataSets{dSet}, band, direction+1);
%             save([folderName '/' fName '.mat'], 'resultSet', 'filename', 'velocity', 'band', 'direction');
            
            figName = [dataSets{dSet} ' ' num2str(band, 'Band %d') ' ' num2str(direction+1, 'Direction %d')];
            % plot and save the figures
            
            cols = 5;
            rows = ceil(nEvents/cols);
            
            for rIdx = 1:min(nEvents,2)
                h=figure('Name', figName, 'Position', [1 1 scrsz(3) scrsz(4)]);
                
                e = events(rIdx);
                
%                 Fs = 25000;
%                 wFilter = WaveletFilter();
%                 wFilter.noiseMaxScale=14;
%                 tapLocalizer = PairLocalizer(s, [1,1,1,1,1,1]*24000);
%                 [initLoc, initIdx, e, initTdoa] = initPartExtract( event, Fs, wFilter, tapLocalizer );
                                
                % plot the original signal
                subplot(3,3,1);
                event.plot(0,h);
                
                e.filter(bFilter);
%                 e.data = e.data(5000:end,:);
                                
                % plot the filtered signal
%                 subplot(3,3,1);
%                 e.plot(0,h);
                
                tdoas = e.getTdoa(hilbertTdoa);

                resultSet{rIdx} = tdoas;
                
                tdoas = resultSet{rIdx};
                % remove first 5000 samples and remove mean component
                time = e.getTime();
                time = time - time(1);
                pIndices = 1:length(time);
                
%                 tdoas = tdoas(5000:end-5000,:);
%                 pIndices = pIndices(5000:end-5000);
%                 tdoas(:,1) =  smooth(tdoas(:,1) - mean(tdoas(:,1)),100);
%                 tdoas(:,2) =  smooth(tdoas(:,2) - mean(tdoas(:,2)),100);
%                 tdoas(:,3) =  smooth(tdoas(:,3) - mean(tdoas(:,3)),100);
%                 tdoas(:,4) =  smooth(tdoas(:,4) - mean(tdoas(:,4)),100);
                tdoas = downsample(tdoas,500);
%                 pIndices = downsample(pIndices,500);
%                 pTime = time(pIndices);
                
%                 plot the points over the raw signal
%                 subplot(3,3,1);
%                 hold on;
%                 scatter(pTime , zeros(size(pTime)), [], linspace(1,10,length(pTime)));
%                 
%                 subplot(3,3,4);
%                 hold on;
%                 scatter(pTime , zeros(size(pTime)), [], linspace(1,10,length(pTime)));
%                 
%                 subplot(3,3,[2 3]);
%                 hold on;
%                 scatter(pTime , zeros(size(pTime)), [], linspace(1,10,length(pTime)));
%                 
%                 % plot the tdoas
                subplot(3,3,7);
                plot(tdoas);
%                 hold on;
%                 scatter(pTime , zeros(size(pTime)), [], linspace(1,10,length(pTime)));
                
%                 subplot(rows,cols,rIdx);
                renderer = SurfaceRenderer(s);
                subplot(3,3,[5 6 8 9]);
                renderer.plot(h);
                points = localizer.resolve(tdoas);
%                 renderer.addPoints(initLoc);
                renderer.addPoints(points,false);
                title([num2str(rIdx, 'Swipe %d ') num2str(direction+1, 'Direction %d ') num2str(band, 'Band %d')]);
            end
            
%             saveas(h,[folderName '/' fName '.fig'],'fig');
%             close(h);
        end
        
    end
    
    
end