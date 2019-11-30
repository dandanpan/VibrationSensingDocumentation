close all, clear all

color1=[0, 0.4470, 0.7410;0.9290, 0.6940, 0.1250];
color2=[0.6350, 0.0780, 0.1840];
channels=4;
load('example_om.mat');
t=1:size(data,2);
T=25600;
t=t/25600;
mag=0.6;
colorstring = 'bgrk';
figure(1);
% subplot(1,5,1);
for i=1:2
    color=color1(i,:);
    plot(t,data(i,:),'Color',color);
    set(gca,'YTick',-mag:mag:mag);
    hold on
end
mag=0.5;
for i=1:length(real_peaks)
        rectangle('Position',[real_peaks(1,i)/T,-mag,...
            real_peaks(2,i)/T-real_peaks(1,i)/T,2*mag],'EdgeColor',color2,'LineWidth', 1);
end
title('MOVS detection results');
xlabel('time (s)');
ylabel(' Amplitude');
title('Raw signal of two sensors');
xlabel('time (s)');
ylabel(' Amplitude');



% om
subplot(1,5,2)
for i=1:2
    color=color1(i,:);
    plot(t,reconstruct_signal(i,:),'Color',color);
    set(gca,'YTick',-mag:mag:mag);
    hold on
end


mag=max(max(abs(reconstruct_signal)));
for i=1:length(real_peaks)
        rectangle('Position',[real_peaks(1,i)/T,-mag,...
            real_peaks(2,i)/T-real_peaks(1,i)/T,2*mag],'EdgeColor',color2,'LineWidth', 1);
end
title('MOVS detection results');
xlabel('time (s)');
ylabel(' Amplitude');

%1
load('example_base1.mat');
subplot(1,5,3);
mag=0.6;
for i=1:2
    color=color1(i,:);
    plot(t,data(i,:),'Color',color);
    set(gca,'YTick',-mag:mag:mag);
    hold on
end
mag=0.4;
for i=1:1
        rectangle('Position',[stepStartIdxArray(i)/T,-mag,...
            stepStopIdxArray(i)/T-stepStartIdxArray(i)/T,2*mag],'EdgeColor',color2,'LineWidth', 1);
end
title('1-th Baseline detection results');
xlabel('time (s)');
ylabel(' Amplitude');

% 2
load('example_base2.mat');
subplot(1,5,4);
for i=1:2
    color=color1(i,:);
    plot(t,reconstruct_signal(i,:),'Color',color);
    set(gca,'YTick',-mag:mag:mag);
    hold on
end


mag=max(max(abs(reconstruct_signal)));
for i=1:length(stepStartIdxArray)
        rectangle('Position',[stepStartIdxArray(i)/T,-mag,...
            stepStopIdxArray(i)/T-stepStartIdxArray(i)/T,2*mag],'EdgeColor',color2,'LineWidth', 1);
end
title('2-th Baseline detection results');
xlabel('time (s)');
ylabel(' Amplitude');

% 3
load('example_base3.mat');
subplot(1,5,5);
for i=1:2
    color=color1(i,:);
    plot(t,reconstruct_signal(i,:),'Color',color);
    set(gca,'YTick',-mag:mag:mag);
    hold on
end


mag=max(max(abs(reconstruct_signal)));
for i=1:length(stepStartIdxArray)
        rectangle('Position',[stepStartIdxArray(i)/T,-mag,...
            stepStopIdxArray(i)/T-stepStartIdxArray(i)/T,2*mag],'EdgeColor',color2,'LineWidth', 1);
end
title('3-th Baseline detection results');
xlabel('time (s)');
ylabel(' Amplitude');