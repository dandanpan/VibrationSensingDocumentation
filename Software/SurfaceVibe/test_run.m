init();

% Test Run
d = DataLoader('table20cali00000.txt', 'data/20160816');
d.plot();

e = Event('test', 'today', d.getData());
e.plot(gcf);

% Build a noise model
windowSize = 2500;
data = d.getData();
nModel = NoiseModel(data(1:80000,:), windowSize);

threshold = 10;
detector = EventDetector(nModel, threshold);
events = detector.sweep(data);

t1 = data(1,1);
t2 = data(2,1);
Fs = 1/(t2-t1);

wFilter = WaveletFilter(windowSize);
bFilter = BandPassFilter(Fs, 20, 60, 2);

xcorrTdoa = XcorrTdoaCalculator();
fpeakTdoa = FirstPeakTdoaCalculator();

xTdoas1 = [];
fTdoas1 = [];
xTdoas2 = [];
fTdoas2 = [];

figure;
% plot all detected events
for idx = 1:length(events)
   e = events(idx);
   xTdoas1 = [xTdoas1; xcorrTdoa.calculate(e.getTime(), e.getSignals())];
   fTdoas1 = [fTdoas1; fpeakTdoa.calculate(e.getTime(), e.getSignals())];
   e.filter(bFilter);
   xTdoas2 = [xTdoas2; xcorrTdoa.calculate(e.getTime(), e.getSignals())];
   fTdoas2 = [fTdoas2; fpeakTdoa.calculate(e.getTime(), e.getSignals())];
   e.plot(gcf);
end