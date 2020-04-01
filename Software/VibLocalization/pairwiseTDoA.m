function [TDoA2] = pairwiseTDoA(sig1,sig2,ts1,ts2,firstPeakThreshold)

    % TDOA1 from cross correlation
    norm_sig1 = sig1./norm(sig1);
    norm_sig2 = sig2./norm(sig2);
    sigXcorr = abs(xcorr(norm_sig1, norm_sig2));
    [~, TDoA1] = max(sigXcorr);
    
    % TDOA2 from first peak
    norm_sig1 = sig1./max(abs(sig1));
    norm_sig2 = sig2./max(abs(sig2));
    [~,sig1Peaks] = findpeaks(abs(norm_sig1),'MinPeakHeight',firstPeakThreshold);
    [~,sig2Peaks] = findpeaks(abs(norm_sig2),'MinPeakHeight',firstPeakThreshold);
    T11 = ts1(sig1Peaks(1));
    T12 = ts1(sig1Peaks(2));
    T21 = ts2(sig2Peaks(1));
    T22 = ts1(sig2Peaks(2));
    % candidates
    candidate1 = T11 - T21;
    candidate2 = T12 - T21;
    candidate3 = T11 - T22;
    candis = [candidate1, candidate2, candidate3];
    [~, idx] = min(abs(candis));
    
    TDoA2 = T11 - T21;
%     TDoA2 = candis(idx);
    
%     figure;
%     findpeaks(abs(norm_sig1),'MinPeakHeight',firstPeakThreshold);hold on;
%     findpeaks(abs(norm_sig2),'MinPeakHeight',firstPeakThreshold);
    
  
end

