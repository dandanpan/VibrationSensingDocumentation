%% used the MPH = max(sig)/6; for first peak detection

clear all
close all
clc

init();
s = Surface([50 50]);
s.addSensor(0,0);
s.addSensor(1,0);
s.addSensor(0,1);
s.addSensor(1,1);
tdoaCalc = FirstPeakTdoaCalculator();
% prepare renderer
renderer = SurfaceRenderer(s);
renderer.plot();
estErr = [];

% generate ground truth index
% 8 rows, 8 columns each
gridNum = 4;
GT = cell(gridNum*gridNum,1);

for row = 0:gridNum-1
   for col = 0:gridNum-1
       GT{row * gridNum + col + 1} = [ (10*col + 5), (10*row + 5) ]+5;
   end
end

for velocity = 20000
    localizer = PairLocalizer(s, [1,1,1,1,1,1].*velocity);

    for bandIdx = 10
        load('data/drive/dataset/wood40-5grid-undamped-tap.mat');
        for tapIdx = 0:gridNum-1
            tapIdx
            bFilter = WaveletFilter();
            bFilter.noiseMaxScale=bandIdx;

            eventBatch = events{tapIdx+1};
            
            % wood40 taps are 8 locations per batch,
            % each location is 10 taps each
            for location = 0:gridNum-1
               pointIdx = tapIdx*gridNum + location+1
               tdoas = [];
               points = [];
               for locationTap = 1:10
                   e = eventBatch(location*10 + locationTap);
                   e.filter(bFilter);
%                    e.plot();
                   [oneTdoa] = e.getTdoa(tdoaCalc);
                   onePoint = localizer.resolve(oneTdoa);
                   % check point location, if it is off too much, check the
                   % second one, if both off, discard
                   % [40,40] is the center. Set 60 as max radius
                   if sqrt(sum((onePoint - [30,30]).^2)) > 50
                       continue;
                   end
                   if onePoint(1) == 0 && onePoint(2) == 0
                       continue;
%                    elseif onePoint(1) <= 0.05 && abs(onePoint(2)) >= 79.5
%                        continue;
%                    elseif onePoint(2) <= 0.05 && abs(onePoint(1)) >= 79.5
%                        continue;
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
%%
close all
renderer = SurfaceRenderer(s);
renderer.plot();
for pointIdx = 1:16
    points = pointsAll{pointIdx}
    if size(points,1) >= 2 
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
save('wood40-5grid-tap-results.mat','tdoaAll','pointsAll','estErr');

