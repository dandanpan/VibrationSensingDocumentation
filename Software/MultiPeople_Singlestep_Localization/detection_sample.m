% The sample frequency is 6500Hz
close all; clear all;
load('./../PorterLab_011719/PorterLab_011719_noise.mat');
noise_data=data(2:5,:);
noise_data(2,:)=-noise_data(2,:);

channels=4;
% normalize the noise data for detecting steps
for i=1:channels
    noise_data(i,:)=noise_data(i,:)-mean(noise_data(i,:));
end


% load('./../PorterLab_011719/PorterLab_011719_2p_cross_1.mat'); 
% load('./../PorterLab_011719/PorterLab_011719_2p_side_4.mat'); 
load('./../PorterLab_020919/PorterLab_20190210_follow_5step_rep5.mat');
t=data(1,:); % time 
data=data(2:5,:);


%% use the first data as noise data
% extract the mean of the data before wavelet filter
for i=1:channels
    data(i,:)=data(i,:)-mean(data(i,:));
end
%% set the noise data
noise_data=data(:,30000:40000);
% preproccessing the data
num_expri=1;

% %% get the noise and vibration data with person
% % for noise
% figure(1);
% for i=1:channels
%     subplot(channels,1,i);
%     data=cell2mat(noiseSig(1,i));
%     data(:,1)=(data(:,1)-data(1,1))/(1e6);
%     if (isempty(data)~=1)
%         plot(data(:,1),data(:,2));
%     end
% end
% title('the vibration data of noise');
% xlabel('time /ms');
% ylabel('magnitude');
% 
% noise_data=data(:,2);

%% the 8 geophones data of one person walking
% the magnitude
mag=2.5;
% for 1 person walking in center

% for test
% figure;
% plot(noise_data(1,:));



figure(1);
title('P1 center the vibration data of 8 sensors');
for i=1:channels
    subplot(channels,1,i);
    plot(data(i,:));
    set(gca,'YTick',-mag:mag:mag);
    xlabel('time /index');
ylabel('magnitude');
end
colorstring = 'rgbky';
figure(2);
title('P1 center the vibration data of 8 sensors');
for i=1:channels
    plot(data(i,:),'Color',colorstring(i));
    hold on
end

Fs=25600;
dt=1/Fs;

% geophone_number=5;
% geophone_position=[0.508,1.524,2.54,3.556,4.572;1.9812,0.1524,1.9812,0.1524,1.9812];


%% get all the steps of this person
% get the signals after wavelet filters of the left four geophones then get
% the TDOA; Then do the peak matching for localization
 % the step
coef_all_sensors={};
reconstruct_signal={};
step_begin=zeros(4,1);
corr=zeros(4,1);
cell_distance={};

% detect the step
%% detect footstep and show 

[stepEventsIdx, stepEventsVal, ...
            stepStartIdxArray, stepStopIdxArray, ... 
            windowEnergyArray, noiseMu, noiseSigma, noiseRange ]=MultiPeople_SEDetection(...
            sqrt(sum(data.^2)), sqrt(sum(noise_data.^2)),1024*2.5,32);



%% &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& using index, not real time for x label
figure;
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
