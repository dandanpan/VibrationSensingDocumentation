clear
% close all
% clc

filenames{1} = '../loc_results/wood16-tap-results.mat';
filenames{2} = '../loc_results/wood24-tap-results.mat';
filenames{3} = '../loc_results/wood32-tap-results.mat';
filenames{4} = '../loc_results/wood40-tap-results.mat';
mNum = length(filenames);
% figure;
locErr = [];
for mIdx = 1:mNum
    load(filenames{mIdx});
    locErr = [locErr; mean(estErr), std(estErr)];
end
% subplot(2,1,1);
% bar([1:mNum],locErr(:,1));hold on;
errorbar([1:mNum],locErr(:,1),locErr(:,2));hold on;
% set(gca,'XTickLabel',{'Size B1','Baseline','Size B2','Size B3'});
% ylim([0,10]);

pErr = [];
for mIdx = 1:mNum
    load(filenames{mIdx});
    precisionErr{mIdx} = [];
    for locIdx = 1:16
        meanTdoa = mean(pointsAll{locIdx});
        tempErr = [];
        for eIdx = 1:size(pointsAll{locIdx},1)
            tempErr = [tempErr, sqrt(sum((pointsAll{locIdx}(eIdx,:)-meanTdoa).^2))];
        end
        precisionErr{mIdx} = [precisionErr{mIdx} tempErr];
    end
    pErr = [pErr; mean(precisionErr{mIdx}), std(precisionErr{mIdx})];
end
% subplot(2,1,2);
% bar([1:mNum],pErr(:,1));hold on;
errorbar([1:mNum],pErr(:,1),pErr(:,2));
set(gca,'XTickLabel',{' 41',' 61',' 81','101'});
% set(gca,'XTickLabel',{'Size B1','Baseline','Size B2','Size B3'});
ylim([0,10]);
xlabel('Board Size (B = x cm)');
legend('Localization Error', 'Precision');