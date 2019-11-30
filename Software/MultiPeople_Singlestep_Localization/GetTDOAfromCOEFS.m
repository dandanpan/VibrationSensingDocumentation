% select the frequencies between 10-100 Hz from the scales to do cross
% correlation for TDOA and record the possibility of real

function [tdoa_pairs] = GetTDOAfromCOEFS(coef_all_sensors,channels, scale_min, scale_max,Fs)

dt=1/Fs;
scale_number=scale_max-scale_min+1;
tdoa_pairs=zeros(scale_number,channels);
reconstruct_signal={};
for i=1:scale_number
    scal2frq(scale_min+i-1,'mexh',dt)
    % get all the reconstructed signals from one scale
    colorstring = 'kbgry';
    figure;
    for j=1:channels
        reconstruct_signal{j}=waveletFiltering(coef_all_sensors{j},scale_min+i-1);
        plot(reconstruct_signal{j},'Color',colorstring(j));
        hold on
    end
    % cross correlation
    for j=1:channels
        [value,shift]=xcorr(reconstruct_signal{1},reconstruct_signal{j});
        value=value/norm(reconstruct_signal{1},2)/norm(reconstruct_signal{j},2);
%         figure;
%         plot(shift,value);
        % find possible peaks
        peaks_threhold=1;
        [ firstPeakIdx, firstPeakVal ]=SelectPossiblePeaks(value,peaks_threhold);       
        firstPeakIdx=-shift(firstPeakIdx);
        tdoa_pairs(i,j)=firstPeakIdx;
    end

end

