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

GT = cell(80,1);

centerID = [];
% generate ground truth index
% 8 rows, 8 columns each
for row = 0:7
   for col = 0:7
       GT{row * 8 + col + 1} = [ (10*col + 5), (10*row + 5) ];
   end
end

for velocity = 30000
    localizer = PairLocalizer(s, [1,1,1,1,1,1].*velocity);

    for bandIdx = 8
        load('data/drive/dataset/wood40-8grid-tap.mat');
        for tapIdx = 2:5%0:7
            tapIdx
            bFilter = WaveletFilter();
            bFilter.noiseMaxScale=bandIdx;

            eventBatch = events{tapIdx+1};
            
            % wood40 taps are 8 locations per batch,
            % each location is 10 taps each
            for location = 2:5%0:7
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

renderer = SurfaceRenderer(s);
renderer.plot();
for pointIdx = centerID
    points = pointsAll{pointIdx};
    if size(points,1) >= 2 && ismember(pointIdx, centerID)
       renderer.addPoints(points);hold on;
       ptCenter = mean(points);
       if sum(isnan(ptCenter)) == 0
           plot([ptCenter(1),GT{pointIdx}(1)],[ptCenter(2),GT{pointIdx}(2)],'k');
           estErr = [estErr; sqrt(sum((ptCenter-GT{pointIdx}).^2))];
       end
       title([num2str(velocity) '-' num2str(bandIdx)]);
    end
    hold off
end

% 
save('wood40-8grid-tap-results.mat','tdoaAll','pointsAll','estErr');

