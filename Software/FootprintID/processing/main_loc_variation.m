clear all
close all
clc

Fs = 1000;
WIN1 = 100;
WIN2 = 300;
numSpeed = 8;
numPeople = 5;
numSensor = 5;
speedID = 1;
medianFrequencySet = zeros(numSpeed,numPeople);
stepFrequencySet = zeros(numSpeed,numPeople);
%% select sensor 1 P1
load('../dataset/P1.mat');
personID = 1;
humantest_loc;

load('../dataset/P2.mat');
personID = 2;
humantest_loc;

load('../dataset/P3.mat');
personID = 3;
humantest_loc;

load('../dataset/P4.mat');
personID = 4;
humantest_loc;

load('../dataset/P5.mat');
personID = 5;
humantest_loc;



