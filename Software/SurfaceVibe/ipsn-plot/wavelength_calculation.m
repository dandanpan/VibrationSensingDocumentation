clear all
close all
clc

filename{1} = 'data/drive/dataset/wood16-swipe.mat';
load(filename{1});
e = events{1}(1);
figure;
for sIdx = 1:4
    subplot(4,1,sIdx);
    Fs = 1/(e.data(2,1)-e.data(1,1));
    [f,Y] = signalFrequencyExtraction(e.data(25000:50000,sIdx+1), Fs);
    plot(f,Y);
end