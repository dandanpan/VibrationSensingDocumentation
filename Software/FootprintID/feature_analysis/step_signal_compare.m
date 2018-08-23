clear
close all
clc

load('../dataset/steps.mat');
Fs = 1000;

figure;
subplot(2,4,1);
idxSet = find(personIDLabel == 1 & speedIDLabel == 1);
plot([1:400]./Fs,stepSigs(idxSet(4),:));ylim([-0.25, 0.25]);
xlabel('Time (s)');ylabel('Amplitude');
title('(a) Person 1 Speed 1 Time Domain');

[ Y, f, NFFT] = signalFreqencyExtract( stepSigs(idxSet(4),:), Fs );
subplot(2,4,2);
plot(f,Y);xlim([0,100]);
xlabel('Frequency (Hz)');ylabel('Amplitude');
title('(b) Person 1 Speed 1 Freq Domain');


subplot(2,4,3);
idxSet = find(personIDLabel == 1 & speedIDLabel == 7);
plot([1:400]./Fs,stepSigs(idxSet(4),:));ylim([-0.25, 0.25]);
xlabel('Time (s)');ylabel('Amplitude');
title('(c) Person 1 Speed 7 Time Domain');

[ Y, f, NFFT] = signalFreqencyExtract( stepSigs(idxSet(4),:), Fs );
subplot(2,4,4);
plot(f,Y);xlim([0,100]);
xlabel('Frequency (Hz)');ylabel('Amplitude');
title('(d) Person 1 Speed 7 Freq Domain');

subplot(2,4,5);
idxSet = find(personIDLabel == 2 & speedIDLabel == 1);
plot([1:400]./Fs,stepSigs(idxSet(4),:));ylim([-0.25, 0.25]);
xlabel('Time (s)');ylabel('Amplitude');
title('(e) Person 2 Speed 1 Time Domain');

[ Y, f, NFFT] = signalFreqencyExtract( stepSigs(idxSet(4),:), Fs );
subplot(2,4,6);
plot(f,Y);xlim([0,100]);
xlabel('Frequency (Hz)');ylabel('Amplitude');
title('(f) Person 2 Speed 1 Freq Domain');

subplot(2,4,7);
idxSet = find(personIDLabel == 2 & speedIDLabel == 7);
plot([1:400]./Fs,stepSigs(idxSet(4),:));ylim([-0.25, 0.25]);
xlabel('Time (s)');ylabel('Amplitude');
title('(g) Person 2 Speed 7 Time Domain');

[ Y, f, NFFT] = signalFreqencyExtract( stepSigs(idxSet(4),:), Fs );
subplot(2,4,8);
plot(f,Y);xlim([0,100]);
xlabel('Frequency (Hz)');ylabel('Amplitude');
title('(h) Person 2 Speed 7 Freq Domain');