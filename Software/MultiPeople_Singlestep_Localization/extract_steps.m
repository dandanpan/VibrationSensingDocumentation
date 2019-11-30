close all; clear all;

% get noise data and extract the mean
load('./../PorterLab_011719/PorterLab_011719_noise.mat');
noise_data=data(2:5,:);
noise_data(2,:)=-noise_data(2,:);

channels=4;
% normalize the noise data for detecting steps
for i=1:channels
    noise_data(i,:)=noise_data(i,:)-mean(noise_data(i,:));
end

% get the walking data and extract the mean
load('./../PorterLab_011719/PorterLab_011719_jon_l_4.mat');
t=data(1,:); % time 
data=data(2:5,:);
data(2,:)=-data(2,:);

% extract the mean of the data before wavelet filter
for i=1:channels
    data(i,:)=data(i,:)-mean(data(i,:));
end

% detect step
[ stepEventsSig, stepEventsIdx, stepEventsVal, ...
            stepStartIdxArray, stepStopIdxArray, ... 
            windowEnergyArray, noiseMu, noiseSigma, noiseRange ]=SEDetection(sqrt(sum(data.^2)), sqrt(sum(noise_data.^2)));

%% &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& using index, not real time for x label
% show the result of step detection
figure(1);
colorstring = 'rgbky';
mag=2.5;
for i=1:channels
    plot(data(i,:),'Color',colorstring(i));
    hold on
end
for i=1:length(stepEventsIdx)
        rectangle('Position',[stepStartIdxArray(i),-mag,...
            stepStopIdxArray(i)-stepStartIdxArray(i),2*mag],'EdgeColor','r');
end
title('The detected person');
xlabel('time /ms');
ylabel('magnitude');