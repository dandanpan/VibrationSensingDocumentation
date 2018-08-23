clear all
close all
clc

init();
surfaceSize = [80 80];
s = Surface(surfaceSize);
s.addSensor(0,0);
s.addSensor(1,0);
s.addSensor(0,1);
s.addSensor(1,1);

bands = 10:11;% 5:5:40;
velocities = 12000:2000:64000;%14000:2000:24000;

% GT = [20,0;20,0;20,0;20,0;20,0;
%     40,20;40,20;40,20;40,20;40,20;
%     20,40;20,40;20,40;20,40;20,40;
%     0,20;0,20;0,20;0,20;0,20;
%     20,20;20,20;20,20;20,20;20,20];

GT = [ 0.5 0; 0.5 0; 0.5 0; 0.5 0; 0.5 0;
        1 0.5; 1 0.5; 1 0.5; 1 0.5; 1 0.5;
        0.5 1; 0.5 1; 0.5 1; 0.5 1; 0.5 1;
        0 0.5; 0 0.5; 0 0.5; 0 0.5; 0 0.5;
        0.5 0.5; 0.5 0.5; 0.5 0.5; 0.5 0.5; 0.5 0.5;];
    
GT = GT * [surfaceSize(1) 0; 0 surfaceSize(2)];

surfaces{1} = 'cement24';
surfaces{2} = 'cement36';
surfaces{3} = 'iron24';
surfaces{4} = 'stone24';
surfaces{5} = 'tile16';
surfaces{6} = 'wood24-dampened';
surfaces{7} = 'iron24-dampened';
surfaces{8} = 'cement24-dampened';
surfaces{9} = 'wood40-8grid';

folderName = 'data/OrganizedData/Calibration';
mkdir(folderName);

for sType = 9%1:length(surfaces)
   surfaceType = surfaces{sType}; 
   
   load([surfaceType '-cali.mat']);

    [tdoaBands, points, errors] = tap_calibration(s,events,bands,velocities,GT);

    %% plot points
    for bIdx = 1:length(bands)
       for vIdx = 1:length(velocities) 
            renderer = SurfaceRenderer(s);
            renderer.plot();
            renderer.addPoints(points{bIdx,vIdx});
            title([num2str(bands(bIdx), 'Band %d ') ' ' num2str(velocities(vIdx), 'Vel %d')]);
       end
    end

    %% plot error
    nBands = length(bands);
    nVel = length(velocities);
    bErrors = cell(nVel,1);
    legends = [];
    for bIdx = 1:nVel
       vErrors = zeros(25,nBands);
       for vIdx = 1:nBands
            vErrors(:,vIdx) = errors{vIdx,bIdx};
       end
       bErrors{bIdx} = vErrors;
       legends = [legends; num2str(velocities(bIdx), 'v=%06d cm/s')];
    end
    h = figure;
    aboxplot(bErrors,'labels',bands);
    xlabel('Band');
    ylabel('Error (cm)');
    legend(legends);
    title(surfaceType);
%     saveas(h,[folderName '/' surfaceType '-errors.fig'],'fig');
%     save([folderName '/' surfaceType '-errors.mat'], 'bands', 'velocities', 'tdoaBands', 'points', 'errors');
end
