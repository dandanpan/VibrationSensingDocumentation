clear all
close all
clc

%% example
% load('tile16-tap-results-noncali2.mat');
% load('tap_ground_truth.mat');
% figure;
% for locIdx = 1:16
%     scatter(pointsAll{locIdx}(:,1),pointsAll{locIdx}(:,2));hold on;
%     meanPoint = mean(pointsAll{locIdx});
%     plot([GT{locIdx}(1), meanPoint(1)],[GT{locIdx}(2), meanPoint(2)],'k');hold on;
% end
% hold off;
% axis equal;
% grid on;
% xlim([-10,50]);
% ylim([-10,50]);

%% statistics
locErr = [];
for mIdx = 1:5
    precisionErr{mIdx} = [];
end
load('data/drive/loc_results/wood24-tap-results.mat');
locErr = [locErr; mean(estErr), std(estErr)];
for locIdx = 1:16
    meanTdoa = mean(pointsAll{locIdx});
    tempErr = [];
    for eIdx = 1:size(pointsAll{locIdx},1)
        tempErr = [tempErr, sqrt(sum((pointsAll{locIdx}(eIdx,:)-meanTdoa).^2))];
    end
    precisionErr{1} = [precisionErr{1} tempErr];
end
load('data/drive/loc_results/tile16-tap-results.mat');
locErr = [locErr; mean(estErr), std(estErr)];
for locIdx = 1:16
    meanTdoa = mean(pointsAll{locIdx});
    tempErr = [];
    for eIdx = 1:size(pointsAll{locIdx},1)
        tempErr = [tempErr, sqrt(sum((pointsAll{locIdx}(eIdx,:)-meanTdoa).^2))];
    end
    precisionErr{2} = [precisionErr{2} tempErr];
end
load('data/drive/loc_results/iron24-tap-results.mat');
locErr = [locErr; mean(estErr), std(estErr)];
for locIdx = 1:16
    meanTdoa = mean(pointsAll{locIdx});
    tempErr = [];
    for eIdx = 1:size(pointsAll{locIdx},1)
        tempErr = [tempErr, sqrt(sum((pointsAll{locIdx}(eIdx,:)-meanTdoa).^2))];
    end
    precisionErr{3} = [precisionErr{3} tempErr];
end
load('data/drive/loc_results/cement24-tap-results.mat');
locErr = [locErr; mean(estErr), std(estErr)];
for locIdx = 1:16
    meanTdoa = mean(pointsAll{locIdx});
    tempErr = [];
    for eIdx = 1:size(pointsAll{locIdx},1)
        tempErr = [tempErr, sqrt(sum((pointsAll{locIdx}(eIdx,:)-meanTdoa).^2))];
    end
    precisionErr{4} = [precisionErr{4} tempErr];
end
load('data/drive/loc_results/stone24-tap-results.mat');
locErr = [locErr; mean(estErr), std(estErr)];
for locIdx = 1:16
    meanTdoa = mean(pointsAll{locIdx});
    tempErr = [];
    for eIdx = 1:size(pointsAll{locIdx},1)
        tempErr = [tempErr, sqrt(sum((pointsAll{locIdx}(eIdx,:)-meanTdoa).^2))];
    end
    precisionErr{5} = [precisionErr{5} tempErr];
end
pErr = [];
for idx = 1:5
    pErr = [pErr; mean(precisionErr{idx}), std(precisionErr{idx})];
end

figure;
bar(1:5,[locErr(:,1),pErr(:,1)]);hold on;
% errorbar(1:5,locErr(:,1),locErr(:,2),'.');hold on;
plot([0.5,5.5],[10,10],'r--');
ylim([0,12]);
set(gca,'XTickLabel',{' wood ',' tile ',' iron ','cement',' stone'});
ylabel('Localization Error (cm)');
legend('accuracy','precision','grid size');
