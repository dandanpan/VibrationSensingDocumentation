clear

load('../loc_results/wood40-8grid-tap-effect-results.mat');
s = Surface([80 80]);
s.addSensor(0,0);
s.addSensor(1,0);
s.addSensor(0,1);
s.addSensor(1,1);
renderer = SurfaceRenderer(s);
% renderer.plot();
eIdx = 0;
velocity = 30000;
bandIdx = 8;
for pointIdx = centerID
    eIdx = eIdx + 1;
    estErrEach{eIdx} = [];
    preErrEach{eIdx} = [];
    points = pointsAll{pointIdx};
    if size(points,1) >= 2 && ismember(pointIdx, centerID)
       renderer.addPoints(points);hold on;
       ptCenter = mean(points);
       if sum(isnan(ptCenter)) == 0
           plot([ptCenter(1),GT{pointIdx}(1)],[ptCenter(2),GT{pointIdx}(2)],'k');
           for i = 1:size(points,1)
               estErrEach{eIdx} = [estErrEach{eIdx}; sqrt(sum((points(i,:)-GT{pointIdx}).^2))];
               preErrEach{eIdx} = [preErrEach{eIdx}; sqrt(sum((points(i,:)-ptCenter).^2))];
           end
       end
       title([num2str(velocity) '-' num2str(bandIdx)]);
    end
    hold off
end

distance = [0:4];
orderIdx = [4,5,12,13;3,6,11,14;2,7,10,15;1,8,9,16];
estErrPlot = [];
preErrPlot = [];
for idx = 1:4
    estErrLoc{idx} = [estErrEach{orderIdx(idx,1)};estErrEach{orderIdx(idx,2)};estErrEach{orderIdx(idx,3)};estErrEach{orderIdx(idx,4)}];
    estErrPlot = [estErrPlot; mean(estErrLoc{idx}), std(estErrLoc{idx})];
    preErrLoc{idx} = [preErrEach{orderIdx(idx,1)};preErrEach{orderIdx(idx,2)};preErrEach{orderIdx(idx,3)};preErrEach{orderIdx(idx,4)}];
    preErrPlot = [preErrPlot; mean(preErrLoc{idx}), std(preErrLoc{idx})];
end

% figure;
errorbar([5:10:35],estErrPlot(:,1),estErrPlot(:,2));hold on;
errorbar([5:10:35],preErrPlot(:,1),preErrPlot(:,2));hold off;

xlabel('Distance to Board Center (cm)');
set(gca,'XTickLabel',{' 5','15','25','35'});
ylabel('Error (cm)');
legend('Localization Error', 'Precision');