clear all
close all
clc

Fs = 1000;
WIN1 = 100;
WIN2 = 300;
numSpeed = 8;
numPeople = 10;
sensorID = 7;
numTraceEach = 10;
medianFrequencySet = zeros(numSpeed,numPeople);
stepFrequencySet = zeros(numSpeed,numPeople);
stepFrequencyStd = zeros(numSpeed,numPeople);
stepFrequencyEach = zeros(numSpeed,numPeople,numTraceEach);
TorF = 0;
%% select sensor 5 P1
load('./dataset/P1.mat');
personID = 1;
Signals = P{personID}.Sen{sensorID}.S;
humantest_speed;

%% select sensor 5 P2
load('./dataset/P2.mat');
personID = 2;
Signals = P{personID}.Sen{sensorID}.S;
humantest_speed;

%% select sensor 5 P3
load('./dataset/P3.mat');
personID = 3;
Signals = P{personID}.Sen{sensorID}.S;
humantest_speed;

%% select sensor 5 P4
load('./dataset/P4.mat');
personID = 4;
Signals = P{personID}.Sen{sensorID}.S;
humantest_speed;

%% select sensor 5 P5
load('./dataset/P5.mat');
personID = 5;
Signals = P{personID}.Sen{sensorID}.S;
humantest_speed;

%% select sensor 5 P5
load('./dataset/P6.mat');
personID = 6;
Signals = P{personID}.Sen{sensorID}.S;
humantest_speed;

%% select sensor 5 P5
load('./dataset/P7.mat');
personID = 7;
Signals = P{personID}.Sen{sensorID}.S;
humantest_speed;

%% select sensor 5 P5
load('./dataset/P8.mat');
personID = 8;
Signals = P{personID}.Sen{sensorID}.S;
humantest_speed;

%% select sensor 5 P5
load('./dataset/P9.mat');
personID = 9;
Signals = P{personID}.Sen{sensorID}.S;
humantest_speed;

%% select sensor 5 P5
load('./dataset/P10.mat');
personID = 10;
Signals = P{personID}.Sen{sensorID}.S;
humantest_speed;

figure;plot(medianFrequencySet(1:7,:));

walkingSpeed = mean(stepFrequencySet,2);
figure;plot(walkingSpeed(1:7));hold on;
plot([1,7],[walkingSpeed(8), walkingSpeed(8)],'r');hold off;


%%
% temp = [];
% for i = 1 : 8
%    temp = [temp; mean(stepFrequencyEach(i,6,stepFrequencyEach(i,6,:) ~=0)),...
%        std(stepFrequencyEach(i,6,stepFrequencyEach(i,6,:) ~=0))]; 
% end
% plot(temp);

%% averaging through traces
stepFrequencyAve = zeros(numSpeed,numPeople);
stepFrequencyStd = zeros(numSpeed,numPeople);
for iS = 1 : numSpeed
    for iP = 1 : numPeople
        stepFrequencyAve(iS, iP) = mean(stepFrequencyEach(iS,iP,stepFrequencyEach(iS,iP,:) ~=0));
        stepFrequencyStd(iS, iP) = std(stepFrequencyEach(iS,iP,stepFrequencyEach(iS,iP,:) ~=0));
    end
end
stepFrequencyAve

stepFrequencyMinute = 60./stepFrequencyAve;

figure;
subplot(2,1,1);
boxplot(stepFrequencyMinute');

set(gca,'xtick',1:8,'XtickLabel',{'-3\sigma', '-2\sigma', '-\sigma', '\mu','\sigma','2\sigma', '3\sigma','s'});
xlabel('Speed');
ylabel('Step Interval (s/step)');
subplot(2,1,2);
indi = stepFrequencyMinute(8,:);
levels = mean(stepFrequencyMinute(1:7,:),2)';
bar(indi);hold on;
for i = 1 : 7
    plot([0,11],[levels(i),levels(i)]);
end
hold off;
xlabel('Person ID');
ylabel('Step Interval (s/step)');

%%
figure;
subplot(2,1,1);
boxplot(stepFrequencyMinute(1:7,:)');

set(gca,'xtick',1:8,'XtickLabel',{'-3\sigma', '-2\sigma', '-\sigma', '\mu','\sigma','2\sigma', '3\sigma','s'});
xlabel('Speed');
ylabel('Step Interval (s/step)');

subplot(2,1,2);
bar(indi);
xlabel('Person ID');
ylabel('Step Interval (s/step)');
