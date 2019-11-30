close all
clear all
avg = 0;
s = daq.createSession('ni')
s.Rate = 25600;%2560
% addAnalogInputChannel(s,'cDAQ2Mod3',0:0,'IEPE');
% addAnalogInputChannel(s,'cDAQ2Mod3',3:3,'Voltage');
addAnalogInputChannel(s,'cDAQ2Mod1',0:2,'Voltage');
% addAnalogInputChannel(s,'cDAQ2Mod2',0:2,'Voltage');
 addAnalogInputChannel(s,'cDAQ2Mod2',0:2,'Voltage');

fid1 = fopen('log.bin','w');
lh = addlistener(s,'DataAvailable',@(src, event)logData(src, event, fid1));
s.IsContinuous = true;
s.startBackground;
pause(30);
s.stop;
delete(lh);
fclose(fid1);

n=6; %number of sensors

fid2 = fopen('log.bin','r');
[data,count] = fread(fid2,[(n+1),inf],'double');
fclose(fid2);

fc = 50;
fs = s.Rate;
% [b, a] = butter(6, fc/(fs/2));
% dataout = filter(b, a, data(2, :));
% figure; plot(dataout)
% figure;plot(abs(fft(data(2,:))));xlim([0 1000]);
t = data(1,:);
%ch = data(2:4,:);
ch = data(2:(n+1),:);
% n = 4 %number of sensors
% figure; plot(t,data(2,:)); %ylim([0 5])
figure; subplot(n,1,1); plot(t, data(2,:)); ylim([0 5])
subplot(n,1,2); plot(t, data(3, :)); ylim([0 5])
subplot(n,1,3); plot(t, data(4, :)); ylim([0 5])
subplot(n,1,4); plot(t, data(5,:)); ylim([0 5])
subplot(n,1,5); plot(t, data(6,:)); ylim([0 5])
subplot(n,1,6); plot(t, data(7,:)); ylim([0 5])

% figure; 
% plot(t, data(2,:)); ylim([-5 5]); hold on;
% plot(t, data(3,:)); ylim([-5 5]); hold on;
% plot(t, data(4,:)); ylim([-5 5]); hold on;
% plot(t, data(5,:)); ylim([-5 5]);hold off;

% save('./PorterLab_20190208_breakfast_rep5.mat','data');

% subplot(n,1,7); plot(t, data(8,:)); ylim([0 5])
% subplot(8,1,8); plot(t, data(9,:)); ylim([0 5])
%figure; subplot(n,1,1); plot(t, (data(2,:)-2.5).^2);
%subplot(n,1,2); plot(t, (data(3, :)-2.5).^2); 
%subplot(n,1,3); plot(t, (data(4, :)-2.5).^2); 
%subplot(n,1,4); plot(t, (data(5,:)-2.5).^2); 
%subplot(n,1,5); plot(t, (data(6,:)-2.5).^2); 

% figure;plot(t,data(2,:));ylim([0 5])
% 
% signal = data(2, :) - 2.5;
% energy = sum(signal.^2)/length(signal)
% max_val = max(abs(signal))
% 
% signal2 = data(6, :) - 2.5;
% energy2 = sum(signal2.^2)/length(signal2)
% max_val2 = max(abs(signal2))
% 
% energy_rat = energy/energy2
% max_val_rat = max_val/max_val2

% for i=2:size(data(:,1),1)
%     data(i,:)=data(i,:)-mean(data(i,:));
% end
% 
% freq=25600*(0:(length(data(2,:))-1))/length(data(2,:));
% 
% figure;subplot(3,1,1);plot(freq,abs(fft(data(2,:))));xlim([0 300]);
% subplot(3,1,2);plot(freq,abs(fft(data(3,:))));xlim([0 300]);
% subplot(3,1,3);plot(freq,abs(fft(data(4,:))));xlim([0 300]);
