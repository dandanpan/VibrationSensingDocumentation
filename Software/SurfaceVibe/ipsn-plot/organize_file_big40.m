close all
clear all

init();
%% load calibration data
clear all;
directory = 'data/drive/20160920/wood40-8grid-effect3-un';
filename = 'wood40-cali00000.txt';
d = DataLoader(filename, directory);

windowSize = 5000;
% Build a noise model
data = d.getData();
nModel = NoiseModel(data(1:25000,:), windowSize);

t1 = data(1,1);
t2 = data(2,1);
Fs = 1/(t2-t1);

threshold = 45;
startMargin = 1000;
endMargin = 2000;
detector = TapDetector(nModel, threshold, startMargin, endMargin,0.1);
events = detector.sweep(data);

d.plot();
for idx = 1:length(events)
   e = events(idx);
   e.plot(1,gcf,true);
end

save('wood40-8grid-effect3-un-cali.mat','events','data','Fs');

%% tapping data
clear all;close all;
directory = 'data/drive/20160920/cement24-damp-tap';
for tapIdx = 0:3
    filename = ['cement24-tap'  num2str(tapIdx,'%05d') '.txt'];
    d = DataLoader(filename, directory);

    windowSize = 5000;
    % Build a noise model
    data{tapIdx+1} = d.getData();
    nModel = NoiseModel(data{tapIdx+1}(1:35000,:), windowSize);

    t1 = data{tapIdx+1}(1,1);
    t2 = data{tapIdx+1}(2,1);
    Fs = 1/(t2-t1);

    threshold  = 10;
    startMargin = 1000;
    endMargin = 2000;
        detector = TapDetector(nModel, threshold, startMargin, endMargin, 0.05);
    % minLength = 4 * windowSize;
    % detector = SwipeDetector(nModel, threshold, minLength);
    events{tapIdx+1} = detector.sweep(data{tapIdx+1});

    d.plot();
    for idx = 1:length(events{tapIdx+1})
       e = events{tapIdx+1}(idx);
       e.plot(1,gcf,true);
    end
    
end

events{2}(end-2:end) = [];
events{4}(1:2) = [];

save('cement24-damp-tap.mat','events','data','Fs');
%% swiping data
clear all;close all;
directory = 'data/drive/20160920/wood40-8grid-effect5';
for tapIdx = 0:8
    filename = ['wood40-swipe'  num2str(tapIdx,'%05d') '.txt'];
    d = DataLoader(filename, directory);

    windowSize = 7500;
    % Build a noise model
    data{tapIdx+1} = d.getData();
    nModel = NoiseModel(data{tapIdx+1}(1:35000,:), windowSize);

    t1 = data{tapIdx+1}(1,1);
    t2 = data{tapIdx+1}(2,1);
    Fs = 1/(t2-t1);
    
    threshold = 3;
    minLength = 6 * windowSize;
    detector = SwipeDetector(nModel, threshold, minLength);
    theEvents = detector.sweep(data{tapIdx+1});
    events{tapIdx+1} = theEvents;

    d.plot();
    for idx = 1:length(events{tapIdx+1})
       e = events{tapIdx+1}(idx);
       e.plot(1,gcf,true);
    end
end
save('wood40-8grid-effect5-swipe.mat','events','data','Fs');