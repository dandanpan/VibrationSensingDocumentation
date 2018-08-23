clear all
close all
clc

load('../dataset/Ball.mat');
Fs = 1000;

%% variation between locations near one sensor
%% Sensor3
Loc{1,1} = Ball.Sen{3}{1,1}(5000:22500);
Loc{2,1} = Ball.Sen{3}{3,1};
Loc{3,1} = Ball.Sen{3}{5,1};
Loc{4,1} = Ball.Sen{3}{7,1};
Loc{5,1} = Ball.Sen{3}{9,1};
Loc{1,2} = Ball.Sen{3}{2,1};
Loc{2,2} = Ball.Sen{3}{4,1};
Loc{3,2} = Ball.Sen{3}{6,1};
Loc{4,2} = Ball.Sen{3}{8,1};
Loc{5,2} = Ball.Sen{3}{10,1};

numImpulse = 10;
numLocation = 5;
numBall = 2;
WIN1 = 30;
WIN2 = 100;
figure;
for ballID = 1 : numBall
    for locID = 1 : numLocation
        [ pV ,pI ] = findpeaks(Loc{locID,ballID},'MinPeakDistance',500,'MinPeakHeight',100,'Annotate','extents');

        subplot(2,5,(ballID-1)*5+locID);
        plot(Loc{locID,ballID});hold on;
        for stepID = 1 : length(pV)
            if ballID == 1
                scatter(pI(stepID),pV(stepID),'rV');
            else
                scatter(pI(stepID),pV(stepID),'gV');
            end
        end
        hold off;
        ylim([-550,550]);
    end 
end

% loadtest_sensor3_golf;
% loadtest_sensor3_tennis;


%% Sensor5
Loc{1,1} = Ball.Sen{5}{10,1};
Loc{2,1} = Ball.Sen{5}{12,1};
Loc{3,1} = Ball.Sen{5}{14,1};
Loc{4,1} = Ball.Sen{5}{16,1};
Loc{5,1} = Ball.Sen{5}{18,1};
Loc{1,2} = Ball.Sen{5}{11,1};
Loc{2,2} = Ball.Sen{5}{13,1};
Loc{3,2} = Ball.Sen{5}{15,1};
Loc{4,2} = Ball.Sen{5}{17,1};
Loc{5,2} = Ball.Sen{5}{19,1};

figure;
for ballID = 1 : numBall
    for locID = 1 : numLocation
        [ pV ,pI ] = findpeaks(Loc{locID,ballID},'MinPeakDistance',500,'MinPeakHeight',100,'Annotate','extents');

        subplot(2,5,(ballID-1)*5+locID);
        plot(Loc{locID,ballID});hold on;
        for stepID = 1 : length(pV)
            if ballID == 1
                scatter(pI(stepID),pV(stepID),'rV');
            else
                scatter(pI(stepID),pV(stepID),'gV');
            end
        end
        hold off;
        ylim([-550,550]);
    end
    
end

% loadtest_sensor5_golf;
loadtest_sensor5_tennis;