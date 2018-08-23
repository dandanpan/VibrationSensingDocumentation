function [ features ] = spectrumFeatures( specSig )
%SPECTRUMFEATURES Summary of this function goes here
%   Detailed explanation goes here
        features = [];
        % basic statistics
        f1 = mean(specSig);
        f2 = std(specSig);
        f3 = max(specSig);
        f4 = min(specSig);
        
        changeInSpec = diff(specSig);
        % find top 3 difference
        [soredV, soredI]= sort(abs(changeInSpec),'descend');
        if length(soredI) >= 3
             soredI = soredI(1:3);
             f5 = soredI;
             f6 = changeInSpec(soredI);
        elseif length(soredI) > 0
             soredI = soredI(1);
             f5 = [soredI,soredI,soredI];
             f6 = [changeInSpec(soredI),changeInSpec(soredI),changeInSpec(soredI)];
        else
             f5 = [0,0,0];
             f6 = [0,0,0];
        end
        features = [f1,f2,f3,f4,f5,f6];
end

