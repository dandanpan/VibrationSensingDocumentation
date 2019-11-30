close all;
clear all;

channels=4;
load('./../PorterLab_032019/PorterLab_20190320_3p_cross_rep1.mat');
% load('./../PorterLab_032019/PorterLab_20190320_uncontrol_sidebyside_2p2p.mat');
% t=data(1,:); % time 
data=data';


%% use the first data as noise data
% extract the mean of the data before wavelet filter
for i=1:channels
    data(i,:)=data(i,:)-mean(data(i,:));
end

% % for 10 min uncontrol data:
% time_one_data=25600*60;
% i=9;
% data=data(:,(i-1)*time_one_data+1:i*time_one_data);

%% set the noise data and nomrlize the amplitude of every sensor
noise_data=data(:,1:10000);
amplitude_sensors=sum(abs(noise_data),2)/min(sum(abs(noise_data),2));
for i=1:channels
    data(i,:)=data(i,:)/amplitude_sensors(i);
    noise_data(i,:)=noise_data(i,:)/amplitude_sensors(i);
end

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
for num_step=6:12
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
            sqrt(sum(data.^2)), sqrt(sum(noise_data.^2)),1024*2.5,16);



%% &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& using index, not real time for x label
figure;
colorstring = 'rgbky';
mag=2;
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



 %% the 2p_cross_1.mat

% step_detect=[30000,38000;37000,43000;47000,54000;53000,60000;62000,70000;69000,78000;78000,84000;87000,92000;...
%     92000,96000;96500,100000;100000,107000;106500,115000;117000,122500;122500,129000;133000,141000];

%% the 2p_cross_2.mat
% step_detect=[86000,94000;96000,104000;106000,112000;111000,118700;121000,126000;125500,135000;137000,141000;...
%     140300,145000;148000,153000;153200,160000;164000,174000;180000,188000];
% 
% % the 2p_cross_3.mat
% step_detect=[66000,76000;76000,84000;84000,92000;92000,100000;100000,108000;107000,114000;116000,122000;...
%     121000,128000;130000,136000;135000,142000;145000,151000;150000,160000;162000,165500;165000,169000];


%% the 2p_cross_4.mat
% step_detect=[52000,60000;62000,68000;69000,75000;79500,83500;84000,89000;95000,98000;...
%     97500,104000;109000,115000;123000,130000;135000,145000;154000,160000];
%% the 2p_cross_5.mat
% step_detect=[35000,38500;38500,41500;51500,53250;53250,57000;66000,67250;65000,70000;78000,81500;81700,88000;90000,96000;96000,102000;104000,111000;111000,118000;120000,125000;125000,132000];
% data_test=data(:,step_detect(num_step,1):step_detect(num_step,2));

%% the 2p_side_2.mat
% num_step
% step_detect=[53000,55500];

%% the 2p_side_5.mat
% num_step
% step_detect=[42000,48000;48000,56000;58000,65000;65000,73000;74000,81000;81000,88000;90000,100000;106000,114000;122000,128000;136000,144000];

%% the 2p_side_1.mat
num_step
% step_detect=[88000,96000;102000,109000;109000,114000;120000,125000;134000,140000;148000,156000;164000,172000;178000,188000];

%% the 2p_side_2.mat
% step_detect=[50000,60000;68000,76000;84000,92000;100000,110000;116000,124000;130000,140000;146000,154000]

%% the 2p_side_3.mat
% step_detect=[30000,40000;48000,56000;64000,70000;78000,84000;92000,100000;108000,113000;122000,130000];

%% the 2p_side_4.mat
% step_detect=[52000,60000;69000,78000;85000,88000;88000,93000;100000,108000;118000,123000;132000,140000;150000,157000]

%% the ballon PorterLab_2019_0221_ballon_Rep7.mat
% step_detect=[202000,210000;230000,235000;236000,243000;245000,253000;265000,271000;272000,276000;280000,287000;...
%     287000,295000;296000,305000;305000,312000;315000,322000;323000,329000;332000,338000;340000,345000];
% data_test=data(:,step_detect(num_step,1):step_detect(num_step,2));

data_test=data(:,stepStartIdxArray(num_step)-6000:stepStopIdxArray(num_step)+4000);
[step_number,tdoa_pairs_all,tdoa_pairs_3channel_all,channel_3numbers_all,scale_4c_all,scale_3c_all]=ShowoneScaleData(channels,data_test,Fs, noise_data);


% % get the TDOA between geophone 1 and geophone 2-4 using the signal after highpass filter and fixed velocity
% % using cross correlation to get possible TDOA
% scale_min=65;
% scale_max=256;
% [tdoa_pairs]=GetTDOAfromCOEFS(coef_all_sensors,channels, scale_min, scale_max,Fs);
% 
% % using peaks to get TDOA
% for geoi=2:channels
%     tdoa_pairs(:,geoi)=dt*(tdoa_pairs(:,geoi)+step_begin(geoi)-step_begin(1));
% end

tdoa_pairs


%% get the localization according to the TDOA
%##########################################################################
for tdoai=1:step_number
    tdoa_pairs=tdoa_pairs_all{tdoai};
    tdoa_pairs_3channel=tdoa_pairs_3channel_all{tdoai};
    channel_3numbers=channel_3numbers_all{tdoai};
    scale_4c=scale_4c_all{tdoai};
    scale_3c=scale_3c_all{tdoai};
%% parameter setting
% geophones positions and persons positions
geophone_number=4;
geophone_position=[3.37,0.2,3.37,0.2;3.05,2.03,1.02,0];

velocity=linspace(200,600,100);
%% use four geophones
% The EDM of localized geophones
if (~isempty(tdoa_pairs))
D_geophone=zeros(geophone_number);
for i=1:geophone_number
    for j=1:geophone_number
        D_geophone(i,j)=norm(geophone_position(:,i)-geophone_position(:,j),2);
    end
end


num_matching=length(tdoa_pairs);
matchedposition=zeros(2,num_matching);
all_score=zeros(num_matching,1);

[matchedposition,all_score]=Echo_sorting_velocity_scale(geophone_position,D_geophone,tdoa_pairs,velocity);

% show the several good matching and remove bad ones
wrong_place=[];
for positioni=1:length(all_score)
    if(abs(matchedposition(1,positioni))>5 || abs(matchedposition(2,positioni))>5)
        wrong_place=[wrong_place,positioni];
    end
end
all_score(wrong_place)=[];
matchedposition(:,wrong_place)=[];
tdoa_pairs(wrong_place,:)=[];
scale_4c(wrong_place)=[];
% plot the localization results
figure;
plot(geophone_position(1,:),geophone_position(2,:),'r*');
hold on
t=sort(all_score);
if (length(t)>=4)
    [~,pos]=find(all_score<=t(4),4)
    plot(matchedposition(1,pos),matchedposition(2,pos),'go');
    hold on
end
plot(matchedposition(1,:),matchedposition(2,:),'bo');
else
    all_score=[];
    matchedposition=[];
    tdoa_pairs=[];
    scale_4c=[];
end

% %% save the result of 4 channels
filename='./result_3p_cross/uncontrol/10_min/person1_trail1.mat';
load(filename);
if (~exist('all_score_4c'))
    all_score_4c={all_score};
    matchedposition_4c={matchedposition};
    tdoa_4c={tdoa_pairs};
    all_scale_4c={scale_4c};
else
    all_score_4c{length(all_score_4c)+1}=all_score;
    matchedposition_4c{length(matchedposition_4c)+1}=matchedposition;
    tdoa_4c{length(tdoa_4c)+1}=tdoa_pairs;
    all_scale_4c{length(all_scale_4c)+1}=scale_4c;
end
%% use three geophone positions
if (~isempty(tdoa_pairs_3channel))
    tdoa_pairs=tdoa_pairs_3channel;
    num_matching=length(tdoa_pairs);
    matchedposition=zeros(2,num_matching);
    all_score=zeros(num_matching,1);
for ti=1:size(tdoa_pairs,1)
geophone=channel_3numbers(ti,:);
geophone_number=3;
geophone_position_3c=[geophone_position(:,geophone(1)),geophone_position(:,geophone(2)),geophone_position(:,geophone(3))];
% The EDM of localized geophones
D_geophone=zeros(geophone_number);
for i=1:geophone_number
    for j=1:geophone_number
        D_geophone(i,j)=norm(geophone_position_3c(:,i)-geophone_position_3c(:,j),2);
    end
end

[matchedposition(:,ti),all_score(ti)]=Echo_sorting_velocity_scale(geophone_position_3c,D_geophone,tdoa_pairs(ti,:),velocity);
end
% show the several good matching
wrong_place=[];
for positioni=1:length(all_score)
    if(abs(matchedposition(1,positioni))>5 || abs(matchedposition(2,positioni))>5)
        wrong_place=[wrong_place,positioni];
    end
end

all_score(wrong_place)=[];
matchedposition(:,wrong_place)=[];
tdoa_pairs(wrong_place,:)=[];
scale_3c(wrong_place)=[];
% plot the localization results
figure;
plot(geophone_position(1,:),geophone_position(2,:),'r*');
hold on
t=sort(all_score);
if (length(t)>=4)
    [~,pos]=find(all_score<=t(4),4);
    plot(matchedposition(1,pos),matchedposition(2,pos),'go');
    hold on
end
plot(matchedposition(1,:),matchedposition(2,:),'bo');
else
    all_score=[];
    matchedposition=[];
    tdoa_pairs=[];
    scale_3c=[];
end
% plot(matchedposition(1,:),matchedposition(2,:),'bo');

%% save the results of the 3 channels
if (~exist('all_score_3c'))
    all_score_3c={all_score};
    matchedposition_3c={matchedposition};
    tdoa_3c={tdoa_pairs};
    all_scale_3c={scale_3c};
else
    all_score_3c{length(all_score_3c)+1}=all_score;
    matchedposition_3c{length(matchedposition_3c)+1}=matchedposition;
    tdoa_3c{length(tdoa_3c)+1}=tdoa_pairs;
    all_scale_3c{length(all_scale_3c)+1}=scale_3c;
end
step_position=[];
true_step_position=[];
% save(filename,'true_step_position','step_position',...
%     'tdoa_4c','all_score_4c','matchedposition_4c','all_scale_4c',...
%     'tdoa_3c','all_score_3c','matchedposition_3c','all_scale_3c');

end
close all;
end