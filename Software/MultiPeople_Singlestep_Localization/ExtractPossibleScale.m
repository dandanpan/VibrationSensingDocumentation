function [selected_scales,scales_values] = ExtractPossibleScale(channels,scale_min, scale_max,energy_scale)
% draw the energy distribution
%     figure;
%     colorstring = 'rgbky';
%     for i=1:channels
%         plot(energy_scale(i,:),'Color',colorstring(i));
%         hold on
%     end

    select_thre=5;
    selected_scales=[scale_min:select_thre:scale_max];
    for i=1:channels
        [value,pos]=findpeaks(energy_scale(i,scale_min:scale_max));
%         plot(scale_min+pos-1,value,'r*');
%         hold on
        selected_scales=[selected_scales,setdiff(scale_min+pos-1, selected_scales)];
    end
    energy_all=sum(energy_scale);
    scales_values=energy_all(selected_scales);
    
end

