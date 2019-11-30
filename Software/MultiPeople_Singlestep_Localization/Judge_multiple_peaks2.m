%% after detection of step: judge whether there is two person's signal in
% this step, i.e the signal overlapping
function [step_number,seperate_position] = Judge_multiple_peaks2(channels,coef_all_sensors,selected_scales,noise_coef_all_sensors)
% judge whether it is one person or multiple person
    
    %%  reconstruct the 5 highest frequency signal and get peaks for every scale
    max_scale_number=5;
    seperate_position=[];
    step_number=1; % the default is one peak detected
    signal_energy={};
    noise_signal_energy={}
    all_peaks_value={};
    all_peaks_position={};
    highest_peakvalue=zeros(max_scale_number,1);
    
    for i=1:max_scale_number % for every scale
        signal_energy{i}=0;
        noise_signal_energy{i}=0;
        for j=1:channels
            % normalization before the wavelet filter and extract the mean
            reconstruct_signal(j,:)=waveletFiltering(coef_all_sensors{j},selected_scales(1+3*(i-1)));
            reconstruct_signal(j,:)=reconstruct_signal(j,:)-mean(reconstruct_signal(j,:));
            signal_energy{i}=signal_energy{i}+reconstruct_signal(j,:).^2;
            % get the restructed signal of the noise
            noise_reconstruct_signal(j,:)=waveletFiltering(noise_coef_all_sensors{j},selected_scales(1+3*(i-1)));
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
        
%         %% remove the wrong peaks
%         % if the peaks max value is too low
%         wrong_peak_thre=1/8;
%         [value_max_peak,position_max_peak]=max(stepEventsVal);
%         for peak_i=length(stepEventsVal):-1:1
%             if(stepEventsVal(peak_i)<wrong_peak_thre*value_max_peak)
%                 stepStartIdxArray(peak_i)=[];
%                 stepStopIdxArray(peak_i)=[];
%                 stepEventsVal(peak_i)=[];
%             end
%         end
%         % if the length of peak is small
%         peak_length=400;
%         wrong_peak_thre2=1/4;
%         for peak_i=length(stepEventsVal):-1:1
%             if(stepStopIdxArray(peak_i)-stepStartIdxArray(peak_i)<peak_length &&...
%                     stepEventsVal(peak_i)<wrong_peak_thre2*value_max_peak)
%                 stepStartIdxArray(peak_i)=[];
%                 stepStopIdxArray(peak_i)=[];
%                 stepEventsVal(peak_i)=[];
%             end
%         end
        
        %% store the peaks position and value
        all_peaks_value{i}=stepEventsVal;
        all_peaks_position{i}=[stepStartIdxArray;stepStopIdxArray];
    end
    
    
    %% vote on the peaks, up to 3 will be a peak
    same_peak_thre=200;
    
    real_peaks=all_peaks_position{1}; % the column is peak start and stop
    vote_for_peaks=3*ones(1,size(real_peaks,2));  
    for i=2:max_scale_number
        one_frequency_peaks=all_peaks_position{i};
        % search for same peaks
        for add_i=1:size(one_frequency_peaks,2)
            is_new=1;
            for now_j=1:size(real_peaks,2)
                smallest_peak_length=min((real_peaks(2,now_j)-real_peaks(1,now_j)),...
                    (one_frequency_peaks(2,add_i)-one_frequency_peaks(1,add_i)));
                if (min(real_peaks(2,now_j),one_frequency_peaks(2,add_i))...% overlapping bigger than same peak thr
                        -max(real_peaks(1,now_j),one_frequency_peaks(1,add_i))>min (same_peak_thre,smallest_peak_length*0.8))
                    vote_for_peaks(now_j)=vote_for_peaks(now_j)+1;
                    is_new=0; % this is a peak which already exists
                    break;
                end
            end
            if (is_new==1) % this is a new peak
                vote_for_peaks=[vote_for_peaks,1];
                real_peaks=[real_peaks,one_frequency_peaks(:,add_i)];
            end
        end
    end   
    %% get the voting
    false_peaks_index=find(vote_for_peaks<=2);
    real_peaks(:,false_peaks_index)=[];
    
    %% order and return the results
    step_number=size(real_peaks,2);
    %% order these peaks
    if (step_number~=0)
        [t,pos]=sort(real_peaks(1,:));
        real_peaks=real_peaks(:,pos);
        for i=1:size(real_peaks,2)-1
            seperate_position=[seperate_position;real_peaks(2,i),real_peaks(1,i+1)];
        end
        if (~isempty(seperate_position))
            figure;
            plot(signal_energy{max_scale_number});
            hold on
            plot(floor(3/4*seperate_position(:,1)+1/4*seperate_position(:,2)),signal_energy{max_scale_number}(floor(3/4*seperate_position(:,1)+1/4*seperate_position(:,2))),'r*');
        end
    end
end

