clear all
close all
clc

load('../steps_10p_8s.mat');

selectedIdx = find(speedIDLabel == 8);
selectedSpeed = stepInfoAll(selectedIdx, 5);

%%
60/min(selectedSpeed)
60/max(selectedSpeed)
m = mean(60./selectedSpeed)
s = std(60./selectedSpeed)
% 60/(m-2*s)
% 60/(m+2*s)
m-2*s
m+2*s
