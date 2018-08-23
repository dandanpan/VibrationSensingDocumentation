function [f, Y] = signalFrequencyExtraction(signal, Fs)
    L = length(signal);
    NFFT = 2^nextpow2(L);
    Y = fft(signal, NFFT)/L;
    Y = 2*abs(Y(1:NFFT/2+1));
    f = (1:NFFT/2+1)*Fs/NFFT;
    
end