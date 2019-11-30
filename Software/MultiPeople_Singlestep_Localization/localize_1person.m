% The sample frequency is 6500Hz
close all; clear all;
load('../P1.mat');
load('../P1_noise.mat');
% load('P1P2.mat');
% load('P1P2_noise.mat');
channel=4;
% preproccessing the data
num_expri=1;
noise_data=PreprocessFixinglength(noiseSig(1,:),channel);

% %% get the noise and vibration data with person
% % for noise
% figure(1);
% for i=1:channel
%     subplot(channel,1,i);
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
mag=600;
% for 1 person walking in center
% 
figure;
data=cell2mat(P1_center(num_expri,1));
plot(data(:,1)/1e6,data(:,2));
%set(gca,'YTick',-mag:mag:mag);
title('The vibration data of 1 sensors when P1 center');
xlabel('time /s');
ylabel('magnitude');



figure(1);
title('P1 center the vibration data of 8 sensors');
for i=1:channel
    subplot(channel,1,i);
    data=cell2mat(P1_center(num_expri,i));
    data(:,1)=(data(:,1)-data(1,1))/(1e6);
    plot(data(:,1),data(:,2));
    set(gca,'YTick',-mag:mag:mag);
    xlabel('time /ms');
ylabel('magnitude');
end


person_data=PreprocessFixinglength(P1_center(num_expri,:),channel);
t=person_data(:,1,1);
Fs=6500;
dt=1/Fs;

geophone_number=4;
geophone_position=[-1.5,-1.5,1.5,1.5;0.76,-0.76,0.76,-0.76];
figure(10);
plot(geophone_position(1,:),geophone_position(2,:),'r*');
hold on

%% get all the steps of this person
% get the signals after wavelet filters of the left four geophones then get
% the TDOA; Then do the peak matching for localization
num_step=7; % the step
for num_step=1:8
coef_all_sensors={};
reconstruct_signal={};
step_begin=zeros(4,1);
corr=zeros(4,1);
cell_distance={};
for geoi=1:4
select_channel=geoi;
rawsignal_data=person_data(:,2,select_channel);
%% detect footstep and show 

[ stepEventsSig, stepEventsIdx, stepEventsVal, ...
            stepStartIdxArray, stepStopIdxArray, ... 
            windowEnergyArray, noiseMu, noiseSigma, noiseRange ]=SEDetection(rawsignal_data, noise_data(:,1,select_channel));


onechannel_data=person_data(:,:,select_channel);

% draw the detected steps in rectangle
% figure;
% plot(onechannel_data(:,1),rawsignal_data);
% plot(rawsignal_data);
% hold on
% for i=1:length(stepEventsIdx)
%         rectangle('Position',[onechannel_data(stepStartIdxArray(i),1),-mag,...
%             onechannel_data(stepStopIdxArray(i),1)-onechannel_data(stepStartIdxArray(i),1),2*mag],'EdgeColor','r');
% end
% title('The detected person');
% xlabel('time /ms');
% ylabel('magnitude');
%% &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& using index, not real time for x label
% figure;
% plot(rawsignal_data);
% hold on
% for i=1:length(stepEventsIdx)
%         rectangle('Position',[stepStartIdxArray(i),-mag,...
%             stepStopIdxArray(i)-stepStartIdxArray(i),2*mag],'EdgeColor','r');
% end
% title('The detected person');
% xlabel('time /ms');
% ylabel('magnitude');

% using high pass filter for all signals
cutlow=90;
reconstruct_signal{geoi}=signalFilter(stepEventsSig(num_step,:), Fs, cutlow, cutlow+150);
figure;
plot(reconstruct_signal{geoi});


%% show the wavelet of one channel's selected step
step_begin(geoi)=stepStartIdxArray(num_step);
isshow=0;
[COEFS,maxscale]= Getwavelet(stepEventsSig(num_step,:), isshow);
coef_all_sensors{geoi}=COEFS;
% selected_scale=60;
% reconstruct_signal{geoi}=waveletFiltering(COEFS, selected_scale);
% figure;
% plot(reconstruct_signal{geoi});
end


%% get the TDOA between geophone 1 and geophone 2-4 using the signal after highpass filter and fixed velocity
velocity=185;
% using cross correlation to get possible TDOA
for geoi=1:4
    [value,shift]=xcorr(reconstruct_signal{1},reconstruct_signal{geoi});
    figure;
    plot(shift,value);
    % find possible peaks
    peaks_threhold=0.7;
    [ firstPeakIdx, firstPeakVal ]=SelectPossiblePeaks(value,peaks_threhold);
    shift(firstPeakIdx)
    firstPeakIdx=-shift(firstPeakIdx)+step_begin(geoi);
    firstPeakIdx

    if (geoi==1)
        cell_distance{geoi}=step_begin(geoi);
    else
        cell_distance{geoi}=firstPeakIdx;
    end
end

% using peaks to get TDOA
for geoi=2:4
    cell_distance{geoi}=velocity*dt*(cell_distance{geoi}(:)-cell_distance{1}(1));
end
cell_distance{1}=velocity*dt*(cell_distance{1}(:)-cell_distance{1}(1));
corr
%% get the localization according to the TDOA
%##########################################################################
%% parameter setting
% geophones positions and persons positions
geophone_number=4;
geophone_position=[-1.5,-1.5,1.5,1.5;0.76,-0.76,0.76,-0.76];

% The EDM of localized geophones
D_geophone=zeros(geophone_number);
for i=1:geophone_number
    for j=1:geophone_number
        D_geophone(i,j)=norm(geophone_position(:,i)-geophone_position(:,j),2)
    end
end

% test all the peaks matching and choose the best one
% function of Echo sorting
num_matching=length(cell_distance{1})*8;
matchedposition=zeros(2,num_matching);
sort_peaks=zeros(geophone_number,num_matching);
all_score=zeros(num_matching,1);
already_matching=[];
for i=1:length(cell_distance{1})
    for j=1:8
        sort_peaks(1,(i-1)*2+j)=i;
        peak_for_match=i;
        d1=cell_distance{1}(i);
        [matchedposition(:,(i-1)*2+j),sort_peaks(:,(i-1)*2+j),all_score((i-1)*2+j)]...
            =Echo_sorting_localize(geophone_position,D_geophone,d1,cell_distance,already_matching,peak_for_match);
        already_matching=[already_matching,sort_peaks(:,(i-1)*2+j)];
    end
end



% show the several good matching 
t=sort(all_score);
[pos, ~]=find(all_score<=t(2),2)
plot(matchedposition(1,pos),matchedposition(2,pos),'o');
end
% plot(matchedposition(1,:),matchedposition(2,:),'bo');