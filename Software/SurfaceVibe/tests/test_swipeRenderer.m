init();
tic;
s = Surface([40 40]);
s.addSensor(0,0);
s.addSensor(1,0);
s.addSensor(0,1);
s.addSensor(1,1);

velocity = 10000;
localizer = PairLocalizer(s, [1,1,1,1,1,1].*velocity);
tdoaCalc = XcorrTdoaCalculator();
windowSize = 5000;
wCalc = WindowedTdoaCalculator(tdoaCalc, windowSize);

for direction = 2%1:8
    directory = ['data/20160314/o' num2str(direction)];
    figure();
    figIdx = 1;
    for filenumber = 0:1
        filename = ['l3o' num2str(direction) num2str(filenumber, '%05d') '.txt'];
% for direction = 1
%     directory = ['data/drive/20160903/iron'];
%     figure();
%     figIdx = 1;
%     for filenumber = 0:0
%         filename = num2str(direction,'iron-test%05d.txt');
%         filename = ['l3o' num2str(direction) num2str(filenumber, '%05d') '.txt'];
        d = DataLoader(filename, directory);
        d.plot();
        % Build a noise model
        data = d.getData();
        nModel = NoiseModel(data(1:40000,:), windowSize);

        t1 = data(1,1);
        t2 = data(2,1);
        Fs = 1/(t2-t1);

        bFilter = BandPassFilter(Fs, 20, 55, 2);

        threshold = 10;
        minLength = 5 * windowSize;
        detector = SwipeDetector(nModel, threshold, minLength);
        events = detector.sweep(data);

        d.plot();
        h = gcf;
        for idx = 1:2%length(events)
           e = events(idx);
%            e.plot(1,h,true);
           e.filter(bFilter);
           tdoas = e.getTdoa(wCalc);
           points = localizer.resolve(tdoas);
%            renderer.addPoints(points,true);
           v = figure();
           renderer = SurfaceRenderer(s);
           renderer.plot(v);
           renderer.addPoints(points,true);
           title(['Direction ' num2str(direction) ' - ' num2str(figIdx)]);
           figIdx = figIdx+1;
        end
    end
end

toc;