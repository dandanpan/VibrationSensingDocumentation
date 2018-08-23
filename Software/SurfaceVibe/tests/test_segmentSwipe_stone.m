close all

init();

directory = 'data/sb';
filename = 'sb-test00000.txt';
d = DataLoader(filename, directory);

windowSize = 10000;
% Build a noise model
data = d.getData();
nModel = NoiseModel(data(1:80000,:), windowSize);

t1 = data(1,1);
t2 = data(2,1);
Fs = 1/(t2-t1);

threshold = 3;
minLength = 4 * windowSize;
detector = SwipeDetector(nModel, threshold, minLength);
events = detector.sweep(data);

d.plot();
for idx = 1:length(events)
   e = events(idx);
   e.plot(1,gcf,true);
end

save('sb-test.mat','events','d','Fs');return;

% load('stone-test.mat');
selectedFrq = 312;
bFilter = GainVaryingFilter(Fs);
% bFilter.addBand(75,90,2,1);
bFilter.addBand(selectedFrq-1,selectedFrq+1,2,1);
bFilter.addBand(2*selectedFrq-1,2*selectedFrq+1,3,0.75);

% Base frequency
f = 312;
P = 1/f;
Ps = floor(P*Fs);
wSize = 8*Ps;

for eIdx = 1:length(events)
    h = figure;
    subplot(4,4,[2 3 4]);
    e = events(eIdx);
    e.plot(0,h);
    axis tight;
%     data = e.getSignals();
%     figure(); spectrogram(data(:,1));
    e.filter(bFilter);
    sig = e.getSignals();
    
    g=figure; e.plot(0,g);

	time = e.getTime();
    timeIdxs = [];
    
    startIdxs = 1:(wSize):(length(sig)-1);
    startIdxs = startIdxs(1:end-2);

    n = length(startIdxs);
    
     tdoas = zeros(n,3);
     conf = zeros(n,3);
     energy = zeros(n,4);
     % signal ref
    sRef =sig(:,1);
    for idx = 1:n
        wStartIdx = startIdxs(idx);
        refWindow = sRef(wStartIdx:wStartIdx + wSize);
        refE = sum(refWindow.*refWindow);
        refS = SignalNormalization(refWindow);
        energy(idx,1) = refE;
        for sIdx = 2:size(sig,2)
            sWindow = sig(wStartIdx:wStartIdx + wSize,sIdx);
            sE = sum(sWindow.*sWindow);
            energy(idx,sIdx) = sE;
            s = SignalNormalization(sWindow);
%             [cor, lag] = xcorr(s,refS);
%             [c,I] = max(abs(cor));
%             lagDiff = lag(I);
            [ lagDiff, lagVal ] = TDoAMinShift( refS, s );
            tdoas(idx,sIdx-1) = lagDiff/Fs;
            conf(idx,sIdx-1) = lagVal;
        end

        if sum(energy(idx,:)) < 0.0005 || min(conf(idx,:)) < 0.3
            tdoas(idx,:) = [NaN NaN NaN];
        else
            timeIdxs = [timeIdxs wStartIdx];
        end

    end

    % moving average filter
    t = downsample(tdoas,2);
    figure(h);
    timePoints = time(timeIdxs) - time(1);
    subplot(4,4,1);
    e.plot(0,h);
    subplot(4,4,[2 3 4]);
%     figure(g);
    hold on;
    scatter(timePoints , zeros(size(timePoints)), [], linspace(1,10,length(timePoints)));
    axis tight;
    figure(h);
    subplot(4,4,5);
    plot([0 length(t)], [0 0]);
    axis tight;
    hold on;
    plot(t);
    axis tight;
    subplot(4,4,9);
    plot(conf);
    axis tight;
    subplot(4,4,13);
    plot(energy);
    axis tight;

    s = Surface([40 40]);
    s.addSensor(0,0);
    s.addSensor(1,0);
    s.addSensor(0,1);
    s.addSensor(1,1);
    velocity = 15000;
    localizer = Localizer(s, [1,1,1,1].*velocity);

    stdoas = zeros(size(t,1), 4);
    span=10;
%     stdoas(:,2) = smooth(t(:,1),0.2,'rloess');
%     stdoas(:,3) = smooth(t(:,2),0.2,'rloess');
%     stdoas(:,4) = smooth(t(:,3),0.2,'rloess');
    stdoas(:,2) = t(:,1);
    stdoas(:,3) = t(:,2);
    stdoas(:,4) = t(:,3);
    points = localizer.resolve(stdoas);

    renderer = SurfaceRenderer(s);
    pIdxs = 1:16;
    pIdxs([1 2 3 4 5 9 13]) = [];
    subplot(4,4,pIdxs);
    renderer.plot(gcf);
    renderer.addPoints(points,false);
    title(['event id: ' num2str(eIdx)]);
    length(points)
end

