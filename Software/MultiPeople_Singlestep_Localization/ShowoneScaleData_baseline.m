function [step_number,tdoa_pairs,tdoa_pairs_3channel,channel_3numbers, scale_4c,scale_3c] = ShowoneScaleData_baseline(channels,data,Fs,noise_data,mode)
%% set all the varibales required for storing
dt=1/Fs;
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
    %% baseline adding 
    scale_min=1;
    scale_max=1024;

    
    seperate_position=[];
    step_number=0;
    
    if (mode==1) % using raw signal
        figure;
        mag=max(sqrt(sum(data.^2)));
        plot(sqrt(sum(data.^2)));

        [stepEventsIdx, stepEventsVal, ...
            stepStartIdxArray, stepStopIdxArray, ... 
            windowEnergyArray, noiseMu, noiseSigma, noiseRange ]=PeaksDetection_withinEvent(...
            sqrt(sum(data.^2)), sqrt(sum(noise_data.^2)),150,10);

        for plot_i=1:length(stepEventsIdx)
            rectangle('Position',[stepStartIdxArray(plot_i),-mag,...
            stepStopIdxArray(plot_i)-stepStartIdxArray(plot_i),2*mag],'EdgeColor','r');
        end
        
        %% get the step_number and seperate_position
        for i=1:length(stepStartIdxArray)-1
            seperate_position=[seperate_position;stepStopIdxArray(i),stepStartIdxArray(i+1)];
        end
        step_number=length(stepStartIdxArray);
        
        %% get the tdoa from raw signal
        if(step_number==0)  % there is no peaks in this event
        elseif (step_number==1)

            [tdoa_pairs{1},tdoa_pairs_3channel{1},channel_3numbers{1},scale_4c{1},scale_3c{1}]=...
        GetTDOAfromSlidingWindow_rawsignal(data,channels,Fs);
        else
     % seperate the signals of multiple peaks
        step_number
    
        data_length=size(data,2);
    for peak_i=1:step_number
        one_data=[];
        if (peak_i==1)
            for i=1:channels
                one_data=[one_data;data(:,1:floor(mean(seperate_position(1,:))))];
            end
        elseif(peak_i==step_number)
            for i=1:channels
                one_data=[one_data;data(:,floor(3/4*seperate_position(peak_i-1,1)+1/4*seperate_position(peak_i-1,2)):data_length)];
            end
        else
            for i=1:channels
                one_data=[one_data;...
                    data(:,floor(3/4*seperate_position(peak_i-1,1)+1/4*seperate_position(peak_i-1,2)):floor(mean(seperate_position(peak_i,:))))];
            end
        end   
        [tdoa_pairs{peak_i},tdoa_pairs_3channel{peak_i},channel_3numbers{peak_i},scale_4c{peak_i},scale_3c{peak_i}]...
        =GetTDOAfromSlidingWindow_rawsignal(one_data,channels,Fs);
    end
end
        
       
        
      %% &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
    else %% using wavelet to get high and low frequency results

    %% wavelet filtering the signal
    coef_all_sensors={};
    scale_length=1024;
    energy_scale=zeros(channels,scale_length); % the energy of every scale
    for i=1:channels
        isshow=0;
        [COEFS,maxscale,energy_scale(i,:)]= Getwavelet(data(i,:), isshow);
        coef_all_sensors{i}=COEFS;
    end
    
    %% get the reconstructed noise data
    noise_coef_all_sensors={};
    energy_scale=zeros(channels,scale_length); % the energy of every scale
    for i=1:channels
        isshow=0;
        [COEFS,maxscale,energy_scale(i,:)]= Getwavelet(noise_data(i,:), isshow);
        noise_coef_all_sensors{i}=COEFS;
    end
     
    
    %% know it is high frequency or low frequency
    if(mode==2)
        selected_scale=randi(512,1)
    else
        
        selected_scale=50;
    end
    
    %% reconstruct the signal
    signal_energy{i}=0;
        noise_signal_energy{i}=0;
        for j=1:channels
            % normalization before the wavelet filter and extract the mean
            reconstruct_signal(j,:)=waveletFiltering(coef_all_sensors{j},selected_scale);
            reconstruct_signal(j,:)=reconstruct_signal(j,:)-mean(reconstruct_signal(j,:));
            signal_energy{i}=signal_energy{i}+reconstruct_signal(j,:).^2;
            % get the restructed signal of the noise
            noise_reconstruct_signal(j,:)=waveletFiltering(noise_coef_all_sensors{j},selected_scale);
            noise_reconstruct_signal(j,:)=noise_reconstruct_signal(j,:)-mean(noise_reconstruct_signal(j,:));
            noise_signal_energy{i}=noise_signal_energy{i}+noise_reconstruct_signal(j,:).^2;
        end
        
        highest_peakvalue(i)=max(signal_energy{i});
        figure;
        mag=highest_peakvalue(i);
        plot(signal_energy{i});
        % plot(peaks_position{i},peaks_value{i},'r*');
        hold on
        %% detect peaks
        [stepEventsIdx, stepEventsVal, ...
            stepStartIdxArray, stepStopIdxArray, ... 
            windowEnergyArray, noiseMu, noiseSigma, noiseRange ]=PeaksDetection_withinEvent(...
            sqrt(signal_energy{i}), sqrt(noise_signal_energy{i}),120,20);
        
        for plot_i=1:length(stepEventsIdx)
            rectangle('Position',[stepStartIdxArray(plot_i),-mag,...
                stepStopIdxArray(plot_i)-stepStartIdxArray(plot_i),2*mag],'EdgeColor','r');
        end
        
        %% get the step_number and seperate_position
        for i=1:length(stepStartIdxArray)-1
            seperate_position=[seperate_position;stepStopIdxArray(i),stepStartIdxArray(i+1)];
        end
        step_number=length(stepStartIdxArray);
        

% using cross correlation to get possible TDOA

if(step_number==0 || step_number==1)  % there is no peaks in this event
    [tdoa_pairs{1},tdoa_pairs_3channel{1},channel_3numbers{1},scale_4c{1},scale_3c{1}]=GetTDOAfromSlidingWindow_normalize(coef_all_sensors,channels,scale_min,scale_max,selected_scale,Fs);
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
        GetTDOAfromSlidingWindow_normalize(coef_one_sensors_all,channels,scale_min,scale_max,selected_scale,Fs);
    end
end
end
end

