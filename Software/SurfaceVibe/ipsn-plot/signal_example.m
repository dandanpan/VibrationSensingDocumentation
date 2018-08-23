clear all
close all
clc

init();
% figure;
load('wood24-tap.mat');
%%
sig = data{6}(235000:305000,2);%events{6}(1).data(1:end,2);
Fs = 25000;
% sig = events{6}(1).data(500:end,2);
% Fs = 25000;
% subplot(1,4,1);
% plot([1:length(sig)]./Fs, sig);
% axis tight;
% ylim([-0.6, 0.6]);
% xlabel('Time (s)');ylabel('Amplitude (V)');

windowSize  = 100;
windowEnergy = [];
sigLen = length(sig);
for i = 1:windowSize:sigLen
    windowSig = sig(i:min(i+2*windowSize,sigLen));
    windowEnergy = [windowEnergy; i, sum(windowSig.^2)];
end

noiseSig = windowEnergy(1:8,2);
noiseMean = mean(noiseSig);
noiseStd = std(noiseSig);


% sig = sig(800:1800);
sigLen = length(sig);
figure;
subplot(2,1,1);
plot([1:sigLen]./Fs,sig); xlabel('Time (s)'); ylabel('Amplitude');axis tight;

subplot(2,1,2);
% plot(windowEnergy(:,1)./Fs,windowEnergy(:,2));hold on;
% plot([windowEnergy(1,1)./Fs, windowEnergy(end,1)./Fs],[noiseMean+6*noiseStd, noiseMean+6*noiseStd]);hold off;
% xlabel('Time (s)'); ylabel('Amplitude');
% axis tight;

[f, Y] = signalFrequencyExtraction(sig, Fs);
plot(f,Y);xlabel('Frequency (Hz)'); ylabel('Amplitude');xlim([0,4000]);

%% filter example on taps
figure;
subplot(2,1,1);
plot([1:501]./Fs,signalNormalization(events{5}(3).data(900:1400,2)));hold on;
% plot(signalNormalization(events{5}(3).data(:,3)));hold on;
% plot(signalNormalization(events{5}(3).data(:,4)));hold on;
plot([1:501]./Fs,signalNormalization(events{5}(3).data(900:1400,5)));hold off;axis tight;ylim([-0.2,0.2]);
xlabel('Time (s)');ylabel('Amplitude');title('Raw signal');

subplot(2,1,2);
for k = 20%5:5:50
    for i = [2,5]
        sig = events{5}(3).data(:,i);
        sig = sig - mean(sig);
        sig = signalNormalization(sig);
        [ COEFS ] = waveletAnalysis(sig , 1 );
        [ reconstructedSig ] = waveletFiltering( COEFS, k );
        reconstructedSig = signalNormalization(reconstructedSig);
        plot([1:501]./Fs,reconstructedSig(900:1400));hold on;
    end
    hold off;axis tight;ylim([-0.2,0.2]);
end
xlabel('Time (s)');ylabel('Amplitude');title('Filtered signal');

figure;
SC = wscalogram('image',COEFS.cfs);

%%
load('wood24-swipe.mat');
sig = events{1}(3).data(:,2);
% subplot(1,4,[2,3,4]);
% plot([1:length(sig)]./Fs, sig);
% axis tight;
% ylim([-0.6, 0.6]);
% xlabel('Time (s)');ylabel('Amplitude (V)');

windowSize  = 100;
windowEnergy = [];
sigLen = length(sig);
for i = 1:windowSize:sigLen
    windowSig = sig(i:min(i+2*windowSize,sigLen));
    windowEnergy = [windowEnergy; i, sum(windowSig.^2)];
end
noiseSig = windowEnergy(1:15,2);
noiseMean = mean(noiseSig);
noiseStd = std(noiseSig);

figure;
subplot(2,1,1);
plot([1:sigLen]./Fs,sig); xlabel('Time (s)'); ylabel('Amplitude');axis tight;

subplot(2,1,2);
% plot(windowEnergy(:,1)./Fs,windowEnergy(:,2));hold on;
% plot([windowEnergy(1,1)./Fs, windowEnergy(end,1)./Fs],[noiseMean+6*noiseStd, noiseMean+6*noiseStd]);hold off;
% xlabel('Time (s)'); ylabel('Amplitude');
% axis tight;

[f, Y] = signalFrequencyExtraction(sig(25000:26000), Fs);
plot(f,Y);xlabel('Frequency (Hz)'); ylabel('Amplitude');xlim([0,4000]);

%%
figure;
subplot(2,1,1);
plot(signalNormalization(events{1}(3).data(32100:32600,2)));hold on;
% plot(signalNormalization(events{5}(3).data(:,3)));hold on;
plot(signalNormalization(events{1}(3).data(32100:32600,4)));hold on;
% plot(signalNormalization(events{1}(3).data(1:50000,5)));
hold off;axis tight;
xlabel('Time (s)');ylabel('Amplitude');title('Raw signal');

subplot(2,1,2);
for k = 20%5:5:50
    for i = [2,5]
        sig = events{5}(3).data(:,i);
        sig = sig - mean(sig);
        sig = signalNormalization(sig);
        [ COEFS ] = waveletAnalysis(sig , 1 );
        [ reconstructedSig ] = waveletFiltering( COEFS, k );
        reconstructedSig = signalNormalization(reconstructedSig);
        plot(reconstructedSig(:));hold on;
    end
    hold off;axis tight;ylim([-0.2,0.2]);
end
xlabel('Time (s)');ylabel('Amplitude');title('Filtered signal');
