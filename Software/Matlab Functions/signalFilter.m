function [ signal_filtered ] = signalFilter( signal, Fs, cutLow, cutHigh )

%     wc=fc*(2/Fs); % coefficient calculation
%     f_coff = fir1(1024,wc); %
%     signal_filtered = filter(f_coff, 1, signal);
%     
%     figure;
%     subplot(2,1,1);
%     plot(signal);
%     subplot(2,1,2);
%     plot(signal_filtered);

    d = designfilt('bandpassfir','FilterOrder',10, ...
                   'CutoffFrequency1',cutLow,'CutoffFrequency2',cutHigh, ...
                   'SampleRate',Fs);
    signal_filtered = filtfilt(d, double(signal)); 
    
    
end

