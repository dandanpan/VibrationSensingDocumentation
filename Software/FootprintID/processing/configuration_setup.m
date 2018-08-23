% sampling frequency
Fs = 1000;

% window setting
WIN1 = 100;
WIN2 = 300;

% dataset statistics
numSpeed = 8;
numPeople = 10;
sensorID = 7;
cutoffFrequency = 200;
clusterSelectNum = 5;

% other container
medianFrequencySet = zeros(numSpeed,numPeople);
stepFrequencySet = zeros(numSpeed,numPeople);
speedSequence = [7,6,5,1,2,3,4,8];

% flags
plotEach = 0;
plotStep = 0;
plotTrace = 0;
performStepSelection = 1;
