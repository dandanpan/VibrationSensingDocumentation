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

for row = 0:7
   for col = 0:7
      GT{ row*8 + col+1 } = [ col*10 + 5, row*10 + 5 ];
   end
end

for velocity = 56000
    localizer = PairLocalizer(s, [1,1,1,1,1,1].*velocity);

    for bandIdx = 10
        load('wood40-8grid-tap2.mat');
        bFilter = WaveletFilter();
        bFilter.noiseMaxScale=bandIdx;
        for row = 0:7
            rowEvents = events{row+1};
            for col = 0:7
                tapIdx = (row*8+col+1)
                tdoas = [];
                points = [];
                
                startIdx = col*10 + 1;
                endIdx = startIdx + 9;
                
                for idx = startIdx:endIdx
                   e = rowEvents(idx);
                   e.filter(bFilter);
    %                e.plot();
                   [oneTdoa] = e.getTdoa(tdoaCalc);
                   onePoint = localizer.resolve(oneTdoa);
                   % check point location, if it is off too much, check the
                   % second one, if both off, discard
    %                if sqrt(sum((onePoint - [20,20]).^2)) > 30
    %                    continue;
    %                end
    %                if onePoint(1) == 0 && onePoint(2) == 0
    %                    continue;
    %                elseif onePoint(1) <= 0.05 && abs(onePoint(2)) >= 39.5
    %                    continue;
    %                elseif onePoint(2) <= 0.05 && abs(onePoint(1)) >= 39.5
    %                    continue;
    %                end
                   tdoas = [tdoas; oneTdoa];
                   points = [points; onePoint];
                end
                tdoaAll{tapIdx} = tdoas;
                pointsAll{tapIdx} = points;
                if size(points,1) >= 2
                    renderer.addPoints(points);hold on;
                    ptCenter = mean(points);
                    if sum(isnan(ptCenter)) == 0
                        plot([ptCenter(1),GT{tapIdx}(1)],[ptCenter(2),GT{tapIdx}(2)],'k');
                        estErr = [estErr; sqrt(sum((ptCenter-GT{tapIdx}).^2))];
                    end
                    title([num2str(velocity) '-' num2str(bandIdx)]);
                end
                hold off;
            end
        end
        drawnow;
    end
end

% testTdoas = [];
% for tapIdx = 1:16
%     temp = mean(tdoaAll{tapIdx});
%     temp = temp-temp(1);
%     testTdoas = [testTdoas; temp];
% end

% mean(estErr)
% std(estErr)

%% plot each point in its own grid

h = figure;
subplot(1,3,1);
renderer = SurfaceRenderer(s);
renderer.plot(h);
errors = cell(3,1);
estErr = [];
for idx = [ 1:8 9:8:49 16:8:56 57:64 ]
   points = pointsAll{idx};
   renderer.plotPoints(points);
   hold on;
   ptCenter = mean(points);
   plot([ptCenter(1),GT{idx}(1)],[ptCenter(2),GT{idx}(2)],'k');
   estErr = [estErr; sqrt(sum((ptCenter-GT{idx}).^2))];
   hold off;
end
errors{1} = estErr;
axis([0 80 0 80]);
title([num2str(mean(estErr),'meanError=%.2f') ' ' num2str(std(estErr), 'std=%.2f')]);

estErr = [];
renderer = SurfaceRenderer(s);
subplot(1,3,2);
renderer.plot(h);
for idx = [ 10:15 18:8:42 23:8:47 50:55 ]
   points = pointsAll{idx};
   renderer.plotPoints(points);
   hold on;
   ptCenter = mean(points);
   plot([ptCenter(1),GT{idx}(1)],[ptCenter(2),GT{idx}(2)],'k');
   estErr = [estErr; sqrt(sum((ptCenter-GT{idx}).^2))];
   hold off;
end
errors{2} = estErr;
axis([0 80 0 80]);
title([num2str(mean(estErr),'meanError=%.2f') ' ' num2str(std(estErr), 'std=%.2f')]);

estErr = [];
renderer = SurfaceRenderer(s);
subplot(1,3,3);
renderer.plot(h);
for idx = [19:22 27:30 35:38 43:46 ]
   points = pointsAll{idx};
   renderer.plotPoints(points);
   hold on;
   ptCenter = mean(points);
   plot([ptCenter(1),GT{idx}(1)],[ptCenter(2),GT{idx}(2)],'k');
   estErr = [estErr; sqrt(sum((ptCenter-GT{idx}).^2))];
   hold off;
end
errors{3} = estErr;
axis([0 80 0 80]);
title([num2str(mean(estErr),'meanError=%.2f') ' ' num2str(std(estErr), 'std=%.2f')]);

save('wood40-8grid-tap-results.mat','tdoaAll','pointsAll', 'errors');
