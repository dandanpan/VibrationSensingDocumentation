clear all
close all
clc

load('compare_material_winit.mat');

sNum = size(evaluation,1);
dNum = size(evaluation,2);
eNum = size(evaluation,3);

angleErrorAvg = zeros(sNum, dNum);
angleErrorStd = zeros(sNum, dNum);
lengthErrorAvg = zeros(sNum, dNum);
lengthErrorStd = zeros(sNum, dNum);
distanceErrorAvg = zeros(sNum, dNum);
distanceErrorStd = zeros(sNum, dNum);

angleErrors = cell(dNum, 1);
lengthErrors = cell(dNum, 1);
distanceErrors = cell(dNum, 1);

for directionIdx = 1:dNum
    
   angE = ones(eNum, sNum) * NaN;
   lenE = ones(eNum, sNum) * NaN;
   distE = ones(eNum, sNum) * NaN;

   for scenarioIdx = 1:sNum
       for eventIdx = 1:eNum
            if ~isempty(evaluation{scenarioIdx, directionIdx, eventIdx})
                angE(eventIdx, scenarioIdx) = evaluation{scenarioIdx, directionIdx, eventIdx}.angleError;
                lenE(eventIdx, scenarioIdx) = evaluation{scenarioIdx, directionIdx, eventIdx}.lengthError;
                distE(eventIdx, scenarioIdx) = mean(evaluation{scenarioIdx, directionIdx, eventIdx}.distances);
            end
       end
   end
   
   angleErrors{directionIdx} = angE;
   lengthErrors{directionIdx} = lenE;
   distanceErrors{directionIdx} = distE;
   
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

% for scenarioIdx = 1:sNum
%     for directionIdx = 1:dNum
%         % for each event we have a angle, length, traj error
%         tempAngle = [];
%         tempLength = [];
%         tempDistance = [];
%         for eventIdx = 1:eNum
%             if ~isempty(evaluation{scenarioIdx, directionIdx, eventIdx})
%                 tempAngle = [tempAngle, evaluation{scenarioIdx, directionIdx, eventIdx}.angleError];
%                 tempLength = [tempLength, evaluation{scenarioIdx, directionIdx, eventIdx}.lengthError];
%                 tempDistance = [tempDistance, mean(evaluation{scenarioIdx, directionIdx, eventIdx}.distances)];
%             end
%         end
%         angleErrorAvg(scenarioIdx,directionIdx) = mean(tempAngle);
%         angleErrorStd(scenarioIdx,directionIdx) = std(tempAngle);
%         lengthErrorAvg(scenarioIdx,directionIdx) = mean(tempLength);
%         lengthErrorStd(scenarioIdx,directionIdx) = std(tempLength);
%         distanceErrorAvg(scenarioIdx,directionIdx) = mean(tempDistance);
%         distanceErrorStd(scenarioIdx,directionIdx) = std(tempDistance);
%     end
% end
% 
% figure;
% subplot(3,1,1);
% bar(angleErrorAvg);
% subplot(3,1,2);
% bar(lengthErrorAvg);
% subplot(3,1,3);
% bar(distanceErrorAvg);

