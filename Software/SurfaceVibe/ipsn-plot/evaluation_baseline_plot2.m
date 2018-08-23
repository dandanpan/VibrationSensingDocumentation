clear all
close all
clc

init();
load('./swipe_results/compare_material_winit.mat');

% load('data/drive/swipe_results/compare_material_winit.mat');
evaluationWinit = evaluation; % rename data
clear evaluation;

load('./swipe_results/compare_material.mat');
evaluation; % keep variable name

sNum = size(evaluation,1);
dNum = size(evaluation,2);
eNum = size(evaluation,3);

angleErrors = cell(4, 1);
lengthErrors = cell(4, 1);
distanceErrors = cell(4, 1);

% undamped
for conditionIdx = 1
    angE = ones(12,8) * NaN;
    lenE = ones(12,8) * NaN;
    distE = ones(12,8) * NaN;
    for sIdx = 1 % there are 5 different surfaces
        for directionIdx = 1:8
            for eventIdx = 1:12
                if ~isempty(evaluation{sIdx, directionIdx, eventIdx})
                    angE(eventIdx, directionIdx) = evaluation{sIdx, directionIdx, eventIdx}.angleError;
                    lenE(eventIdx, directionIdx) = evaluation{sIdx, directionIdx, eventIdx}.lengthError;
                    distE(eventIdx, directionIdx) = mean(evaluation{sIdx, directionIdx, eventIdx}.distances);
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
    angE = ones(12,8) * NaN;
    lenE = ones(12,8) * NaN;
    distE = ones(12,8) * NaN;
    for sIdx = 2 % there are 5 different surfaces
        for directionIdx = 1:8
            for eventIdx = 1:12
                if ~isempty(evaluation{sIdx, directionIdx, eventIdx})
                    angE(eventIdx, directionIdx) = evaluation{sIdx, directionIdx, eventIdx}.angleError;
                    lenE(eventIdx, directionIdx) = evaluation{sIdx, directionIdx, eventIdx}.lengthError;
                    distE(eventIdx, directionIdx) = mean(evaluation{sIdx, directionIdx, eventIdx}.distances);
                end
            end
        end
    end
    angleErrors{conditionIdx} = angE;
    lengthErrors{conditionIdx} = lenE;
    distanceErrors{conditionIdx} = distE;
end

% undamped winit
for conditionIdx = 3
    angE = ones(12,8) * NaN;
    lenE = ones(12,8) * NaN;
    distE = ones(12,8) * NaN;
    for sIdx = 1 % there are 5 different surfaces
        for directionIdx = 1:8
            for eventIdx = 1:12
                if ~isempty(evaluationWinit{sIdx, directionIdx, eventIdx})
                    angE(eventIdx, directionIdx) = evaluationWinit{sIdx, directionIdx, eventIdx}.angleError;
                    lenE(eventIdx, directionIdx) = evaluationWinit{sIdx, directionIdx, eventIdx}.lengthError;
                    distE(eventIdx, directionIdx) = mean(evaluationWinit{sIdx, directionIdx, eventIdx}.distances);
                end
            end
        end
    end
    angleErrors{conditionIdx} = angE;
    lengthErrors{conditionIdx} = lenE;
    distanceErrors{conditionIdx} = distE;
end

% damped winit
for conditionIdx = 4
    angE = ones(12,8) * NaN;
    lenE = ones(12,8) * NaN;
    distE = ones(12,8) * NaN;
    for sIdx = 2 % there are 5 different surfaces
        for directionIdx = 1:8
            for eventIdx = 1:12
                if ~isempty(evaluationWinit{sIdx, directionIdx, eventIdx})
                    angE(eventIdx, directionIdx) = evaluationWinit{sIdx, directionIdx, eventIdx}.angleError;
                    lenE(eventIdx, directionIdx) = evaluationWinit{sIdx, directionIdx, eventIdx}.lengthError;
                    distE(eventIdx, directionIdx) = mean(evaluationWinit{sIdx, directionIdx, eventIdx}.distances);
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
aboxplot(lengthErrors(1:2));
xlabel('Direction (degrees)');
ylabel('Error (cm)');
title('Length Error');
hold on;
plot([0 sNum+1], [0 0], 'r--');
set(gca,'XTickLabel',{'0','45','90','135','180','225','270','315'});

aa = lengthErrors{1};
mean(aa(~isnan(aa)))
aa = lengthErrors{2};
mean(aa(~isnan(aa)))

subplot(3,1,2);
aboxplot(angleErrors(1:2));
xlabel('Direction (degrees)');
ylabel('Error (degrees)');
title('Angle Error');
hold on;
plot([0 sNum+1], [0 0], 'r--');
set(gca,'XTickLabel',{'0','45','90','135','180','225','270','315'});

aa = angleErrors{1};
mean(aa(~isnan(aa)))
std(aa(~isnan(aa)))
aa = angleErrors{2};
mean(aa(~isnan(aa)))
std(aa(~isnan(aa)))

subplot(3,1,3);
aboxplot(distanceErrors(1:2));
xlabel('Direction (degrees)');
ylabel('Error (cm)');
title('Trajectory Error');
hold on;
plot([0 sNum+1], [0 0], 'r--');
set(gca,'XTickLabel',{'0','45','90','135','180','225','270','315'});

%% calculate damp undamped difference: d damped, u undamped
angleErrorD = [angleErrors{2}(~isnan(angleErrors{2})); angleErrors{4}(~isnan(angleErrors{4}))];
angleErrorU = [angleErrors{1}(~isnan(angleErrors{1})); angleErrors{3}(~isnan(angleErrors{3}))];
mean(angleErrorD)
std(angleErrorD)
mean(angleErrorU)
std(angleErrorU)


lengthErrorD = [lengthErrors{2}(~isnan(lengthErrors{2})); lengthErrors{4}(~isnan(lengthErrors{4}))];
lengthErrorU = [lengthErrors{1}(~isnan(lengthErrors{1})); lengthErrors{3}(~isnan(lengthErrors{3}))];

mean(lengthErrorD)
std(lengthErrorD)
mean(lengthErrorU)
std(lengthErrorU)

distanceErrorD = [distanceErrors{2}(~isnan(distanceErrors{2})); distanceErrors{4}(~isnan(distanceErrors{4}))];
distanceErrorU = [distanceErrors{1}(~isnan(distanceErrors{1})); distanceErrors{3}(~isnan(distanceErrors{3}))];

mean(distanceErrorD)
std(distanceErrorD)
mean(distanceErrorU)
std(distanceErrorU)

%% polar plots
figure;

angles = deg2rad(0:45:360);

% cases:
% 1 - undamped
% 2 - damped
% 3 - undamped winit
% 4 - damped winit

lineSpec{1} = '-o';
lineSpec{2} = '-x';
lineSpec{3} = '--s';
lineSpec{4} = '--d';

for caseIdx = 1:4
    % get the mean length error and std dev
    cmean = nanmean(lengthErrors{caseIdx});
    cstd = nanstd(lengthErrors{caseIdx});
    
    % loop around to full circle
    cmean = [cmean cmean(1)];
    cstd = [cstd cstd(1)];
    
    h = polar(angles, abs(cmean),lineSpec{caseIdx});
    set(h,{'markers'},{10})  
    hold on;
end
view(90, -90);

legend('Undamped', 'Damped', 'Undamped w/ Initial Tap', 'Damped w/ Initial Tap');

