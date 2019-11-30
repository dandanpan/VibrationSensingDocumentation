function [tdoa_pairs,selected_scales] = ShowoneScaleData_velocity(channels,data,Fs)
%% set all the varibales required for storing
tdoa_pairs={};
tdoa_pairs_3channel={};
channel_3numbers={};
scale_4c={};
scale_3c={};
% test the extraction of one event
colorstring = 'kbgry';
figure(4);
title('P1 center the vibration data of 8 sensors');
for i=1:channels
    plot(data(i,:),'Color',colorstring(i));
    hold on
end

%% get the wavelet results of the raw signals
    coef_all_sensors={};
    scale_length=1024;
    energy_scale=zeros(channels,scale_length); % the energy of every scale
    for i=1:channels
        isshow=1;
        [COEFS,maxscale,energy_scale(i,:)]= Getwavelet(data(i,:), isshow);
        coef_all_sensors{i}=COEFS;
    end
%% get the scales we want for velocity     
%     scale_min=50;
    scale_min=50;
    scale_max=200;
    select_thre=5;
    selected_scales=[scale_min:select_thre:scale_max];

%% get all the tdoa for calculating velocity for every scale
dt=1/Fs;
[~,data_length]=size(coef_all_sensors{1}.cfs);
reconstruct_signal=zeros(channels,data_length);
energy_reconstruct_signal=zeros(channels,1);
highest_peakvalue=zeros(channels,1);
scale_number=length(selected_scales)
tdoa_pairs=[];
scale_4c=[];
for i=1:scale_number
    one_scale=selected_scales(i);
%      one_scale=scale_min+i-1;
    scal2frq(one_scale,'morl',dt)
    
    % get all the reconstructed signals from one scale
    colorstring = 'rgbky';
%     figure;
    for j=1:channels
        % normalization before the wavelet filter and extract the mean
        reconstruct_signal(j,:)=waveletFiltering(coef_all_sensors{j},one_scale);
        reconstruct_signal(j,:)=reconstruct_signal(j,:)-mean(reconstruct_signal(j,:));
        highest_peakvalue(j)=max(reconstruct_signal(j,:));
        energy_reconstruct_signal(j)=norm(reconstruct_signal(j,:),2)^2;
%         plot(reconstruct_signal(j,:),'Color',colorstring(j));
%         hold on
    end
    
    % find first peaks for the signals of one scale
    [one_tdoa,useful_flag]=FindFirstPeak_velocity(channels,reconstruct_signal,energy_reconstruct_signal,highest_peakvalue);
    if (useful_flag==0) % if we find useful peaks we store the results in tdoa_pairs for this scale
        tdoa_pairs=[tdoa_pairs;dt*one_tdoa];
        scale_4c=[scale_4c,one_scale];
    else
        tdoa_pairs=[tdoa_pairs;-100]; %  if we didn't find useful peaks we set a default value for tdoa as -100
    end   
end


        
end

