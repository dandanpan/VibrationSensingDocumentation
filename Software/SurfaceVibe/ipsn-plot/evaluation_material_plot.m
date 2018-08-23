clear all
close all
clc

init();

load('./swipe_results/compare_material_winit.mat');
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
    angE = ones(8*12,5) * NaN;
    lenE = ones(8*12,5) * NaN;
    distE = ones(8*12,5) * NaN;
    s = [1 3 5 7 9];
    for surfaceIdx = 1:5 % there are 5 different surfaces
        sIdx = s(surfaceIdx);
        for directionIdx = 1:8
            for eventIdx = 1:12
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
    angE = ones(8*12,5) * NaN;
    lenE = ones(8*12,5) * NaN;
    distE = ones(8*12,5) * NaN;
    s = [2 4 6 8 10];
    for surfaceIdx = 1:5 % there are 5 different surfaces
        sIdx = s(surfaceIdx);
        for directionIdx = 1:8
            for eventIdx = 1:12
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

% undamped winit
for conditionIdx = 3
    angE = ones(8*12,5) * NaN;
    lenE = ones(8*12,5) * NaN;
    distE = ones(8*12,5) * NaN;
    s = [1 3 5 7 9];
    for surfaceIdx = 1:5 % there are 5 different surfaces
        sIdx = s(surfaceIdx);
        for directionIdx = 1:8
            for eventIdx = 1:12
                if ~isempty(evaluationWinit{sIdx, directionIdx, eventIdx})
                    angE(eventIdx + (directionIdx-1)*12, surfaceIdx) = evaluationWinit{sIdx, directionIdx, eventIdx}.angleError;
                    lenE(eventIdx + (directionIdx-1)*12, surfaceIdx) = evaluationWinit{sIdx, directionIdx, eventIdx}.lengthError;
                    distE(eventIdx + (directionIdx-1)*12, surfaceIdx) = mean(evaluationWinit{sIdx, directionIdx, eventIdx}.distances);
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
    angE = ones(8*12,5) * NaN;
    lenE = ones(8*12,5) * NaN;
    distE = ones(8*12,5) * NaN;
    s = [2 4 6 8 10];
    for surfaceIdx = 1:5 % there are 5 different surfaces
        sIdx = s(surfaceIdx);
        for directionIdx = 1:8
            for eventIdx = 1:12
                if ~isempty(evaluationWinit{sIdx, directionIdx, eventIdx})
                    angE(eventIdx + (directionIdx-1)*12, surfaceIdx) = evaluationWinit{sIdx, directionIdx, eventIdx}.angleError;
                    lenE(eventIdx + (directionIdx-1)*12, surfaceIdx) = evaluationWinit{sIdx, directionIdx, eventIdx}.lengthError;
                    distE(eventIdx + (directionIdx-1)*12, surfaceIdx) = mean(evaluationWinit{sIdx, directionIdx, eventIdx}.distances);
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

%% calculate the statistics of the four different scenario comparision
% angle
uae = [angleErrors{1}];%; angleErrors{3}];
uae4 = uae(:,1:4);
meanUndampedAngleError = mean(uae(~isnan(uae)));
meanUndampedAngle4Error = mean(uae4(~isnan(uae4)));
stdUndampedAngleError = std(uae(~isnan(uae)));
stdUndampedAngle4Error = std(uae4(~isnan(uae4)));
dae = [angleErrors{4}];%; angleErrors{2}];
dae4 = dae(:,1:4);
meanDampedAngleError = mean(dae(~isnan(dae)));
meanDampedAngle4Error = mean(dae4(~isnan(dae4)));
stdDampedAngleError = std(dae(~isnan(dae)));
stdDampedAngle4Error = std(dae4(~isnan(dae4)));

nae = [angleErrors{1}; angleErrors{2}];
meanNonInitAngleError = mean(nae(~isnan(nae)));
stdNonInitAngleError = std(nae(~isnan(nae)));
iae = [angleErrors{3}; angleErrors{4}];
meanInitAngleError = mean(iae(~isnan(iae)));
stdInitAngleError = std(iae(~isnan(iae)));

% length
uae = [lengthErrors{1}];%; lengthErrors{3}];
uae4 = uae(:,1:4);
meanUndampedLengthError = mean(uae(~isnan(uae)));
meanUndampedLength4Error = mean(uae4(~isnan(uae4)));
dae = [lengthErrors{4}];%; lengthErrors{2}];
dae4 = dae(:,1:4);
meanDampedLengthError = mean(dae(~isnan(dae)));
meanDampedLength4Error = mean(dae4(~isnan(dae4)));

nae = [lengthErrors{1}; lengthErrors{2}];
meanNonInitLengthError = mean(nae(~isnan(nae)));
iae = [lengthErrors{3}; lengthErrors{4}];
meanInitLengthError = mean(iae(~isnan(iae)));

% distance
uae = [distanceErrors{1}; distanceErrors{3}];
meanUndampedDistError = mean(uae(~isnan(uae)));
dae = [distanceErrors{2}; distanceErrors{4}];
meanDampedDistError = mean(dae(~isnan(dae)));

nae = [distanceErrors{1}; distanceErrors{2}];
meanNonInitDistError = mean(nae(~isnan(nae)));
iae = [distanceErrors{3}; distanceErrors{4}];
meanInitDistError = mean(iae(~isnan(iae)));


%%
figure;
subplot(2,1,1);
aboxplot(lengthErrors([1,4]));
xlabel('Scenario');
ylabel('Error (cm)');
title('Length Error');
hold on;
plot([0 sNum+1], [0 0], 'r--');
set(gca,'XTickLabel',{' wood ',' iron ','cement',' stone',' tile '});

subplot(2,1,2);
aboxplot(angleErrors([1,4]));
xlabel('Scenario');
ylabel('Error (Degrees)');
title('Angle Error');
hold on;
plot([0 sNum+1], [0 0], 'r--');
set(gca,'XTickLabel',{' wood ',' iron ','cement',' stone',' tile '});

% 
% subplot(3,1,3);
% aboxplot(distanceErrors([1,4]));
% xlabel('Scenario');
% ylabel('Error (cm)');
% title('Trajectory Error');
% hold on;
% plot([0 sNum+1], [0 0], 'r--');


