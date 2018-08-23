clear all
close all
clc

init();

load('/swipe_results/compare_windowsize_125_2.mat');
evaluation; % keep variable name

sNum = size(evaluation,2);
dNum = size(evaluation,3);
eNum = size(evaluation,4);

angleErrors = cell(2, 1);
lengthErrors = cell(2, 1);
distanceErrors = cell(2, 1);

xNum = 9;
% undamped
for conditionIdx = 1
    angE = ones(8*10,xNum) * NaN;
    lenE = ones(8*10,xNum) * NaN;
    distE = ones(8*10,xNum) * NaN;
%     s = [1 2 5 10 20];%wSize/100
    s = [1 2 5 10 15 20 25 30 35];
    for surfaceIdx = 1:xNum %1:8% there are 5 different surfaces
        sIdx = surfaceIdx;%s(surfaceIdx);%surfaceIdx+1;
        for directionIdx = 1:8
            for eventIdx = 1:10
                if ~isempty(evaluation{conditionIdx, sIdx,  directionIdx, eventIdx})
                    angE(eventIdx + (directionIdx-1)*12, surfaceIdx) = evaluation{conditionIdx, sIdx,  directionIdx, eventIdx}.angleError;
                    lenE(eventIdx + (directionIdx-1)*12, surfaceIdx) = evaluation{conditionIdx, sIdx,  directionIdx, eventIdx}.lengthError;
                    distE(eventIdx + (directionIdx-1)*12, surfaceIdx) = mean(evaluation{conditionIdx, sIdx,  directionIdx, eventIdx}.distances);
                end
            end
        end
    end
    aI = angE < -160;
    angE(aI) = angE(aI)+360;
    angleErrors{conditionIdx} = angE;
    lengthErrors{conditionIdx} = lenE;
    distanceErrors{conditionIdx} = distE;
end

% damped
for conditionIdx = 2
    angE = ones(8*10,xNum) * NaN;
    lenE = ones(8*10,xNum) * NaN;
    distE = ones(8*10,xNum) * NaN;
%     s = [1 2 5 10 20]; %wSize/100
    s = [1 2 5 10 15 20 25 30 35];
    for surfaceIdx = 1:xNum%1:7 % there are 5 different surfaces
        sIdx = s(surfaceIdx);%surfaceIdx+1;
        for directionIdx = 1:8
            for eventIdx = 1:10
                if ~isempty(evaluation{conditionIdx, sIdx, directionIdx, eventIdx})
                    angE(eventIdx + (directionIdx-1)*12, surfaceIdx) = evaluation{conditionIdx, sIdx, directionIdx, eventIdx}.angleError;
                    lenE(eventIdx + (directionIdx-1)*12, surfaceIdx) = evaluation{conditionIdx, sIdx, directionIdx, eventIdx}.lengthError;
                    distE(eventIdx + (directionIdx-1)*12, surfaceIdx) = mean(evaluation{conditionIdx, sIdx, directionIdx, eventIdx}.distances);
                end
            end
        end
    end
    
    aI = angE < -160;
    angE(aI) = angE(aI)+360;
    
    angleErrors{conditionIdx} = angE;
    lengthErrors{conditionIdx} = lenE;
    distanceErrors{conditionIdx} = distE;
end

h = figure;

subplot(3,1,1);
aboxplot(angleErrors);
xlabel('Scenario');
ylabel('Error (Degrees)');
title('Angle Error');
hold on;
plot([0 sNum+1], [0 0], 'r--');

subplot(3,1,2);
aboxplot(lengthErrors);
xlabel('Scenario');
ylabel('Error (cm)');
title('Length Error');
hold on;
plot([0 sNum+1], [0 0], 'r--');

subplot(3,1,3);
aboxplot(distanceErrors);
xlabel('Scenario');
ylabel('Error (cm)');
title('Trajectory Error');
hold on;
plot([0 sNum+1], [0 0], 'r--');


%% calculation
aa1 = angleErrors{1}(:,1);
aa1(isnan(aa1)) = [];
mean(aa1)

aa2 = angleErrors{1}(:,2);
aa2(isnan(aa2)) = [];
mean(aa2)

aa3 = angleErrors{1}(:,3);
aa3(isnan(aa3)) = [];
mean(aa3)

aa4 = angleErrors{1}(:,4);
aa4(isnan(aa4)) = [];
mean(aa4)

aa5 = angleErrors{1}(:,5);
aa5(isnan(aa5)) = [];
mean(aa5)

%% calculation 2
aa1 = distanceErrors{1}(:,1);
aa1(isnan(aa1)) = [];
mean(aa1)

aa2 = distanceErrors{1}(:,2);
aa2(isnan(aa2)) = [];
mean(aa2)

aa3 = distanceErrors{1}(:,3);
aa3(isnan(aa3)) = [];
mean(aa3)

aa4 = distanceErrors{1}(:,4);
aa4(isnan(aa4)) = [];
mean(aa4)

aa5 = distanceErrors{1}(:,5);
aa5(isnan(aa5)) = [];
mean(aa5)

%%
aa1 = lengthErrors{1}(:,1);
aa1(isnan(aa1)) = [];
mean(aa1)

aa2 = lengthErrors{1}(:,2);
aa2(isnan(aa2)) = [];
mean(aa2)

aa3 = lengthErrors{1}(:,3);
aa3(isnan(aa3)) = [];
mean(aa3)

aa4 = lengthErrors{1}(:,4);
aa4(isnan(aa4)) = [];
mean(aa4)

aa5 = lengthErrors{1}(:,5);
aa5(isnan(aa5)) = [];
mean(aa5)
