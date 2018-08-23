%  import to check
clear all
close all
clc

listing = dir('./Anchor1/copyFromPi/Footstep/');
count = 0;
for i = 1 : length(listing)
    if sum(ismember(listing(i).name,'txtout')) == 9
        count = count + 1;
        signal1{count} = importdata(['./Anchor1/copyFromPi/Footstep/' listing(i).name]);
    end
end

listing = dir('./Anchor2/copyFromPi/Footstep/');
count = 0;
for i = 1 : length(listing)
    if sum(ismember(listing(i).name,'txtout')) == 9
        count = count + 1;
        signal2{count} = importdata(['./Anchor2/copyFromPi/Footstep/' listing(i).name]);
    end
end

listing = dir('./Anchor3/copyFromPi/Footstep/');
count = 0;
for i = 1 : length(listing)
    if sum(ismember(listing(i).name,'txtout')) == 9
        count = count + 1;
        signal3{count} = importdata(['./Anchor3/copyFromPi/Footstep/' listing(i).name]);
    end
end

% listing = dir('./Anchor4/copyFromPi/Footstep/');
% count = 0;
% for i = 1 : length(listing)
%     if sum(ismember(listing(i).name,'txtout')) == 9
%         count = count + 1;
%         signal4{i} = importdata(['./Anchor4/copyFromPi/Footstep/' listing(i).name]);
% %         figure; plot(signal2{i});
% %         title('Anchor3');
%         if count == 2
%             break;
%         end
%     end
% end
s1 = [];
for i = 1 : length(signal1)
    s1 = [s1; signal1{i}];
end
s2 = [];
for i = 1 : length(signal2)
    s2 = [s2; signal2{i}];
end
s3 = [];
for i = 1 : length(signal3)
    s3 = [s3; signal3{i}];
end
% s4 = [signal2{4}; signal2{6}];
timestamp1 = s1(s1>10000);
timestampIdx1 = find(s1>10000);
timestamp2 = s2(s2>10000);
timestampIdx2 = find(s2>10000);
timestamp3 = s3(s3>10000);
timestampIdx3 = find(s3>10000);
% timestamp4 = s4(s4>10000);
% timestampIdx4 = find(s4>10000);

% sensor 1
deltaTime = timestamp1(2:end)-timestamp1(1:end-1);
deltaTimeIdx = timestampIdx1(2:end)-timestampIdx1(1:end-1);
timeEva = deltaTime./deltaTimeIdx/10^11;

% sensor 2
deltaTime = timestamp2(2:end)-timestamp2(1:end-1);
deltaTimeIdx = timestampIdx2(2:end)-timestampIdx2(1:end-1);
timeEva = deltaTime./deltaTimeIdx/10^11;
deltaVal = mean(timeEva(timeEva < 1.5));
errorIdx = find(timeEva >= 1.5);
placeHolderLen = calculatePlaceHoldLen( deltaTime, deltaTimeIdx, deltaVal, errorIdx );
s2 = insertTimePlaceHolder( s2, timestampIdx2(errorIdx+1)-1, placeHolderLen );

% sensor 3
deltaTime = timestamp3(2:end)-timestamp3(1:end-1);
deltaTimeIdx = timestampIdx3(2:end)-timestampIdx3(1:end-1);
timeEva = deltaTime./deltaTimeIdx/10^11;
deltaVal = mean(timeEva(timeEva < 1.5));
errorIdx = find(timeEva >= 1.5);
placeHolderLen = calculatePlaceHoldLen( deltaTime, deltaTimeIdx, deltaVal, errorIdx );
s3 = insertTimePlaceHolder( s3, timestampIdx3(errorIdx+1)-1, placeHolderLen );

unifiedTime = round([timestamp1; timestamp2; timestamp3]./10^16);
unifiedTime = unique(unifiedTime);

%% alignment
% extract signal between each timestamp
dIdx = (s1 == 10000);
dIdx2 = [0; dIdx(1:end-1)];

distance1 = s1.*(dIdx2);
d1 = distance1(distance1>0);
d1Idx = find(distance1>0);
d{1,1} = [];
d{1,2} = [];
for i = 1 : 2 : length(d1)
    if d1(i) == 11
        d{1,1} = [d{1,1}; d1Idx(i+1) d1(i+1)];
    elseif d1(i) == 12
        d{1,2} = [d{1,2}; d1Idx(i+1) d1(i+1)];
    end
end

dIdx = (s2 == 10000);
dIdx2 = [0; dIdx(1:end-1)];
distance2 = s2.*(dIdx2);
d2 = distance2(distance2>0);
d2Idx = find(distance2>0);
d{2,1} = [];
d{2,2} = [];
for i = 1 : 2 : length(d2)
    if d2(i) == 11
        d{2,1} = [d{2,1}; d2Idx(i+1) d2(i+1)];
    elseif d2(i) == 12
        d{2,2} = [d{2,2}; d2Idx(i+1) d2(i+1)];
    end
end

dIdx = (s3 == 10000);
dIdx2 = [0; dIdx(1:end-1)];
distance3 = s3.*(dIdx2);
d3 = distance3(distance3>0);
d3Idx = find(distance3>0);
d{3,1} = [];
d{3,2} = [];
for i = 1 : 2 : length(d3)
    if d3(i) == 11
        d{3,1} = [d{3,1}; d3Idx(i+1) d3(i+1)];
    elseif d3(i) == 12
        d{3,2} = [d{3,2}; d3Idx(i+1) d3(i+1)];
    end
end

figure;
plot(d{1,1}(:,1),d{1,1}(:,2));hold on;
plot(d{2,1}(:,1),d{2,1}(:,2));hold on;
plot(d{3,1}(:,1),d{3,1}(:,2));hold off;

figure;
plot(d{1,2}(:,1),d{1,2}(:,2));hold on;
plot(d{2,2}(:,1),d{2,2}(:,2));hold on;
plot(d{3,2}(:,1),d{3,2}(:,2));hold off;

% figure;
% plot(distance1(distance1<10));
% 
figure;
plot(s1);
hold on;
plot(s2);
hold on;
plot(s3);
hold off;
