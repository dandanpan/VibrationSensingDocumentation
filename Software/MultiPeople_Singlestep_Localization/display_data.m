% The sample frequency is 6500kHz
close all; clear all;
load('../P1.mat');
%load('P1_noise.mat');
load('../P1P2.mat');
load('../P1P2_noise.mat');
channel=8;


%% for noise
figure;
for i=1:channel
    subplot(channel,1,i);
    data=cell2mat(noiseSig(1,i));
    if (isempty(data)~=1)
        plot(data(:,1)/1e6,data(:,2));
    end
end
title('the vibration data of noise');
xlabel('time /s');
ylabel('magnitude');

%% the magnitude
mag=600;
%% for 1 person walking in center
num_expri=1;
figure;
data=cell2mat(P1_center(num_expri,1));
plot(data(:,1)/1e6,data(:,2));
%set(gca,'YTick',-mag:mag:mag);
title('The vibration data of 1 sensors when P1 center');
xlabel('time /s');
ylabel('magnitude');

figure;
title('P1 center the vibration data of 8 sensors');
for i=1:channel
    subplot(channel,1,i);
    data=cell2mat(P1_center(num_expri,i));
    plot(data(:,1)/1e6,data(:,2));
    set(gca,'YTick',-mag:mag:mag);
    xlabel('time /s');
ylabel('magnitude');
end



% %% for 1 person walking in left
% num_expri=2;
% figure;
% title('P1 left the vibration data of 8 sensors');
% for i=1:channel
%     subplot(channel,1,i);
%     data=cell2mat(P1_left(num_expri,i));
%     plot(data(:,1)/1e6,data(:,2));
%      set(gca,'YTick',-mag:mag:mag);
%      xlabel('time /s');
%     ylabel('magnitude');
% end
% 
% %% for 1 person walking in right
% num_expri=2;
% figure;
% title('P1 right the vibration data of 8 sensors');
% for i=1:channel
%     subplot(channel,1,i);
%     data=cell2mat(P1_right(num_expri,i));
%     plot(data(:,1)/1e6,data(:,2));
%      set(gca,'YTick',-mag:mag:mag);
%      xlabel('time /s');
%     ylabel('magnitude');
% end


%% for 2 person 
% %% for noise
% figure;
% for i=1:channel
%     subplot(channel,1,i);
%     data=cell2mat(noiseSig(1,i));
%     if (isempty(data)~=1)
%         plot(data(:,1)/1e6,data(:,2));
%     end
% end
% title('the vibration data of noise');
% xlabel('time /s');
% ylabel('magnitude');



%% for 2 person walking side by side
num_expri=2;
figure(11);
data=cell2mat(P1P2_side(num_expri,1));
plot(data(:,1)/1e6,data(:,2));
%set(gca,'YTick',-mag:mag:mag);
title('The vibration data of 1 sensors when P1P2 side by side ');
xlabel('time /s');
ylabel('magnitude');

figure;
for i=1:channel
    subplot(channel,1,i);
    data=cell2mat(P1P2_side(num_expri,i));
    if (isempty(data)~=1)
        plot(data(:,1)/1e6,data(:,2));
    end
    xlabel('time /s');
    ylabel('magnitude');
end


%% for 2 person walking in follows by 15 meters
num_expri=2;
figure(12);
data=cell2mat(P1P2_follow_5(num_expri,1));
plot(data(:,1)/1e6,data(:,2));
%set(gca,'YTick',-mag:mag:mag);
title('The vibration data of 1 sensors when P1P2 follows');
xlabel('time /s');
ylabel('magnitude');

figure;
for i=1:channel
    subplot(channel,1,i);
    data=cell2mat(P1P2_follow_15(num_expri,i));
    if (isempty(data)~=1)
        plot(data(:,1)/1e6,data(:,2));
    end
    xlabel('time /s');
    ylabel('magnitude');
end

%% for 2 person walking cross
num_expri=2;
figure(13);
data=cell2mat(P1P2_cross_1(num_expri,1));
plot(data(:,1)/1e6,data(:,2));
%set(gca,'YTick',-mag:mag:mag);
title('The vibration data of 1 sensors when P1P2 cross ');
xlabel('time /s');
ylabel('magnitude');

figure;
for i=1:channel
    subplot(channel,1,i);
    data=cell2mat(P1P2_cross_1(num_expri,i));
    if (isempty(data)~=1)
        plot(data(:,1)/1e6,data(:,2));
    end
    xlabel('time /s');
    ylabel('magnitude');
end