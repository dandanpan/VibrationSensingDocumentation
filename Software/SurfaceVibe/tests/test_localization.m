init();

% generate a surface
s = Surface([40 40]);
s.addSensor(0,0);
s.addSensor(1,0);
s.addSensor(0,1);
s.addSensor(1,1);

d = DataLoader('table40tap100000.txt', 'data/20160818/taps'); % A1

% Build a noise model
windowSize = 2500;
data = d.getData();
nModel = NoiseModel(data(1:80000,:), windowSize);

threshold = 5;
detector = EventDetector(nModel, threshold);
events = detector.sweep(data);

t1 = data(1,1);
t2 = data(2,1);
Fs = 1/(t2-t1);

wFilter = WaveletFilter(windowSize);
bFilter = BandPassFilter(Fs, 20, 60, 2);

tdoaCalc = XcorrTdoaCalculator();
tdoas = [];

% figure;
% plot all detected events
for idx = 1:length(events)
   e = events(idx);
   e.filter(bFilter);
   tdoas = [tdoas; tdoaCalc.calculate(e.getTime(), e.getSignals())];
end

localizer = Localizer(s, 40/0.004);
localizer.resolve(tdoas)