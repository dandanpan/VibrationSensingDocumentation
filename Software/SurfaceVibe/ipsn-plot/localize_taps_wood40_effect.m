%% used the MPH = max(sig)/6; for first peak detection

clear all
close all
clc

init();
s = Surface([80 80]);
s.addSensor(0,0);
s.addSensor(1,0);
s.addSensor(0,1);
s.addSensor(1,1);
tdoaCalc = FirstPeakTdoaCalculator();
% prepare renderer
renderer = SurfaceRenderer(s);
renderer.plot();
estErr = [];


centerID = [];
% generate ground truth index
% 8 rows, 8 columns each
GT = cell(80,1);
for row = 0:7
   for col = 0:7
       GT{row * 8 + col + 1} = [ (10*col + 5), (10*row + 5) ];
   end
end

for velocity = 30000
    localizer = PairLocalizer(s, [1,1,1,1,1,1].*velocity);

    for bandIdx = 8
        load('data/drive/dataset/wood40-8grid-tap.mat');
        for tapIdx = 3:4%0:7
            tapIdx
            bFilter = WaveletFilter();
            bFilter.noiseMaxScale=bandIdx;

            eventBatch = events{tapIdx+1};
            
            % wood40 taps are 8 locations per batch,
            % each location is 10 taps each
            for location = 0:7
               pointIdx = tapIdx*8 + location+1
               
               centerID = [centerID, pointIdx];
               tdoas = [];
               points = [];
               for locationTap = 1:10
                   e = eventBatch(location*10 + locationTap);
                   e.filter(bFilter);
%                    e.plot();
                   e.data(:,2:5) = -e.data(:,2:5);
                   [oneTdoa] = e.getTdoa(tdoaCalc);
                   onePoint = localizer.resolve(oneTdoa);
                   % check point location, if it is off too much, check the
                   % second one, if both off, discard
                   % [40,40] is the center. Set 60 as max radius
                   if sqrt(sum((onePoint - [40,40]).^2)) > 60
                       continue;
                   end
                   if onePoint(1) == 0 && onePoint(2) == 0
                       continue;
                   elseif onePoint(1) <= 0.05 && abs(onePoint(2)) >= 79.5
                       continue;
                   elseif onePoint(2) <= 0.05 && abs(onePoint(1)) >= 79.5
                       continue;
                   end
                   tdoas = [tdoas; oneTdoa];
                   points = [points; onePoint];
               end
               
               tdoaAll{pointIdx} = tdoas;
               pointsAll{pointIdx} = points;
               if size(points,1) >= 2
                   renderer.addPoints(points);hold on;
                   ptCenter = mean(points);
                   if sum(isnan(ptCenter)) == 0
                       plot([ptCenter(1),GT{pointIdx}(1)],[ptCenter(2),GT{pointIdx}(2)],'k');
                       estErr = [estErr; sqrt(sum((ptCenter-GT{pointIdx}).^2))];
                   end
                   title([num2str(velocity) '-' num2str(bandIdx)]);
               end
               hold off;
            end
        end
        drawnow;
    end
end

mean(estErr)
std(estErr)

save('wood40-8grid-effect-results.mat','tdoaAll','pointsAll','estErr','centerID','GT');

%% plotting
clear
load('./loc_results/wood40-8grid-tap-effect-results.mat');
s = Surface([80 80]);
s.addSensor(0,0);
s.addSensor(1,0);
s.addSensor(0,1);
s.addSensor(1,1);
renderer = SurfaceRenderer(s);
renderer.plot();
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

figure;
errorbar([5:10:35],estErrPlot(:,1),estErrPlot(:,2));hold on;
errorbar([5:10:35],preErrPlot(:,1),preErrPlot(:,2));hold off;

