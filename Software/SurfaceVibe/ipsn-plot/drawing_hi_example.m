%% swiping data
directory = 'data/swipe-hi';
for tapIdx = 0:4
    filename = ['wood40-swipe-hi'  num2str(tapIdx,'%05d') '.txt'];
    d = DataLoader(filename, directory);

    windowSize = 10000;
    % Build a noise model
    data{tapIdx+1} = d.getData();
%     if tapIdx == 2
        nModel = NoiseModel(data{tapIdx+1}(1:37500,:), windowSize);
%     else 
%         nModel = NoiseModel(data{tapIdx+1}(1:80000,:), windowSize);
%     end

    t1 = data{tapIdx+1}(1,1);
    t2 = data{tapIdx+1}(2,1);
    Fs = 1/(t2-t1);

    threshold = 6;
    minLength = 1 * windowSize;
    detector = SwipeDetector(nModel, threshold, minLength);
    events{tapIdx+1} = detector.sweep(data{tapIdx+1});

    d.plot();
    for idx = 1:length(events{tapIdx+1})
       e = events{tapIdx+1}(idx);
       e.plot(1,gcf,true);
    end
end
save('swipe-hi.mat','events','data','Fs');


%% localize the fifth h

wSize = 500;
h = figure;
subplot(4,4,[2 3 4]);
e = events{5}(1);
e.plot(0,h);
axis tight;
sig = e.getSignals();

time = e.getTime();
timeIdxs = [];
startIdxs = 1:(wSize):(length(sig)-1);
startIdxs = startIdxs(1:end-2);

n = length(startIdxs);

tdoas = zeros(n,3);
conf = zeros(n,3);
energy = zeros(n,4);
energyProfile = zeros(n,1);
 % signal ref
sRef =sig(:,1);
% get the energy information
for idx = 1:n
    wStartIdx = startIdxs(idx);
    windowE = zeros(1,4);
    for sIdx = 1:size(sig,2)
        sWindow = sig(wStartIdx:wStartIdx + wSize,sIdx);
        sE = sqrt(sum(sWindow.*sWindow));
        windowE(sIdx) = sE;
    end
    energyProfile(idx) = sum(windowE);
end

% get the 
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
        [ lagDiff, lagVal ] = TDoAMinShift( refS, s);
        tdoas(idx,sIdx-1) = lagDiff/Fs;
        conf(idx,sIdx-1) = lagVal;
    end

    if sum(energy(idx,:)) < prctile(energyProfile,0.25) || min(conf(idx,:)) < 0.25
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
velocity = 24000;
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
points(points(:,1)>20,:) = [];
renderer = SurfaceRenderer(s);
pIdxs = 1:16;
pIdxs([1 2 3 4 5 9 13]) = [];
subplot(4,4,pIdxs);
renderer.plot(gcf);
renderer.addPoints(points,false);
finalPoints{1} = points;

%% i
wSize = 500;
h = figure;
subplot(4,4,[2 3 4]);
e = events{1}(2);
e.plot(0,h);
axis tight;
sig = e.getSignals();

time = e.getTime();
timeIdxs = [];
startIdxs = 1:(wSize):(length(sig)-1);
startIdxs = startIdxs(1:end-2);

n = length(startIdxs);

tdoas = zeros(n,3);
conf = zeros(n,3);
energy = zeros(n,4);
energyProfile = zeros(n,1);
 % signal ref
sRef =sig(:,1);
% get the energy information
for idx = 1:n
    wStartIdx = startIdxs(idx);
    windowE = zeros(1,4);
    for sIdx = 1:size(sig,2)
        sWindow = sig(wStartIdx:wStartIdx + wSize,sIdx);
        sE = sqrt(sum(sWindow.*sWindow));
        windowE(sIdx) = sE;
    end
    energyProfile(idx) = sum(windowE);
end

% get the 
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
        [ lagDiff, lagVal ] = TDoAMinShift( refS, s);
        tdoas(idx,sIdx-1) = lagDiff/Fs;
        conf(idx,sIdx-1) = lagVal;
    end

    if sum(energy(idx,:)) < prctile(energyProfile,0.25) || min(conf(idx,:)) < 0.25
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
velocity = 24000;
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
points(points(:,1)>30,:) = [];
renderer = SurfaceRenderer(s);
pIdxs = 1:16;
pIdxs([1 2 3 4 5 9 13]) = [];
subplot(4,4,pIdxs);
renderer.plot(gcf);
renderer.addPoints(points,false);
finalPoints{2} = points;

%% point

tdoaCalc = FirstPeakTdoaCalculator();
bFilter = WaveletFilter();
bFilter.noiseMaxScale=14;
tdoas = [];
points = [];

e = events{4}(3);
e.filter(bFilter);
e.plot();
oneTdoa = e.getTdoa(tdoaCalc);
onePoint = localizer.resolve(oneTdoa);
finalPoints{3} = onePoint;

%%
renderer = SurfaceRenderer(s);
renderer.plot();
renderer.addPoints(finalPoints{1}, false);
renderer.addPoints(finalPoints{2}, false);
renderer.addPoints(finalPoints{3}, false);
xlim([0,40]);
ylim([0,40]);
axis equal;

% scatter(finalPoints{1}(:,1),finalPoints{1}(:,2));hold on;
% scatter(finalPoints{2}(:,1),finalPoints{2}(:,2));hold off;
% xlim([0,40]);
% ylim([0,40]);
% axis equal;
