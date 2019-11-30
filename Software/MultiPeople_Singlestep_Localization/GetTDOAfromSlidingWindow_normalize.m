% select the frequencies between 10-100 Hz from the scales to do cross
% correlation for TDOA and record the possibility of real

function [tdoa_pairs,tdoa_pairs_3channel,channel_3numbers,scale_4c,scale_3c] =...
    GetTDOAfromSlidingWindow_rawsignal(coef_all_sensors,channels,scale_min,scale_max,selected_scales,Fs)

mag=0.01;
dt=1/Fs;
window_size=300;
window_step=100;
sliding_step=10;
% scale_number=scale_max-scale_min+1;
scale_number=length(selected_scales);
[~,data_length]=size(coef_all_sensors{1}.cfs);
window_number=floor((data_length-window_size)/window_step);
sliding_number=floor((data_length-window_size)/sliding_step);
% tdoa_pairs=zeros(window_number,sliding_number,channels,scale_number);
tdoa_pairs=[];
tdoa_pairs_3channel=[];
channel_3numbers=[];
scale_4c=[];
scale_3c=[];
reconstruct_signal=zeros(channels,data_length);
energy_reconstruct_signal=zeros(channels,1);
highest_peakvalue=zeros(channels,1);
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
    [one_tdoa,useful_flag]=FindFirstPeak(channels,reconstruct_signal,energy_reconstruct_signal,highest_peakvalue);
    if (useful_flag==0)
        tdoa_pairs=[tdoa_pairs;dt*one_tdoa];
        scale_4c=[scale_4c,one_scale];
    elseif(useful_flag>0)
        tdoa_pairs_3channel=[tdoa_pairs_3channel;dt*one_tdoa];
        scale_3c=[scale_3c,one_scale];
        channels_numbers=[1,2,3,4];
        channels_numbers(useful_flag)=[];
        channel_3numbers=[channel_3numbers;channels_numbers];
    end
end

end

