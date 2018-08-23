clear all
close all
clc

load('compare_weight.mat');

%scenarios:
% 1 - bar1
% 2 - bar2
% 3 - bar3
% 4 - bar4

sNum = size(evaluation,1);
dNum = size(evaluation,2);
eNum = size(evaluation,3);

angleErrors = cell(sNum, 1);
lengthErrors = cell(sNum, 1);
distanceErrors = cell(sNum, 1);

for scenarioIdx = 1:sNum
   angE = ones(eNum, dNum) * NaN;
   lenE = ones(eNum, dNum) * NaN;
   distE = ones(eNum, dNum) * NaN;

   for directionIdx = 1:dNum
       for eventIdx = 1:eNum
            if ~isempty(evaluation{scenarioIdx, directionIdx, eventIdx})
                angE(eventIdx, directionIdx) = evaluation{scenarioIdx, directionIdx, eventIdx}.angleError;
                lenE(eventIdx, directionIdx) = evaluation{scenarioIdx, directionIdx, eventIdx}.lengthError;
                distE(eventIdx, directionIdx) = mean(evaluation{scenarioIdx, directionIdx, eventIdx}.distances);
            end
       end
   end
   angleErrors{scenarioIdx} = angE;
   lengthErrors{scenarioIdx} = lenE;
   distanceErrors{scenarioIdx} = distE;
end

h = figure;

subplot(3,1,1);
aboxplot(angleErrors);
xlabel('Weight');
ylabel('Error (Degrees)');
title('Angle Error');
hold on;
plot([0 dNum+1], [0 0], 'r--');

subplot(3,1,2);
aboxplot(lengthErrors);
xlabel('Weight');
ylabel('Error (cm)');
title('Length Error');
hold on;
plot([0 dNum+1], [0 0], 'r--');

subplot(3,1,3);
aboxplot(distanceErrors);
xlabel('Weight');
ylabel('Error (cm)');
title('Trajectory Error');
hold on;
plot([0 dNum+1], [0 0], 'r--');

%% bargraph
figure;
angleErrorStat = [];
for sIdx = 1:4
    angleErrorStat = [angleErrorStat; mean(angleErrors{sIdx}(~isnan(angleErrors{sIdx}))), ...
        std(angleErrors{sIdx}(~isnan(angleErrors{sIdx})))];
end
subplot(1,3,2);
bar([1:4],angleErrorStat(:,1));hold on;
errorbar([1:4],angleErrorStat(:,1),angleErrorStat(:,2),'.');
set(gca,'XTickLabel',{'bar1','bar2','bar3','bar4'});
ylabel('Error (Degrees)');
title('Angle Error');
hold on;
plot([0 5], [0 0], 'r--');

lengthErrorStat = [];
for sIdx = 1:4
    lengthErrorStat = [lengthErrorStat; mean(lengthErrors{sIdx}(~isnan(lengthErrors{sIdx}))), ...
        std(lengthErrors{sIdx}(~isnan(lengthErrors{sIdx})))];
end
subplot(1,3,1);
bar([1:4],lengthErrorStat(:,1));hold on;
errorbar([1:4],lengthErrorStat(:,1),lengthErrorStat(:,2),'.');
set(gca,'XTickLabel',{'bar1','bar2','bar3','bar4'});
ylabel('Error (cm)');
title('Length Error');hold on;
plot([0 5], [0 0], 'r--');


distErrorStat = [];
for sIdx = 1:4
    distErrorStat = [distErrorStat; mean(distanceErrors{sIdx}(~isnan(distanceErrors{sIdx}))), ...
        std(distanceErrors{sIdx}(~isnan(distanceErrors{sIdx})))];
end
subplot(1,3,3);
bar([1:4],distErrorStat(:,1));hold on;
errorbar([1:4],distErrorStat(:,1),distErrorStat(:,2),'.');
set(gca,'XTickLabel',{'bar1','bar2','bar3','bar4'});
ylabel('Error (cm)');
title('Trajectory Error');
xlabel('Swipe Length')
hold on;
plot([0 5], [0 0], 'r--');hold off;
