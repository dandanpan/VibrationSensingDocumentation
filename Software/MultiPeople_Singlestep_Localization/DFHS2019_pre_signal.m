close all; clear all;
load('./../PorterLab_011719/PorterLab_011719_noise.mat');
noise_data=data(2:5,:);
noise_data(2,:)=-noise_data(2,:);
noise_data=noise_data(:,1:30000);
channels=4;
% normalize the noise data for detecting steps
for i=1:channels
    noise_data(i,:)=noise_data(i,:)-mean(noise_data(i,:));
end


% load('./../PorterLab_011719/PorterLab_011719_2p_cross_1.mat'); 
load('./../PorterLab_011719/PorterLab_011719_2p_side_4.mat'); 
% load('./../PorterLab_020919/PorterLab_20190210_follow_3step_rep5.mat');
% load('./../PorterLab_011719/PorterLab_011719_sj_l_1.mat');
% load('./../PorterLab_032019/PorterLab_20190320_3p_cross_rep1.mat');
% for three person
% data=data';
% for one person
t=data(1,:); % time 
data=data(2:5,:);
data(2,:)=-data(2,:);

for i=1:channels
    data(i,:)=data(i,:)-mean(data(i,:));
end

%% set the noise data and nomrlize the amplitude of every sensor
noise_data=data(:,1:10000);
amplitude_sensors=sum(abs(noise_data),2)/min(sum(abs(noise_data),2));
for i=1:channels
    data(i,:)=data(i,:)/amplitude_sensors(i);
    noise_data(i,:)=noise_data(i,:)/amplitude_sensors(i);
end

num_expri=1;

mag=2.5;
figure(1);
plot(data(1,:));
title('P1 center the vibration data of 8 sensors');
for i=1:1
    pos1=ceil(3*25600);
    pos2=ceil(4*25600);
    plot(t,data(i,:),'color',[0.6350, 0.0780, 0.1840]);
    set(gca,'YTick',-mag:mag:mag);
    xlabel('time /s');
    xlim([4.2,5.2]);
ylabel('magnitude');
end
colorstring = 'rgbky';