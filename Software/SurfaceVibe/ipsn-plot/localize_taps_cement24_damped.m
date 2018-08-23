clear all
close all
clc

init();
s = Surface([40 40]);
s.addSensor(0,0);
s.addSensor(1,0);
s.addSensor(0,1);
s.addSensor(1,1);
tdoaCalc = FirstPeakTdoaCalculator();
% first peak setting MPH = max(sig)/8;
% prepare renderer
renderer = SurfaceRenderer(s);
renderer.plot();
estErr = [];

GT{1} = [5,5];
GT{2} = [15,5];
GT{3} = [25,5];
GT{4} = [35,5];
GT{5} = [5,15];
GT{6} = [15,15];
GT{7} = [25,15];
GT{8} = [35,15];
GT{9} = [5,25];
GT{10} = [15,25];
GT{11} = [25,25];
GT{12} = [35,25];
GT{13} = [5,35];
GT{14} = [15,35];
GT{15} = [25,35];
GT{16} = [35,35];

for velocity = 15000
    localizer = PairLocalizer(s, [1,1,1,1,1,1].*velocity);
    % use first peak from min energy sig

    for bandIdx = 14
        load('cement24-damp-tap.mat');
        for tapIdxP = 0:3
            
            bFilter = WaveletFilter();
            bFilter.noiseMaxScale=bandIdx;
            tdoas = [];
            points = [];
            for idx = 1:length(events{tapIdxP+1})
               tapIdx = tapIdxP*4+floor((idx-1)/10)
               if mod(idx,10) == 1
                   tdoaAll{tapIdx+1} = [];
                   pointsAll{tapIdx+1} = [];
               end
               e = events{tapIdxP+1}(idx);
               e.filter(bFilter);
%                e.plot();
               oneTdoa = e.getTdoa(tdoaCalc);
               onePoint = localizer.resolve(oneTdoa);
               % check point location, if it is off too much, check the
               % second one, if both off, discard
               if sqrt(sum((onePoint - [20,20]).^2)) > 30
                   continue;
               end
               if onePoint(1) == 0 && onePoint(2) == 0
                   continue;
               elseif onePoint(1) <= 0.05 && abs(onePoint(2)) >= 39.5
                   continue;
               elseif onePoint(2) <= 0.05 && abs(onePoint(1)) >= 39.5
                   continue;
               elseif abs(onePoint(1)) >= 39.5 && abs(onePoint(2)) >= 39.5
                   continue;
               end
               tdoas = [tdoas; oneTdoa];
               tdoaAll{tapIdx+1} = [tdoaAll{tapIdx+1} ; oneTdoa];
               points = [points; onePoint];
               pointsAll{tapIdx+1} = [pointsAll{tapIdx+1}; onePoint];
            end
            
        end
        for idx = 1:length(tdoaAll)
            if size(pointsAll{idx},1) >= 2
                renderer.addPoints(pointsAll{idx});hold on;
                ptCenter = mean(pointsAll{idx});
                if sum(isnan(ptCenter)) == 0
                    plot([ptCenter(1),GT{idx}(1)],[ptCenter(2),GT{idx}(2)],'k');
                    estErr = [estErr; sqrt(sum((ptCenter-GT{idx}).^2))];
                end
                title([num2str(velocity) '-' num2str(bandIdx)]);
            end
        end
        hold off;
        drawnow;
    end
end

mean(estErr)
std(estErr)

% close all
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

save('cement24-damped-tap-results.mat','tdoaAll','pointsAll','estErr');


