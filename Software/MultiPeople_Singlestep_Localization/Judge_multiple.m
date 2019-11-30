%% after detection of step: judge whether there is two person's signal in
% this step, i.e the signal overlapping
function [single_ornot,seperate_position,judge_single] = Judge_multiple_peaks(channels,coef_all_sensors,selected_scales)
% judge whether it is one person or multiple person
    
    max_scale_number=3;
    position_seperate=zeros(3,1);
    single_ornot=1; % the default is one person
    signal_energy={};
    peaks_value={};
    peaks_position={};
    highest_peakvalue=zeros(max_scale_number,1);
    figure;
    for i=1:max_scale_number
        signal_energy{i}=0;
        for j=1:channels
            % normalization before the wavelet filter and extract the mean
            reconstruct_signal(j,:)=waveletFiltering(coef_all_sensors{j},selected_scales(1+3*(i-1)));
            reconstruct_signal(j,:)=reconstruct_signal(j,:)-mean(reconstruct_signal(j,:));
            signal_energy{i}=signal_energy{i}+reconstruct_signal(j,:).^2;
        end
        [peaks_value{i},peaks_position{i}]=findpeaks(signal_energy{i});
        highest_peakvalue(i)=max(peaks_value{i});
        plot(signal_energy{i});
        hold on
%         plot(peaks_position{i},peaks_value{i},'r*');
    end
    
    % get the noise level
    noise_energy_level=mean(peaks_value{i}(1:10));
    detect_noise_level=200;
    % firstly detect good condition and store the highest frequency result
    wide_step=300; % the width of steps is
    wide_from_end=200;
    step_thre=0.4;
    high_step_detected_start=[];
    high_step_detected_end=[];
    high_step_start_flag=0;
    i=1;
    for j=1:length(peaks_value{i})
            if (peaks_value{i}(j)>step_thre*highest_peakvalue(i) && high_step_start_flag==0)  % the step haven't start or interrupt
                if (isempty(high_step_detected_start)) % detect the first step
                    high_step_start_flag=1;
                    high_step_detected_start=peaks_position{i}(j);
                    high_step_detected_end=peaks_position{i}(j);
                elseif  (peaks_position{i}(j)-high_step_detected_start(length(high_step_detected_start))<=wide_step... % reconnect the interrupted step
                        || peaks_position{i}(j)-high_step_detected_end(length(high_step_detected_end))<=wide_from_end) 
                    % merge
                    high_step_start_flag=1;
                    high_step_detected_end(length(high_step_detected_start))=peaks_position{i}(j);
                else  % get a new step
                    high_step_start_flag=1;
                    high_step_detected_start=[high_step_detected_start,peaks_position{i}(j)];
                    high_step_detected_end=[high_step_detected_end,peaks_position{i}(j)];
                end
            elseif (peaks_value{i}(j)>step_thre*highest_peakvalue(i) && high_step_start_flag==1) % the signal decay after started
                high_step_detected_end(length(high_step_detected_start))=peaks_position{i}(j);
            elseif (peaks_value{i}(j)<=step_thre*highest_peakvalue(i) && high_step_start_flag==1)
                high_step_start_flag=0;
            end
    end
    
    if (length(high_step_detected_start)>=2 )
        single_ornot=0;
        seperate_position=[high_step_detected_end(1),high_step_detected_start(2)];
        plot(floor(mean(seperate_position)),signal_energy{i}(floor(mean(seperate_position))),'r*');
    else
    % if didn't find 2 step, then try other scales
    wide_from_end=200;
    step_thre=0.2;
    step_detected_start=[];
    step_detected_end=[];
    step_start_flag=0;
    for i=1:max_scale_number
        step_detected_start=[];
        step_detected_end=[];
        step_start_flag=0;
        for j=1:length(peaks_value{i})
            if (peaks_value{i}(j)>step_thre*highest_peakvalue(i) && step_start_flag==0)  % the step haven't start or interrupt
                if (isempty(step_detected_start)) % detect the first step
                    step_start_flag=1;
                    step_detected_start=peaks_position{i}(j);
                    step_detected_end=peaks_position{i}(j);
                elseif (peaks_position{i}(j)-step_detected_start(length(step_detected_start))<=wide_step...
                        || peaks_position{i}(j)-step_detected_end(length(step_detected_end))<=wide_from_end) % reconnect the interrupted step
                    % merge
                    step_start_flag=1;
                    step_detected_end(length(step_detected_start))=peaks_position{i}(j);
                else   % get a new step
                    step_start_flag=1;
                    step_detected_start=[step_detected_start,peaks_position{i}(j)];
                    step_detected_end=[step_detected_end,peaks_position{i}(j)];
                end
            elseif (peaks_value{i}(j)>step_thre*highest_peakvalue(i) && step_start_flag==1) % the signal decay after started
                step_detected_end(length(step_detected_start))=peaks_position{i}(j);
            elseif (peaks_value{i}(j)<=step_thre*highest_peakvalue(i) && step_start_flag==1)
                step_start_flag=0;
            end
        end
        % judge whether find second step
        if (length(step_detected_start)>1)
            for stepi=length(step_detected_start):-1:1
                if (step_detected_end(stepi)-step_detected_start(stepi)<100)
                    step_detected_start(stepi)=[];
                    step_detected_end(stepi)=[];
                end
            end
        end
        if (length(step_detected_start)>=2)
            single_ornot=0;
            seperate_position=[step_detected_end(1),step_detected_start(2)];
            plot(floor(mean(seperate_position)),signal_energy{i}(floor(mean(seperate_position))),'r*');
            break;
        end
    end
    
    % judge one or two peaks for calculation
    if (length(step_detected_start)==1)
        single_ornot=1;
        seperate_position=0;
        %% judge whether there are two but one is too small
        % parameter for judge one or two person
        judge_single=1;
        wide_step2=200;
        wide_from_end2=150;
        step_thre=0.2;
        step_detected_start=[];
        step_detected_end=[];
        step_start_flag=0;
    for i=1:max_scale_number
        step_detected_start=[];
        step_detected_end=[];
        step_start_flag=0;
        for j=1:length(peaks_value{i})
            if (peaks_value{i}(j)>step_thre*highest_peakvalue(i) && step_start_flag==0)  % the step haven't start or interrupt
                if (isempty(step_detected_start)) % detect the first step
                    step_start_flag=1;
                    step_detected_start=peaks_position{i}(j);
                    step_detected_end=peaks_position{i}(j);
                elseif (peaks_position{i}(j)-step_detected_start(length(step_detected_start))<=wide_step2...
                        || peaks_position{i}(j)-step_detected_end(length(step_detected_end))<=wide_from_end2) % reconnect the interrupted step
                    % merge
                    step_start_flag=1;
                    step_detected_end(length(step_detected_start))=peaks_position{i}(j);
                else   % get a new step
                    step_start_flag=1;
                    step_detected_start=[step_detected_start,peaks_position{i}(j)];
                    step_detected_end=[step_detected_end,peaks_position{i}(j)];
                end
            elseif (peaks_value{i}(j)>step_thre*highest_peakvalue(i) && step_start_flag==1) % the signal decay after started
                step_detected_end(length(step_detected_start))=peaks_position{i}(j);
            elseif (peaks_value{i}(j)<=step_thre*highest_peakvalue(i) && step_start_flag==1)
                step_start_flag=0;
            end
        end
        % judge whether find second step
        if (length(step_detected_start)>=2)
            seperate_position=[step_detected_end(1),step_detected_start(2)];
            plot(floor(mean(seperate_position)),signal_energy{i}(floor(mean(seperate_position))),'r*');
            judge_single=2;
            break;
        end
    end
    
    %% if detect 2 peaks for calculations
    else
        single_ornot=0;
        judge_single=2;
        seperate_position=[step_detected_end(1),step_detected_start(2)];
        plot(floor(mean(seperate_position)),signal_energy{i}(floor(mean(seperate_position))),'r*');
    end
    end
    
end

