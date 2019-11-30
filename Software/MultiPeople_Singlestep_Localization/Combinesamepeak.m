function new_peaks = Combinesamepeak(peaks)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
threhold=10;
n=length(peaks);
peaks;
new_peaks=[];
i=1;
while i<=n-1
    if(peaks(i+1)-peaks(i)<threhold)
        num_merge=1;
        for j=i+1:n-1
            if (peaks(j+1)-peaks(j)<threhold)
                num_merge=num_merge+1;
            else
                break;
            end
        end
        new_peaks=[new_peaks;floor((sum(peaks(i:i+num_merge))/(num_merge+1)))];
        i=i+num_merge+1;
        else
            new_peaks=[new_peaks;peaks(i)];
            i=i+1
        end
end   

end

