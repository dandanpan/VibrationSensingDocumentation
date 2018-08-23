close all
clear all

init();
%% load calibration data
clear all;
directory = 'data/drive/20160920/wood40-6grid-undamped';
filename = 'wood40-cali00000.txt';
d = DataLoader(filename, directory);

windowSize = 5000;
% Build a noise model
data = d.getData();
nModel = NoiseModel(data(1:60000,:), windowSize);

t1 = data(1,1);
t2 = data(2,1);
Fs = 1/(t2-t1);

threshold = 90;
startMargin = 2000;
endMargin = 2000;
detector = TapDetector(nModel, threshold, startMargin, endMargin,0.1);
events = detector.sweep(data);

d.plot();
for idx = 1:length(events)
   e = events(idx);
   e.plot(1,gcf,true);
end

save('wood40-6grid-undamped-cali.mat','events','data','Fs');

%% tapping data
clear all;
directory = 'data/drive/20160920/wood40-6grid-undamped';
for tapIdx = 0:5
    filename = ['wood40-tap'  num2str(tapIdx,'%05d') '.txt'];
    d = DataLoader(filename, directory);

    windowSize = 3000;
    % Build a noise model
    data{tapIdx+1} = d.getData();
    nModel = NoiseModel(data{tapIdx+1}(1:35000,:), windowSize);
%     nModel = NoiseModel(data{tapIdx+1}(20000:40000,:), windowSize);

    t1 = data{tapIdx+1}(1,1);
    t2 = data{tapIdx+1}(2,1);
    Fs = 1/(t2-t1);

    threshold = 200;
%     threshold  = 90;
    startMargin = 2000;
    endMargin = 2000;
        detector = TapDetector(nModel, threshold, startMargin, endMargin, 1);
    % minLength = 4 * windowSize;
    % detector = SwipeDetector(nModel, threshold, minLength);
    events{tapIdx+1} = detector.sweep(data{tapIdx+1});

    d.plot();
    for idx = 1:length(events{tapIdx+1})
       e = events{tapIdx+1}(idx);
       e.plot(1,gcf,true);
    end
    
end

save('wood40-6grid-tap.mat','events','data','Fs');
% save('wood40-6grid-undamped-tap.mat','events','data','Fs');
%% swiping data
clear all;
directory = 'data/drive/20160920/wood40-4grid-damped';
for tapIdx = 0:7
    filename = ['wood40-swipe'  num2str(tapIdx,'%05d') '.txt'];
    d = DataLoader(filename, directory);

    windowSize = 7500;
    % Build a noise model
    data{tapIdx+1} = d.getData();
    nModel = NoiseModel(data{tapIdx+1}(1:60000,:), windowSize);

    t1 = data{tapIdx+1}(1,1);
    t2 = data{tapIdx+1}(2,1);
    Fs = 1/(t2-t1);
    
    threshold = 16;
    
    if tapIdx == 2
        threshold = 60; 
    elseif tapIdx == 3
        threshold = 3; 
    end
    
    minLength = 3 * windowSize;
    detector = SwipeDetector(nModel, threshold, minLength);
    theEvents = detector.sweep(data{tapIdx+1});
    
%     if tapIdx == 2
%         theEvents(4) = [];
%     end
    
    events{tapIdx+1} = theEvents;

    d.plot();
    for idx = 1:length(events{tapIdx+1})
       e = events{tapIdx+1}(idx);
       e.plot(1,gcf,true);
    end
end
save('wood40-4grid-damped-swipe.mat','events','data','Fs');
