% select the frequencies between 10-100 Hz from the scales to do cross
% correlation for TDOA and record the possibility of real

function [tdoa_pairs,tdoa_pairs_3channel,channel_3numbers,scale_4c,scale_3c] = GetTDOAfromSlidingWindow_normalize(data,channels,Fs)

mag=0.01;
dt=1/Fs;
window_size=300;
window_step=100;
sliding_step=10;

data_length=length(data);

tdoa_pairs=[];
tdoa_pairs_3channel=[];
channel_3numbers=[];
scale_4c=[];
scale_3c=[];
energy_reconstruct_signal=zeros(channels,1);
highest_peakvalue=zeros(channels,1);

    for j=1:channels
        % normalization before the wavelet filter and extract the mean

        highest_peakvalue(j)=max(data(j,:));
        energy_reconstruct_signal(j)=norm(data(j,:),2)^2;

%         plot(reconstruct_signal(j,:),'Color',colorstring(j));
%         hold on
    end
    
    % find first peaks for the signals of one scale
    [one_tdoa,useful_flag]=FindFirstPeak(channels,data,energy_reconstruct_signal,highest_peakvalue);
    if (useful_flag==0)
        tdoa_pairs=[tdoa_pairs;dt*one_tdoa];
        scale_4c=[scale_4c,1];
    elseif(useful_flag>0)
        tdoa_pairs_3channel=[tdoa_pairs_3channel;dt*one_tdoa];
        scale_3c=[scale_3c,1];
        channels_numbers=[1,2,3,4];
        channels_numbers(useful_flag)=[];
        channel_3numbers=[channel_3numbers;channels_numbers];
    end
end

