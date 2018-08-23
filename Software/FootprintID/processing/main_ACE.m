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
sensorID = 4;
medianFrequencySet = zeros(numSpeed,numPeople);
stepFrequencySet = zeros(numSpeed,numPeople);
%% select sensor 1 P1
load('../dataset/P1.mat');
personID = 1;
Signals = P{personID}.Sen{sensorID}.S;
humantest_ACE;

load('../dataset/P2.mat');
personID = 2;
Signals = P{personID}.Sen{sensorID}.S;
humantest_ACE;

load('../dataset/P3.mat');
personID = 3;
Signals = P{personID}.Sen{sensorID}.S;
humantest_ACE;

load('../dataset/P4.mat');
personID = 4;
Signals = P{personID}.Sen{sensorID}.S;
humantest_ACE;

load('../dataset/P5.mat');
personID = 5;
Signals = P{personID}.Sen{sensorID}.S;
humantest_ACE;



