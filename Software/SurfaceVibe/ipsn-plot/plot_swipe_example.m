clear all
close all
clc

load('wood24-dampened-swipe.mat');
% 
% for i = 1:10
%     events{1}(i).plot();
% end

timestamps = events{1}(10).data(:,1);
timestamps = timestamps - timestamps(1);

figure;
subplot(2,2,[1,2]);
plot(timestamps,events{1}(10).data(:,4));axis tight;
ylim([-0.2,0.3]);
xlabel('Time (s)');ylabel('Amplitude (V)');
title('Raw Signal');
sig1 = events{1}(10).data(6900:7900,4);%figure;plot(sig1);
sig2 = events{1}(10).data(1.16*Fs:1.2*Fs,4);%figure;plot(sig2);
sig1 = sig1 - mean(sig1);
sig2 = sig2 - mean(sig2);
[f, Y] = signalFrequencyExtraction(sig1, Fs);

subplot(2,2,3);plot(f,Y);xlim([0,1000]);
xlabel('Frequency (Hz)');ylabel('Amplitude (V)');
[f, Y] = signalFrequencyExtraction(sig2, Fs);
title('Tap Frequency');
subplot(2,2,4);plot(f,Y);xlim([0,1000]);
xlabel('Frequency (Hz)');ylabel('Amplitude (V)');
title('Swipe Frequency');

figure;
subplot(2,3,[1,2,3]);
plot(timestamps,events{1}(10).data(:,4));hold on;
plot(timestamps,events{1}(10).data(:,2));hold on;
plot([0.77,0.77],[-0.2,0.3],'k');
plot([0.79,0.79],[-0.2,0.3],'k');
plot([1.36,1.36],[-0.2,0.3],'k');
plot([1.38,1.38],[-0.2,0.3],'k');
plot([1.90,1.90],[-0.2,0.3],'k');
plot([1.92,1.92],[-0.2,0.3],'k');
axis tight;
xlabel('Time (s)');ylabel('Amplitude (V)');

subplot(2,3,4);
idx = find(timestamps > 0.77 & timestamps < 0.79);
plot(timestamps(idx)-timestamps(idx(1)),events{1}(10).data(idx,4));hold on;
plot(timestamps(idx)-timestamps(idx(1)),events{1}(10).data(idx,2));hold off;
% xlim([0.77,0.79]);
xlabel('Time (s)');ylabel('Amplitude (V)');

subplot(2,3,5);
idx = find(timestamps > 1.36 & timestamps < 1.38);
plot(timestamps(idx)-timestamps(idx(1)),events{1}(10).data(idx,4));hold on;
plot(timestamps(idx)-timestamps(idx(1)),events{1}(10).data(idx,2));hold off;
% xlim([1.36,1.38]);
xlabel('Time (s)');ylabel('Amplitude (V)');

subplot(2,3,6);
idx = find(timestamps > 1.9 & timestamps < 1.92);
plot(timestamps(idx)-timestamps(idx(1)),events{1}(10).data(idx,4));hold on;
plot(timestamps(idx)-timestamps(idx(1)),events{1}(10).data(idx,2));hold off;
xlabel('Time (s)');ylabel('Amplitude (V)');
% xlim([1.89,1.91]);

%% filter eg
idx = find(timestamps > 0.77 & timestamps < 0.79);
% idx = find(timestamps > 1.36 & timestamps < 1.38);
% idx = find(timestamps > 1.9 & timestamps < 1.92);
egSig1 = events{1}(10).data(idx,4);
egSig2 = events{1}(10).data(idx,2);

[ COEFS ] = waveletAnalysis(egSig1 , 1 );
[ reconstructedSig1 ] = waveletFiltering( COEFS, 20 );
[ COEFS ] = waveletAnalysis(egSig2 , 2 );
[ reconstructedSig2 ] = waveletFiltering( COEFS, 20 );
figure;
subplot(2,1,1);
plot([1:500]./Fs,signalNormalization(egSig1));hold on;
plot([1:500]./Fs,signalNormalization(egSig2));hold off;
xlabel('Time (s)');ylabel('Amplitude');title('Raw signal');

subplot(2,1,2);
plot([1:500]./Fs,signalNormalization(reconstructedSig1));hold on;
plot([1:500]./Fs,signalNormalization(reconstructedSig2));hold off;
xlabel('Time (s)');ylabel('Amplitude');title('Filtered signal');


%% NEW plot 
figure;
subplot(2,4,[1:3]);
plot(timestamps,events{1}(10).data(:,4));hold on;
plot(timestamps,events{1}(10).data(:,2));hold on;
plot([0.77,0.77],[-0.3,0.3],'k');
plot([0.79,0.79],[-0.3,0.3],'k');
plot([1.36,1.36],[-0.3,0.3],'k');
plot([1.38,1.38],[-0.3,0.3],'k');
plot([1.90,1.90],[-0.3,0.3],'k');
plot([1.92,1.92],[-0.3,0.3],'k');
plot([0.276,0.276],[-0.3,0.3],'k');
plot([0.296,0.296],[-0.3,0.3],'k');
axis tight;
xlabel('Time (s)');ylabel('Amplitude (V)');

% subplot(2,6,7);
% idx = find(timestamps > 0.276 & timestamps < 0.296);
% plot(timestamps(idx)-timestamps(idx(1)),events{1}(10).data(idx,4));hold on;
% plot(timestamps(idx)-timestamps(idx(1)),events{1}(10).data(idx,2));hold off;
% % xlim([0.77,0.79]);
% xlabel('Time (s)');ylabel('Amplitude (V)');

subplot(2,4,4);
sig1 = events{1}(10).data(6900:7400,4);
[f, Y] = signalFrequencyExtraction(sig1, Fs);
plot(f,Y);xlim([0,1000]);
xlabel('Frequency (Hz)');ylabel('Amplitude (V)');


subplot(2,4,5);
idx = find(timestamps > 0.77 & timestamps < 0.79);
plot(timestamps(idx)-timestamps(idx(1)),events{1}(10).data(idx,4));hold on;
plot(timestamps(idx)-timestamps(idx(1)),events{1}(10).data(idx,2));hold off;
% xlim([0.77,0.79]);
xlabel('Time (s)');ylabel('Amplitude (V)');

subplot(2,4,6);
idx = find(timestamps > 1.36 & timestamps < 1.38);
plot(timestamps(idx)-timestamps(idx(1)),events{1}(10).data(idx,4));hold on;
plot(timestamps(idx)-timestamps(idx(1)),events{1}(10).data(idx,2));hold off;
% xlim([1.36,1.38]);
xlabel('Time (s)');ylabel('Amplitude (V)');

subplot(2,4,7);
idx = find(timestamps > 1.9 & timestamps < 1.92);
plot(timestamps(idx)-timestamps(idx(1)),events{1}(10).data(idx,4));hold on;
plot(timestamps(idx)-timestamps(idx(1)),events{1}(10).data(idx,2));hold off;
xlabel('Time (s)');ylabel('Amplitude (V)');
% xlim([1.89,1.91]);

subplot(2,4,8);
sig2 = events{1}(10).data(idx,4);
[f, Y] = signalFrequencyExtraction(sig2, Fs);
plot(f,Y);xlim([0,1000]);
xlabel('Frequency (Hz)');ylabel('Amplitude (V)');
