clear all
close all
clc

init();
s = Surface([60 60]);
s.addSensor(0,0);
s.addSensor(1,0);
s.addSensor(0,1);
s.addSensor(1,1);
tdoaCalc = FirstPeakTdoaCalculator();
% tdoaCalc = XcorrTdoaCalculator();

% prepare renderer
for velocity = 60000%:1000:16000%6000:2000:16000%15000
    localizer = PairLocalizer(s, [1,1,1,1,1,1].*velocity);

    for i = 0:0
        
        for bandIdx = 5%5:5:20%5:5:45%45:10:100               
            load('datasets/wood40-6grid-cali.mat');
%         for bandIdx = 14%45:10:100   
%             bandIdx
%             load('/data/drive/dataset/cement24-cali.mat');
            bFilter = WaveletFilter();
            bFilter.noiseMaxScale=bandIdx;

%             bFilter = BandPassFilter(Fs, 30, 40, 2);
%             bFilter = TwoBandFilter(Fs, 30,40,200,220,2);
            tdoas = [];

            for idx = 1:length(events)
               e = events(idx);
%                e.plot(1,gcf,true);hold on;
               e.filter(bFilter);
%                e.plot();
               oneTdoa = e.getTdoa(tdoaCalc);
               tdoas = [tdoas; oneTdoa];
%                title([num2str(velocity) '-' num2str(bandIdx)]);
            end
            tdoaAll{i+1} = tdoas;
            points = localizer.resolve(tdoas);
            renderer = SurfaceRenderer(s);
            renderer.plot();
            renderer.addPoints(points);
            title(['band:' num2str(bandIdx) 'v:' num2str(velocity)]);
        end
        drawnow;
    end
end

% GT = [20,0;40,20;20,40;0,20;20,20];
% TD12 = zeros(40);
% for idx = 1:5:25
%     temp = mean(tdoas(idx:idx+4,:))
%     loc = GT(round(idx/5)+1,:)+1
%     TD12(loc(1),loc(2)) = (temp(2)-temp(1));
% end
% figure;
% % imagesc(TD12);
% 
% [Xq,Yq] = meshgrid(1:1:41);
% for i = 1:size(tdoas,1)
%     for j = 4:-1:1
%         tdoas(i,j) = tdoas(i,j)-tdoas(i,1);
%     end
% end
% 
% caliTdoa = [];
% for i=1:5:25
%     if i == 1
%         temp = tdoas(i:i+3,:);
%     else
%         temp = tdoas(i:i+4,:);
%     end
%     temp = mean(temp);
%     temp = temp - temp(1);
%     caliTdoa = [caliTdoa; temp];
% end
% points
% 
% save('caliTdoa_pla.mat','caliTdoa','events');

% pfreq = scal2frq(scales,'mexh',1/Fs)
% tdoaAllStd = zeros(4,10);
% for bandIdx = 1:4
%     for positionIdx = 1:10
%         tdoaAllMean{bandIdx,positionIdx} = mean(tdoaAll{bandIdx,positionIdx});
%         tdoaAllStd(bandIdx,positionIdx) = sum(std(tdoaAll{bandIdx,positionIdx}));
%     end
% end
% mean(tdoaAllStd,2)
% 
% for j = 1:10
%     tdoaNormalize = tdoaAll{1,j};
% %     for i=1:4
% %         if j <=5
% %             tdoaNormalize(:,i) = tdoaNormalize(:,i)./tdoaAll{1,j}(:,2);
% %         else
% %             tdoaNormalize(:,i) = tdoaNormalize(:,i)./tdoaAll{1,j}(:,3);
% %         end
% %     end
%     tdoaNormalize = tdoaNormalize./0.001;
%     mean(tdoaNormalize)
% end
