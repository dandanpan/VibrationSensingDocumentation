clear all
close all
clc

% sOrder = [4,2,3,1]; % non, filter, califilter,calivelocity

sOrder = [4,1]; % non, filter, califilter,calivelocity
filenames{1} = './loc_results/wood24-tap-results-all.mat';
filenames{2} = './loc_results/iron24-tap-results-all.mat';
filenames{3} = './loc_results/cement24-tap-results-all.mat';
filenames{4} = './loc_results/stone24-tap-results-all.mat';
filenames{5} = './loc_results/tile16-tap-results-all.mat';
for mIdx = 1:5
    load(filenames{mIdx});
    for sIdx = 1:2%:4
        errors{mIdx,sIdx} = evaluation{sOrder(sIdx)}(1).error;
        precisionErr{mIdx,sIdx} = [];
        for locIdx = 1:16
            points = evaluation{sOrder(sIdx)}(locIdx).points;
            meanTdoa = mean(points);
            tempErr = [];
            for eIdx = 1:size(points,1)
                tempErr = [tempErr, sqrt(sum((points(eIdx,:)-meanTdoa).^2))];
            end
            precisionErr{mIdx,sIdx} = [precisionErr{mIdx,sIdx} mean(tempErr)];
        end
    end
end

for sIdx = 1:2%:4
    plotResult1{sIdx} = nan(16,5);
    plotResult2{sIdx} = nan(16,5);
    for mIdx = 1:5
        for locIdx = 1:length(errors{mIdx,sIdx})
            plotResult1{sIdx}(locIdx,mIdx) = errors{mIdx,sIdx}(locIdx);
        end
        for locIdx = 1:length(precisionErr{mIdx,sIdx})
            plotResult2{sIdx}(locIdx,mIdx) = precisionErr{mIdx,sIdx}(locIdx);
        end
    end
end

figure;
subplot(2,1,1);
aboxplot(plotResult1);
ylabel('Error (cm)');
title('Localization Error');hold on;
plot([0 6], [0 0], 'r--');
set(gca,'XTickLabel',{' wood ',' iron ','cement',' stone',' tile '});

subplot(2,1,2);
aboxplot(plotResult2);
xlabel('Material Type');
ylabel('Precision (cm)');
title('Precision Error');hold on;
plot([0 6], [0 0], 'r--');
set(gca,'XTickLabel',{' wood ',' iron ','cement',' stone',' tile '});

figure;
aboxplot(plotResult1);
ylabel('Error (cm)');
title('Localization Error');hold on;
plot([0 6], [0 0], 'r--');
set(gca,'XTickLabel',{' wood ',' iron ','cement',' stone',' tile '});

return;

%% mean of the localization accuracy
aa = plotResult1{1};
mean(aa(~isnan(aa)))
aa = plotResult1{2};
mean(aa(~isnan(aa)))
aa = plotResult1{3};
mean(aa(~isnan(aa)))
aa = plotResult1{4};
mean(aa(~isnan(aa)))

%% mean of the localization precision
aa = plotResult2{1};
mean(aa(~isnan(aa)))
aa = plotResult2{2};
mean(aa(~isnan(aa)))
aa = plotResult2{3};
mean(aa(~isnan(aa)))
aa = plotResult2{4};
mean(aa(~isnan(aa)))

