clear all
close all
clc

load('compare_size.mat');

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
    s = [1 3 5 7];
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
    s = [2 4 6 8];
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
set(gca,'XTickLabel',{'Size B1','Baseline','Size B2','Size B3'});
hold on;
plot([0 sNum+1], [0 0], 'r--');

subplot(3,1,2);
aboxplot(lengthErrors);
xlabel('Size');
ylabel('Error (cm)');
title('Length Error');
set(gca,'XTickLabel',{'Size B1','Baseline','Size B2','Size B3'});
hold on;
plot([0 sNum+1], [0 0], 'r--');

subplot(3,1,3);
aboxplot(distanceErrors);
xlabel('Size');
ylabel('Error (cm)');
set(gca,'XTickLabel',{'Size B1','Baseline','Size B2','Size B3'});
title('Trajectory Error');
hold on;
plot([0 sNum+1], [0 0], 'r--');

%%
lengthErrorsDamp = lengthErrors{2};
ledMean = zeros(1,4);
ledStd = zeros(1,4);
for i = 1:4
    temp = lengthErrorsDamp(:,i);
    ledMean(i) = mean(temp(~isnan(temp)));
    ledStd(i) = std(temp(~isnan(temp)));
end

angleErrorsDamp = angleErrors{2};
aedMean = zeros(1,4);
aedStd = zeros(1,4);
for i = 1:4
    temp = angleErrorsDamp(:,i);
    aedMean(i) = mean(temp(~isnan(temp)));
    aedStd(i) = std(temp(~isnan(temp)));
end

distErrorsDamp = distanceErrors{2};
dedMean = zeros(1,4);
dedStd = zeros(1,4);
for i = 1:4
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
set(gca,'XTickLabel',{'41','61','81','102'});
hold on;
plot([0.5 4.5], [0 0], 'r--');

subplot(3,1,2);
errorbar(aedMean,aedStd);
xlabel('Size');
ylabel('Error (degree)');
title('Angle Error');
set(gca,'XTickLabel',{'41','61','81','102'});
hold on;
plot([0.5 4.5], [0 0], 'r--');

subplot(3,1,3);
errorbar(dedMean,dedStd);
xlabel('Size');
ylabel('Error (cm)');
set(gca,'XTickLabel',{'41','61','81','102'});
title('Trajectory Error');
hold on;
plot([0.5 4.5], [0 0], 'r--');


%%
undampenAngle = angleErrors{1};
dampenAngle = angleErrors{2};
undampenAngle = undampenAngle(:,[4]);
dampenAngle = dampenAngle(:,[4]);
% undampenLength = undampenLength(:,[2,4]);
% dampenLength = dampenLength(:,[2,4]);
mean(undampenAngle(~isnan(undampenAngle)));
mean(dampenAngle(~isnan(dampenAngle)))
std(undampenAngle(~isnan(undampenAngle)));
std(dampenAngle(~isnan(dampenAngle)))

mean([dampenAngle(~isnan(dampenAngle)); undampenAngle(~isnan(undampenAngle))]);
std([dampenAngle(~isnan(dampenAngle)); undampenAngle(~isnan(undampenAngle))]);

undampenLength = lengthErrors{1};
dampenLength = lengthErrors{2};
undampenLength = undampenLength(:,[4]);
dampenLength = dampenLength(:,[4]);
% undampenLength = undampenLength(:,[2,4]);
% dampenLength = dampenLength(:,[2,4]);
mean(undampenLength(~isnan(undampenLength)));
mean(dampenLength(~isnan(dampenLength)))
std(undampenLength(~isnan(undampenLength)));
std(dampenLength(~isnan(dampenLength)))

mean([dampenLength(~isnan(dampenLength)); undampenLength(~isnan(undampenLength))]);