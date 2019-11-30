% select the frequencies between 10-100 Hz from the scales to do cross
% correlation for TDOA and record the possibility of real

function [tdoa_pairs] = GetTDOAfromSlidingWindow(coef_all_sensors,channels, scale_min, scale_max,Fs)

mag=0.01;
dt=1/Fs
window_size=200;
window_step=20;
sliding_step=10;
scale_number=scale_max-scale_min+1;
[~,data_length]=size(coef_all_sensors{1}.cfs);
window_number=floor((data_length-window_size)/window_step);
tdoa_pairs=zeros(window_number,2*data_length-1,scale_number);
reconstruct_signal={};
for i=1:scale_number
    scal2frq(scale_min+i-1,'mexh',dt)
    % get all the reconstructed signals from one scale
    colorstring = 'kbgry';
    figure;
    for j=1:channels
        % normalization before the wavelet filter and extract the mean
        reconstruct_signal{j}=waveletFiltering(coef_all_sensors{j},scale_min+i-1);
        plot(reconstruct_signal{j},'Color',colorstring(j));
        hold on
    end
    
    % cross correlation
    figure;
    plot(reconstruct_signal{1});
    hold on
    for j=1:channels
        for k=120:window_number
            signal_inwindow=zeros(length(reconstruct_signal{1}),1);
            signal_inwindow((k-1)*window_step+1:(k-1)*window_step+window_size)...
                =reconstruct_signal{1}((k-1)*window_step+1:(k-1)*window_step+window_size);
            [value,shift]=xcorr(signal_inwindow,reconstruct_signal{j});

            rectangle('Position',[(k-1)*window_step+1,-mag, window_size,2*mag],'EdgeColor','r');
            %         figure;
%         plot(shift,value);
%         % find possible peaks
%             peaks_threhold=1;
%             [ firstPeakIdx, firstPeakVal ]=SelectPossiblePeaks(value,peaks_threhold);       
%             firstPeakIdx=-shift(firstPeakIdx);
%             tdoa_pairs(i,j)=firstPeakIdx;
            tdoa_pairs(k,:,j)=value;
        end
        figure;
        mesh(tdoa_pairs(:,:,j));
        thres=0.2*max(abs(tdoa_pairs(:,:,j)));
        p=FastPeakFind(tdoa_pairs(:,:,j),thres);
    end
end

end

