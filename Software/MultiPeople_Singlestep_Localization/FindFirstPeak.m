function [tdoa_pairs,useful_flag] = FindFirstPeak(channels,reconstruct_signal,energy_reconstruct_signal,highest_peakvalue)

figure;
colorstring = 'rgbky';
tdoa_pairs=zeros(1,channels);
% get the signal_thre by the energy of every channels between 1.4 to 2
signal_thre=max(sqrt(energy_reconstruct_signal)/sqrt(max(energy_reconstruct_signal))*1.7,1.4)
% sort the energy of these channels
energy_sort=sort(energy_reconstruct_signal,'descend');
max_channel=find(energy_reconstruct_signal==max(energy_reconstruct_signal));
min_channel=find(energy_reconstruct_signal==min(energy_reconstruct_signal));
minpeak_channel=find(highest_peakvalue==min(highest_peakvalue));
% find the highest peak is the lowest one
% save the peaks for further justify
store_peaks_number=5;
number_forexactpeak=3;
peaks=zeros(channels,5);
peaks_value=zeros(channels,5);

% The flag of whether this scale is usable:  -1 no; 0 ok ; 1-4 only three
% is ok, the number is the channel which is canceled
useful_flag=0;
%% first get the position of the max energy signal
ci=max_channel;
signal=reconstruct_signal(ci,:);

[all_value,all_position]=findpeaks(signal);
%% Laixi
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

savingpeaks_thre=4;

%% find the max value of this channel's scale
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
    elseif (signal_detect==0 && (all_value(i+1)<=all_value(i) || all_value(i)/all_value(i-1)<=threshold_between_signal...
            || min(max_value_position-all_position(i))>threshold_max2now*peak2peak))
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

%% get others according to the position of the first one
for ci=1:channels
    % for the worst channels reset the threshold_max2now
    if(ci==min_channel)
        threshold_max2now=2;
    else
        threshold_max2now=4;
    end
signal=reconstruct_signal(ci,:);
[all_value,all_position]=findpeaks(signal);
%%Laixi
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
max_value_position=min([max_value_position,max_scale_max_value_position(1)]);
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
            || min(max_value_position-all_position(i))>threshold_max2now*peak2peak...
            || peaks(max_channel,1)-all_position(i)>threshold_other2this*peak2peak))
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
    if (peaks(ci,1)==0 && ci~=min_channel)
        useful_flag=-1;
        tdoa_pairs(ci)=-1;
    elseif peaks(ci,1)==0
        tdoa_pairs(ci)=-1;
    else
        tdoa_pairs(ci)=mean(peaks(ci,1:number_forexactpeak));
    end
end

%% Laixi
for ci=1:channels    
    plot(peaks(ci,:),peaks_value(ci,:),'r*');
end
%% adjust the final positions of the peaks
% verify that the first comming one's peak is near enough
if (useful_flag==0) % when we have useful tdoa ( 4 channels or 3 large energy one)
    [t,pos]=sort(tdoa_pairs);
    if (t(2)-t(1)>=1.5*peak2peak)
        tdoa_pairs(pos(1))=mean(peaks(pos(1),2:4));
    end
    % verify that the lowest energy one can't exceed the largest one
    if (tdoa_pairs(min_channel)~=-1) % the lowest energy channel has peaks
        if (min_channel==pos(1)) % the lowest energy one can't come first
            % calculate the steps to move ( at most 2 steps)
            move_step=1;
            if (mean(peaks(min_channel,move_step+1:move_step+number_forexactpeak))<t(2))
                move_step=2;
            end
            tdoa_pairs(min_channel)=mean(peaks(min_channel,move_step+1:move_step+number_forexactpeak));
        end
        if (minpeak_channel==pos(1)) % the lowest peak one can't come first
            % calculate the steps to move ( at most 2 stpes)
            move_step=1;
            if (mean(peaks(minpeak_channel,move_step+1:move_step+number_forexactpeak))<t(2))
                move_step=2;
            end
            tdoa_pairs(minpeak_channel)=mean(peaks(minpeak_channel,move_step+1:move_step+number_forexactpeak));
        end
    end
end
% verify that whether the farthest one can be used
threshold_removechannel=3;
if (tdoa_pairs(min_channel)>threshold_removechannel*peak2peak+min(tdoa_pairs))
    useful_flag=min_channel;
    tdoa_pairs(min_channel)=[];
end
    tdoa_pairs=tdoa_pairs-tdoa_pairs(1);
end



