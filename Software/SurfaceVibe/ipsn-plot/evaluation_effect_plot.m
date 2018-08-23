clear all
close all
clc

load('compare_effect_4_2.mat');
eva{1} = evaluation(1,:,:);
eva{2} = evaluation(2,:,:);
% load('compare_effect_4.mat');
% eva{1} = evaluation(2,:,:);
% eva{2} = evaluation(1,:,:);
clear evaluation

for sIdx = 1:2
    aError{sIdx} = [];
    lError{sIdx} = [];
    dError{sIdx} = [];
    
    
    eve = eva{sIdx};
    dNum = size(eve,2);
    eNum = size(eve,3);

    angE = ones(dNum,eNum) * NaN;
    lenE = ones(dNum,eNum) * NaN;
    distE = ones(dNum,eNum) * NaN;

    for directionIdx = 1:dNum
        for eventIdx = 1:eNum
            if ~isempty(eve{1,directionIdx, eventIdx})
                angE(directionIdx,eventIdx) = eve{1,directionIdx, eventIdx}.angleError;
                lenE(directionIdx,eventIdx) = eve{1,directionIdx, eventIdx}.lengthError;
                distE(directionIdx,eventIdx) = mean(eve{1,directionIdx, eventIdx}.distances);
            end
        end
    end

    setID{1} = [5,5];
    setID{2} = [4,6];
    setID{3} = [3,7];
    setID{4} = [2,8];
    setID{5} = [1,9];

    angleErrors = cell(5,1);angleErrorsMean = zeros(5,1);angleErrorsStd = zeros(5,1);
    lengthErrors = cell(5,1);lengthErrorsMean = zeros(5,1);lengthErrorsStd = zeros(5,1);
    distanceErrors = cell(5,1);distanceErrorsMean = zeros(5,1);distanceErrorsStd = zeros(5,1);
    validRate = zeros(5,1);
    for i = 1:5
        temp = [angE(setID{i}(1),:),angE(setID{i}(2),:)];
        validRate(i) = length(temp(~isnan(temp)))/length(temp);
        angleErrors{i} = temp';%(~isnan(temp));
        angleErrors{i}(abs(angleErrors{i}) > 180) = NaN;
        aError{sIdx} = [aError{sIdx}, angleErrors{i}];
        angleErrorsMean(i) = mean(angleErrors{i}(~isnan(angleErrors{i})));
        angleErrorsStd(i) = std(angleErrors{i}(~isnan(angleErrors{i})));
        temp = [lenE(setID{i}(1),:),lenE(setID{i}(2),:)];
        lengthErrors{i} = temp';%(~isnan(temp));
        lError{sIdx} = [lError{sIdx}, lengthErrors{i}];
        lengthErrorsMean(i) = mean(temp(~isnan(temp)));
        lengthErrorsStd(i) = std(temp(~isnan(temp)));
        temp = [distE(setID{i}(1),:),distE(setID{i}(2),:)];
        distanceErrors{i} = temp';%(~isnan(temp));
        distanceErrorsMean(i) = mean(temp(~isnan(temp)));
        distanceErrorsStd(i) = std(temp(~isnan(temp)));
        dError{sIdx} = [dError{sIdx}, distanceErrors{i}];
    end

end

aa = aError{1};
mean(aa(~isnan(aa)))
std(aa(~isnan(aa)))
aa = aError{2};
mean(aa(~isnan(aa)))
std(aa(~isnan(aa)))

h = figure;
subplot(3,1,1);
aboxplot(aError);
xlabel('Distance to Board Center');
ylabel('Error (degrees)');
title('Angle Error');
set(gca,'XTickLabel',{'0','10','20','30','40'});
hold on;
plot([0 6], [0 0], 'r--');

subplot(3,1,2);
aboxplot(lError);
xlabel('Distance to Board Center');
ylabel('Error (cm)');
title('Length Error');
set(gca,'XTickLabel',{'0','10','20','30','40'});
hold on;
plot([0 6], [0 0], 'r--');

subplot(3,1,3);
aboxplot(dError);
xlabel('Distance to Board Center');
ylabel('Error (cm)');
set(gca,'XTickLabel',{'0','10','20','30','40'});
title('Trajectory Error');
hold on;
plot([0 6], [0 0], 'r--');

figure;
subplot(3,1,1);
errorbar([0:10:40],angleErrorsMean,angleErrorsStd);
ylabel('Error (degrees)');
title('Angle Error');hold on;
plot([0 40], [0 0], 'r--');

subplot(3,1,2);
errorbar([0:10:40],lengthErrorsMean,lengthErrorsStd);
ylabel('Error (cm)');
title('Length Error');hold on;
plot([0 40], [0 0], 'r--');

subplot(3,1,3);
errorbar([0:10:40],distanceErrorsMean,distanceErrorsStd);
ylabel('Error (cm)');
title('Trajectory Error');hold on;
plot([0 40], [0 0], 'r--');xlabel('Distance to board center (cm)');

%%
lengthErrorsDamp = lError{2};
ledMean = zeros(1,5);
ledStd = zeros(1,5);
for i = 1:5
    temp = lengthErrorsDamp(:,i);
    ledMean(i) = mean(temp(~isnan(temp)));
    ledStd(i) = std(temp(~isnan(temp)));
end

angleErrorsDamp = aError{2};
aedMean = zeros(1,5);
aedStd = zeros(1,5);
for i = 1:5
    temp = angleErrorsDamp(:,i);
    aedMean(i) = mean(temp(~isnan(temp)));
    aedStd(i) = std(temp(~isnan(temp)));
end

distErrorsDamp = dError{2};
dedMean = zeros(1,5);
dedStd = zeros(1,5);
for i = 1:5
    temp = distErrorsDamp(:,i);
    dedMean(i) = mean(temp(~isnan(temp)));
    dedStd(i) = std(temp(~isnan(temp)));
end

figure;
subplot(3,1,1);
errorbar(ledMean,ledStd);
xlabel('Distance to board center (cm)');ylabel('Error (cm)');
title('Length Error');
set(gca,'XTickLabel',{'0','10','20','30','40'});
hold on;
plot([0.5 5.5], [0 0], 'r--');

subplot(3,1,2);
errorbar(aedMean,aedStd);
xlabel('Distance to board center (cm)');ylabel('Error (degree)');
title('Angle Error');
set(gca,'XTickLabel',{'0','10','20','30','40'});
hold on;
plot([0.5 5.5], [0 0], 'r--');

subplot(3,1,3);
errorbar(dedMean,dedStd);
xlabel('Distance to board center (cm)');ylabel('Error (cm)');
set(gca,'XTickLabel',{'0','10','20','30','40'});
title('Trajectory Error');
hold on;
plot([0.5 5.5], [0 0], 'r--');



%%
% load('compare_effect_3.mat');
% eva{1} = evaluation(1,:,:);
% eva{2} = evaluation(2,:,:);
% 
% 
% for sIdx = 1:2
%     aError{sIdx} = [];
%     lError{sIdx} = [];
%     dError{sIdx} = [];
%     
%     
%     eve = eva{sIdx};
%     dNum = size(eve,2);
%     eNum = size(eve,3);
% 
%     angE = ones(dNum,eNum) * NaN;
%     lenE = ones(dNum,eNum) * NaN;
%     distE = ones(dNum,eNum) * NaN;
% 
%     for directionIdx = 1:dNum
%         for eventIdx = 1:eNum
%             if ~isempty(eve{1,directionIdx, eventIdx})
%                 angE(directionIdx,eventIdx) = eve{1,directionIdx, eventIdx}.angleError;
%                 lenE(directionIdx,eventIdx) = eve{1,directionIdx, eventIdx}.lengthError;
%                 distE(directionIdx,eventIdx) = mean(eve{1,directionIdx, eventIdx}.distances);
%             end
%         end
%     end
% 
% %     setID{1} = [5,5];
% %     setID{2} = [4,6];
% %     setID{3} = [3,7];
% %     setID{4} = [2,8];
% %     setID{5} = [1,9];
% 
%     angleErrors = cell(5,1);angleErrorsMean = zeros(5,1);angleErrorsStd = zeros(5,1);
%     lengthErrors = cell(5,1);lengthErrorsMean = zeros(5,1);lengthErrorsStd = zeros(5,1);
%     distanceErrors = cell(5,1);distanceErrorsMean = zeros(5,1);distanceErrorsStd = zeros(5,1);
%     validRate = zeros(5,1);
%     for i = [1:5]
%         temp = [angE(i,:)];
%         validRate(i) = length(temp(~isnan(temp)))/length(temp);
%         angleErrors{i} = temp';%(~isnan(temp));
% %         angleErrors{i}(abs(angleErrors{i}) > 180) = NaN;
%         aError{sIdx} = [aError{sIdx}, angleErrors{i}];
%         angleErrorsMean(i) = mean(angleErrors{i}(~isnan(angleErrors{i})));
%         angleErrorsStd(i) = std(angleErrors{i}(~isnan(angleErrors{i})));
%         temp = [lenE(i,:)];
%         lengthErrors{i} = temp';%(~isnan(temp));
%         lError{sIdx} = [lError{sIdx}, lengthErrors{i}];
%         lengthErrorsMean(i) = mean(temp(~isnan(temp)));
%         lengthErrorsStd(i) = std(temp(~isnan(temp)));
%         temp = [distE(i,:)];
%         distanceErrors{i} = temp';%(~isnan(temp));
%         distanceErrorsMean(i) = mean(temp(~isnan(temp)));
%         distanceErrorsStd(i) = std(temp(~isnan(temp)));
%         dError{sIdx} = [dError{sIdx}, distanceErrors{i}];
%     end
% 
% end
% 
% 
% % h = figure;
% subplot(3,1,1);
% aboxplot(lError);
% xlabel('Distance to Board Center (cm)');
% ylabel('Error (cm)');
% title('Length Error');
% set(gca,'XTickLabel',{'0','5','10','15','20'});
% hold on;
% plot([0 6], [0 0], 'r--');
% 
% subplot(3,1,2);
% aboxplot(aError);
% xlabel('Distance to Board Center (cm)');
% ylabel('Error (degrees)');
% title('Angle Error');
% set(gca,'XTickLabel',{'0','5','10','15','20'});
% hold on;
% plot([0 6], [0 0], 'r--');
% 
% subplot(3,1,3);
% aboxplot(dError);
% xlabel('Distance to Board Center (cm)');
% ylabel('Error (cm)');
% set(gca,'XTickLabel',{'0','5','10','15','20'});
% title('Trajectory Error');
% hold on;
% plot([0 6], [0 0], 'r--');

% figure;
% 
% subplot(3,1,1);
% errorbar([0:5:40],lengthErrorsMean,lengthErrorsStd);
% ylabel('Error (cm)');
% title('Length Error');hold on;
% plot([0 40], [0 0], 'r--');
% 
% subplot(3,1,2);
% errorbar([0:5:40],angleErrorsMean,angleErrorsStd);
% ylabel('Error (degrees)');
% title('Angle Error');hold on;
% plot([0 40], [0 0], 'r--');
% 
% 
% 
% subplot(3,1,3);
% errorbar([0:5:40],distanceErrorsMean,distanceErrorsStd);
% ylabel('Error (cm)');
% title('Trajectory Error');hold on;
% plot([0 40], [0 0], 'r--');xlabel('Distance to board center (cm)');