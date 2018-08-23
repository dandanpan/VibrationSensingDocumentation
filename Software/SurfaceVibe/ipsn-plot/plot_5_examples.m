% clear all
% close all
% clc

%% example
load('data/drive/loc_results/cement24-undamped-tap-results.mat');
load('data/drive/loc_results/tap_ground_truth.mat');

figure;
for i = 2
    for locIdx = 1:16
        scatter(evaluation{i}(locIdx).points(:,1),evaluation{i}(locIdx).points(:,2));hold on;
        meanPoint = mean(evaluation{i}(locIdx).points);
        plot([GT{locIdx}(1), meanPoint(1)],[GT{locIdx}(2), meanPoint(2)],'k');hold on;
    end
    hold off;
    axis equal;
    grid on;
    xlim([-10,50]);
    ylim([-10,50]);
end

load('data/drive/loc_results/cement24-damped-tap-results.mat');
figure;
for locIdx = 1:16
    scatter(pointsAll{locIdx}(:,1),pointsAll{locIdx}(:,2));hold on;
    meanPoint = mean(pointsAll{locIdx});
    plot([GT{locIdx}(1), meanPoint(1)],[GT{locIdx}(2), meanPoint(2)],'k');hold on;
end
hold off;
axis equal;
grid on;
xlim([-10,50]);
ylim([-10,50]);


%%
load('cement24-undamped-tap-results.mat');
figure;
for locIdx = 1:16
    if ~isempty(pointsAll{locIdx})
        scatter(pointsAll{locIdx}(:,1),pointsAll{locIdx}(:,2));hold on;
        if size(pointsAll{locIdx},1) > 1
            meanPoint = mean(pointsAll{locIdx});
            plot([GT{locIdx}(1), meanPoint(1)],[GT{locIdx}(2), meanPoint(2)],'k');hold on;
        else
            plot([GT{locIdx}(1), pointsAll{locIdx}(1)],[GT{locIdx}(2), pointsAll{locIdx}(2)],'k');hold on;
        end
    end
end
hold off;
axis equal;
grid on;
xlim([-10,50]);
ylim([-10,50]);