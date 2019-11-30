%% the function is used to find the first coming peaks for calculating the time differential arrival of the two diffenrent sensors
% for calculating the velocity
%% if this function can't find useful peaks, we need get the first comming peaks manually

function [tdoa_pairs,useful_flag] = FindFirstPeak_velocity(channels,reconstruct_signal,energy_reconstruct_signal,highest_peakvalue)

figure;
colorstring = 'rgbky';
tdoa_pairs=zeros(1,channels);
% get the signal_thre by the energy of every channels between 1.4 to 2
signal_thre=max(sqrt(energy_reconstruct_signal)/sqrt(max(energy_reconstruct_signal))*1.7,1.4);
% signal_thre=ones(channels,1)*1.5
% sort the energy of these channels
energy_sort=sort(energy_reconstruct_signal,'descend');
max_channel=find(energy_reconstruct_signal==max(energy_reconstruct_signal));
min_channel=find(energy_reconstruct_signal==min(energy_reconstruct_signal));
minpeak_channel=find(highest_peakvalue==min(highest_peakvalue));
max_channel=2;
min_channel=1;
minpeak_channel=1;
% find the highest peak is the lowest one
% save the peaks for further justify
store_peaks_number=7;
number_forexactpeak=2;
peaks=zeros(channels,store_peaks_number);
peaks_value=zeros(channels,store_peaks_number);

% The flag of whether this scale is usable:  -1 no; 0 ok ; 1-4 only three
% is ok, the number is the channel which is canceled
useful_flag=0;
%% first get the position of the max energy signal
ci=max_channel;
signal=reconstruct_signal(ci,:);

[all_value,all_position]=findpeaks(signal);
plot(signal,'Color',colorstring(ci));
hold on
% plot(all_position,all_value,'r*');
% hold on
peaks_number=length(all_position);
error_value=all_value(1);
error_mean=all_value(1);


%% threshold for detecting first peak
threshold_between_signal=1.3;
signal_detect=0;
signal_number=1;
% get the mean of the distance between peaks
peak2peak=mean(all_position(2:peaks_number)-all_position(1:peaks_number-1));
threshold_max2now=4; % for the peaks to the max value peak
threshold_other2this=2; % fot the peaks to others' peaks

savingpeaks_thre=8;

% %% find the max value of this channel's scale
t=sort(all_value,'descend');
pos=find(all_value>=t(3),3);
max_value_position=all_position(pos);
max_scale_max_value_position=max_value_position;
for i=2:peaks_number-3
    
    all_position(i);
    if (all_value(i)/error_mean<signal_thre(ci))
        error_value=[error_value,all_value(i)];
        for error_add=1:signal_detect
            error_value=[error_value,all_value(i-error_add)];
        end
        error_mean=mean(error_value);
        signal_detect=0;
    elseif (i<savingpeaks_thre)
        error_value=[error_value,all_value(i)];
        error_mean=mean(error_value);
        signal_detect=0;
    elseif (signal_detect==0 && (all_value(i+1)<=all_value(i) || abs(all_value(i)/all_value(i-1))<=threshold_between_signal))
%             || min(max_value_position-all_position(i))>threshold_max2now*peak2peak))
        error_value=[error_value,all_value(i)];
        error_mean=mean(error_value);
    elseif (signal_detect<signal_number)
        signal_detect=signal_detect+1;
    elseif (all_value(i)/all_value(i-1)<=signal_thre(ci)&& all_value(i+1)/all_value(i)<=signal_thre(ci))  % if the second peak is not enough bigger than the first peak
        error_value=[error_value,all_value(i)];
        for error_add=1:signal_detect
            error_value=[error_value,all_value(i-error_add)];
        end
        error_mean=mean(error_value);
        signal_detect=0;
    else    
        peaks(ci,:)=all_position(i-1:i-1+store_peaks_number-1);
        peaks_value(ci,:)=all_value(i-1:i-1+store_peaks_number-1);
        break;
    end
end
% get the peaks and store it
if (peaks(ci,1)==0)
    useful_flag=-1;
else
    tdoa_pairs(ci)=mean(peaks(ci,1:number_forexactpeak));
end


t=sort(all_value,'descend');
pos=find(all_value>=t(3),3);
max_value_position=all_position(pos);
max_value_position=min([max_value_position,max_scale_max_value_position(1)]);
%% get others according to the position of the first one
for ci=1:channels
signal=reconstruct_signal(ci,:);
[all_value,all_position]=findpeaks(signal);
plot(signal,'Color',colorstring(ci));
hold on
% plot(all_position,all_value,'r*');
% hold on
peaks_number=length(all_position);
error_value=all_value(1);
error_mean=all_value(1);


% threshold for detecting first peaks
signal_detect=0;
signal_number=1;
% get the mean of the distance between peaks
peak2peak=mean(all_position(2:peaks_number)-all_position(1:peaks_number-1));
savingpeaks_thre=2;
% find the max value of this channel's scale
t=sort(all_value,'descend');
pos=find(all_value>=t(3),3);
max_value_position=all_position(pos);
max_value_position=min([max_value_position]);
for i=2:peaks_number-3
    all_position(i)
    if (all_value(i)/error_mean<signal_thre(ci))
        error_value=[error_value,all_value(i)];
        for error_add=1:signal_detect
            error_value=[error_value,all_value(i-error_add)];
        end
        error_mean=mean(error_value);
        signal_detect=0;
    elseif (i<savingpeaks_thre)
        error_value=[error_value,all_value(i)];
        error_mean=mean(error_value);
        signal_detect=0;
    elseif (signal_detect==0 && (all_value(i+1)<=all_value(i) || abs(all_value(i)/all_value(i-1))<=threshold_between_signal...
            || peaks(max_channel,1)-all_position(i)>threshold_other2this*peak2peak))
%             || min(max_value_position-all_position(i))>threshold_max2now*peak2peak...
%             || peaks(max_channel,1)-all_position(i)>threshold_other2this*peak2peak))
        error_value=[error_value,all_value(i)];
        error_mean=mean(error_value);
    elseif (signal_detect<signal_number)
        signal_detect=signal_detect+1;
    elseif (all_value(i)/all_value(i-1)<=signal_thre(ci) && all_value(i+1)/all_value(i)<=signal_thre(ci))
        error_value=[error_value,all_value(i)];
        for error_add=1:signal_detect
            error_value=[error_value,all_value(i-error_add)];
        end
        error_mean=mean(error_value);
        signal_detect=0;
    else
        peaks(ci,:)=all_position(i-1:i-1+store_peaks_number-1);
        peaks_value(ci,:)=all_value(i-1:i-1+store_peaks_number-1);
        break;
    end
end
    % get the peaks and store it
    if peaks(ci,1)==0
        useful_flag=-1;
        tdoa_pairs(ci)=-1;
    else
        tdoa_pairs(ci)=mean(peaks(ci,1:number_forexactpeak));
    end
end

for ci=1:channels    
    plot(peaks(ci,:),peaks_value(ci,:),'r*');
end


%% adjust the final positions of the peaks
% verify that the first comming one's peak is near enough
% verify that the lowest energy one can't exceed the largest one
[t,pos]=sort(tdoa_pairs);
    if (useful_flag==0) % the lowest energy channel has peaks
        if (min_channel==pos(1) && abs(tdoa_pairs(1)-tdoa_pairs(2))>peak2peak/2) % the lowest peak one can't come first
            % calculate the steps to move ( at most 2 stpes)
            move_step=1;
            if (mean(peaks(minpeak_channel,move_step+1:move_step+number_forexactpeak))<t(2))
                move_step=2;
            end
            tdoa_pairs(minpeak_channel)=mean(peaks(minpeak_channel,move_step+1:move_step+number_forexactpeak));
        elseif (abs(tdoa_pairs(1)-tdoa_pairs(2))>peak2peak/2)
            move_step=1;
            while (abs(mean(peaks(pos(1),move_step+1:move_step+number_forexactpeak))-tdoa_pairs(pos(2)))>peak2peak/2 && move_step<=store_peaks_number-number_forexactpeak-1)
                move_step=move_step+1;
            end
            tdoa_pairs(pos(1))=mean(peaks(pos(1),move_step+1:move_step+number_forexactpeak));
        end
    end
    tdoa_pairs=tdoa_pairs(min_channel)-tdoa_pairs(max_channel);
end



