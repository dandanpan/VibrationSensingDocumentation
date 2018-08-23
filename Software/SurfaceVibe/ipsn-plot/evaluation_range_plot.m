clear all
close all
clc

load('data/drive/swipe_results/compare_range.mat');

sNum = size(evaluation,1);
dNum = size(evaluation,2);
eNum = size(evaluation,3);

angleErrors = cell(2, 1);
lengthErrors = cell(2, 1);
distanceErrors = cell(2, 1);

% undamped
for conditionIdx = 1
    angE = ones(8*12,sNum/2) * NaN;
    lenE = ones(8*12,sNum/2) * NaN;
    distE = ones(8*12,sNum/2) * NaN;
    s = [1 3 5 7 9];
    for surfaceIdx = 1:sNum/2 % there are 5 different surfaces
        sIdx = s(surfaceIdx);
        for directionIdx = 1:dNum
            for eventIdx = 1:eNum
                if ~isempty(evaluation{sIdx, directionIdx, eventIdx})
                    angE(eventIdx + (directionIdx-1)*12, surfaceIdx) = evaluation{sIdx, directionIdx, eventIdx}.angleError;
                    lenE(eventIdx + (directionIdx-1)*12, surfaceIdx) = evaluation{sIdx, directionIdx, eventIdx}.lengthError;
                    distE(eventIdx + (directionIdx-1)*12, surfaceIdx) = mean(evaluation{sIdx, directionIdx, eventIdx}.distances);
                end
            end
        end
    end
    angleErrors{conditionIdx} = angE;
    lengthErrors{conditionIdx} = lenE;
    distanceErrors{conditionIdx} = distE;
end

% damped
for conditionIdx = 2
    angE = ones(8*12,sNum/2) * NaN;
    lenE = ones(8*12,sNum/2) * NaN;
    distE = ones(8*12,sNum/2) * NaN;
    s = [2 4 6 8 10];
    for surfaceIdx = 1:sNum/2 % there are 5 different surfaces
        sIdx = s(surfaceIdx);
        for directionIdx = 1:dNum
            for eventIdx = 1:eNum
                if ~isempty(evaluation{sIdx, directionIdx, eventIdx})
                    angE(eventIdx + (directionIdx-1)*12, surfaceIdx) = evaluation{sIdx, directionIdx, eventIdx}.angleError;
                    lenE(eventIdx + (directionIdx-1)*12, surfaceIdx) = evaluation{sIdx, directionIdx, eventIdx}.lengthError;
                    distE(eventIdx + (directionIdx-1)*12, surfaceIdx) = mean(evaluation{sIdx, directionIdx, eventIdx}.distances);
                end
            end
        end
    end
    angleErrors{conditionIdx} = angE;
    lengthErrors{conditionIdx} = lenE;
    distanceErrors{conditionIdx} = distE;
end

h = figure;

subplot(3,1,1);
aboxplot(angleErrors);
% xlabel('Size');
ylabel('Error (Degrees)');
title('Angle Error');
set(gca,'XTickLabel',{'Size B3','Size R1','Size R2'});
hold on;
plot([0 sNum+1], [0 0], 'r--');

subplot(3,1,2);
aboxplot(lengthErrors);
ylabel('Error (cm)');
title('Length Error');
set(gca,'XTickLabel',{'Size B3','Size R1','Size R2'});
hold on;
plot([0 sNum+1], [0 0], 'r--');

subplot(3,1,3);
aboxplot(distanceErrors);
xlabel('Sensor to Sensing Area Distance');
ylabel('Error (cm)');
set(gca,'XTickLabel',{'Size B3','Size R1','Size R2'});
title('Trajectory Error');
hold on;
plot([0 sNum+1], [0 0], 'r--');

%%

lengthErrorsDamp = lengthErrors{2};
ledMean = zeros(1,5);
ledStd = zeros(1,5);
for i = 1:5
    temp = lengthErrorsDamp(:,i);
    ledMean(i) = mean(temp(~isnan(temp)));
    ledStd(i) = std(temp(~isnan(temp)));
end

angleErrorsDamp = angleErrors{2};
aedMean = zeros(1,5);
aedStd = zeros(1,5);
for i = 1:5
    temp = angleErrorsDamp(:,i);
    aedMean(i) = mean(temp(~isnan(temp)));
    aedStd(i) = std(temp(~isnan(temp)));
end

distErrorsDamp = distanceErrors{2};
dedMean = zeros(1,5);
dedStd = zeros(1,5);
for i = 1:5
    temp = distErrorsDamp(:,i);
    dedMean(i) = mean(temp(~isnan(temp)));
    dedStd(i) = std(temp(~isnan(temp)));
end

figure;
subplot(3,1,1);
errorbar(ledMean,ledStd);
% xlabel('Size');
ylabel('Error (cm)');
title('Length Error');
xlabel('Distance between Sensors (cm)');
set(gca,'XTickLabel',{'40','50','60','70','80'});
hold on;
plot([0.5 5.5], [0 0], 'r--');

subplot(3,1,2);
errorbar(aedMean,aedStd);
xlabel('Size');
ylabel('Error (degree)');
title('Angle Error');
xlabel('Distance between Sensors (cm)');
set(gca,'XTickLabel',{'40','50','60','70','80'});
hold on;
plot([0.5 5.5], [0 0], 'r--');

subplot(3,1,3);
errorbar(dedMean,dedStd);
xlabel('Size');
ylabel('Error (cm)');
xlabel('Distance between Sensors (cm)');
set(gca,'XTickLabel',{'40','50','60','70','80'});
title('Trajectory Error');
hold on;
plot([0.5 5.5], [0 0], 'r--');

%% 
% length
uae = [lengthErrors{1}];%; lengthErrors{3}];
meanUndampedLengthError = mean(uae(~isnan(uae)));
dae = [lengthErrors{2}];%; lengthErrors{2}];
meanDampedLengthError = mean(dae(~isnan(dae)));
