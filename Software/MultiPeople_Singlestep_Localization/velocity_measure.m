%% ge the velocity of the porter hall
close all, clear all;
load('./../PorterLab_011719/PorterLab_011719_noise.mat');
noise_data=data(2:3,:);
noise_data(2,:)=-noise_data(2,:);


load('./../Velocity_Chara/V_2019_02_20_Loc5_rep1.mat');
distance=0.127; % the distance between the two sensors

%% find the peaks of useful frequency
% The sample frequency is 6500Hz

channels=2;
t=data(1,:); % time 
data=data(2:3,:);
% data(2,:)=-data(2,:);

% extract the mean of the data before wavelet filter
for i=1:channels
    data(i,:)=data(i,:)-mean(data(i,:));
end


% preproccessing the data
num_expri=1;
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
for num_step=6:8
coef_all_sensors={};
reconstruct_signal={};
step_begin=zeros(4,1);
corr=zeros(4,1);
cell_distance={};

% autolly detect the useful signal position
%% detect footstep and show 

% [ stepEventsSig, stepEventsIdx, stepEventsVal, ...
%             stepStartIdxArray, stepStopIdxArray, ... 
%             windowEnergyArray, noiseMu, noiseSigma, noiseRange ]=SEDetection(sqrt(sum(data.^2)), sqrt(sum(noise_data.^2)));



%% &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& using index, not real time for x label
% figure;
% colorstring = 'rgbky';
% mag=2.5;
% for i=1:channels
%     plot(data(i,:),'Color',colorstring(i));
%     hold on
% end
% for i=1:length(stepEventsIdx)
%         rectangle('Position',[stepStartIdxArray(i),-mag,...
%             stepStopIdxArray(i)-stepStartIdxArray(i),2*mag],'EdgeColor','r');
% end
% title('The detected person');
% xlabel('time /ms');
% ylabel('magnitude');

% data_test=data(:,stepStartIdxArray(num_step):stepStopIdxArray(num_step));



%% the loc1_velocity.mat
% step_detect=[70000,80000;98000,108000;130000,140000;160000,170000;190000,200000;195000,198000;220000,230000];

% %% the loc2_velocity.mat
% step_detect=[72000,80000;98000,108000;125000,135000;155000,165000;185000,193000;214000,220000;244000,248000];

% %% the loc2_velocity.mat
% step_detect=[42000,50000;72000,80000;100000,110000;128000,136000;160000,166000;188000,196000;215000,225000;246000,252000];

% %% the loc3_velocity.mat
%  step_detect=[22000,32000;55000,65000;85000,93000;115000,123000;140000,150000;170000,178000;200000,208000];


%% manually get the signal position which are used for calculating velocity
step_detect=[83000,90000;106000,114000;130000,140000;158000,165000;180000,190000;207000,216000;230000,240000];

data_test=data(:,step_detect(num_step,1):step_detect(num_step,2));
% calculate the velocity of different scales
[tdoa_pairs_all,selected_scale]=ShowoneScaleData_velocity(channels,data_test,Fs);


%% get the velocity results
scale_number=length(selected_scale);
velocity=ones(scale_number,1)*-1;
for i=1:length(tdoa_pairs_all)
    velocity(i)=distance/tdoa_pairs_all(i);
end

figure;
plot(velocity);

%% get the localization according to the TDOA
%##########################################################################
%% store the velocity results

% load('point5_velocity.mat');
% if (~exist('velocity_all'))
%     velocity_all=velocity;
% else
%     velocity_all=[velocity_all,velocity];
% end
% save('point5_velocity.mat','velocity_all');
% close all;

% %% calculate the final results
mu=mean(velocity_all,2)
sigma=var(velocity_all');
frequencies=zeros(scale_number,1);
for i=1:scale_number
    frequencies(i)=scal2frq(selected_scale(i),'morl',dt);
end
trust_region=11;
errorbar(frequencies(trust_region:-1:1),mu(trust_region:-1:1),sqrt(sigma(trust_region:-1:1)))
save('point5_velocity.mat','velocity_all','frequencies','mu','sigma','trust_region');
end