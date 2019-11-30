function [step_number,tdoa_pairs,tdoa_pairs_3channel,channel_3numbers, scale_4c,scale_3c] = ShowoneScaleData(channels,data,Fs,noise_data)
%% set all the varibales required for storing
tdoa_pairs={};
tdoa_pairs_3channel={};
channel_3numbers={};
scale_4c={};
scale_3c={};
% test the extraction of one event
colorstring = 'rgbky';
figure(4);
title('P1 center the vibration data of 8 sensors');
for i=1:channels
    plot(data(i,:),'Color',colorstring(i));
    hold on
end

    coef_all_sensors={};
    scale_length=1024;
    energy_scale=zeros(channels,scale_length); % the energy of every scale
    for i=1:channels
        isshow=1;
        [COEFS,maxscale,energy_scale(i,:)]= Getwavelet(data(i,:), isshow);
        coef_all_sensors{i}=COEFS;
    end
    
%     scale_min=50;
    scale_min=50;
    scale_max=126;
    [selected_scales,scales_values] = ExtractPossibleScale(channels,scale_min, scale_max,energy_scale);
    
    %% get the reconstructed noise data
    noise_coef_all_sensors={};
    energy_scale=zeros(channels,scale_length); % the energy of every scale
    for i=1:channels
        isshow=1;
        [COEFS,maxscale,energy_scale(i,:)]= Getwavelet(noise_data(i,:), isshow);
        noise_coef_all_sensors{i}=COEFS;
    end
    
 [step_number,seperate_position]=Judge_multiple_peaks2(channels,coef_all_sensors,selected_scales,noise_coef_all_sensors);
% using cross correlation to get possible TDOA

 % there is no peaks in this event
if (step_number==0 || step_number==1)
    [tdoa_pairs{1},tdoa_pairs_3channel{1},channel_3numbers{1},scale_4c{1},scale_3c{1}]=GetTDOAfromSlidingWindow_normalize(coef_all_sensors,channels,scale_min,scale_max,selected_scales,Fs);
else
    % seperate the signals of multiple peaks
    step_number
    coef_one_sensors_all=coef_all_sensors;
    [~,data_length]=size(coef_all_sensors{1}.cfs);
    for peak_i=1:step_number
        if (peak_i==1)
            for i=1:channels
                coef_one_sensors_all{i}.cfs=coef_all_sensors{i}.cfs(:,1:floor(mean(seperate_position(1,:))));
            end
        elseif(peak_i==step_number)
            for i=1:channels
                coef_one_sensors_all{i}.cfs=coef_all_sensors{i}.cfs(:,floor(3/4*seperate_position(peak_i-1,1)+1/4*seperate_position(peak_i-1,2)):data_length);
            end
        else
            for i=1:channels
                coef_one_sensors_all{i}.cfs=coef_all_sensors{i}.cfs...
                    (:,floor(3/4*seperate_position(peak_i-1,1)+1/4*seperate_position(peak_i-1,2)):floor(mean(seperate_position(peak_i,:))));
            end
        end   
    [tdoa_pairs{peak_i},tdoa_pairs_3channel{peak_i},channel_3numbers{peak_i},scale_4c{peak_i},scale_3c{peak_i}]=...
        GetTDOAfromSlidingWindow_normalize(coef_one_sensors_all,channels,scale_min,scale_max,selected_scales,Fs);
    end
end
end

