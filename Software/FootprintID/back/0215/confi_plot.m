% clear all
close all
clc

list_ave = [];
num_list_ave = [];

for i = 1:1
    if i <10
        data_name = [num2str(i) '  6.mat'];
    else
        data_name = [num2str(i) '   6.mat'];
    end
        
   [list, num_list] = confi_trace1(data_name);
   list_ave = [list_ave; list];
   num_list_ave = [num_list_ave; num_list];
   
end

list_ave(isnan(list_ave))=1;
% list_ave = list_ave/10;
% num_list_ave = num_list_ave/10;
xx = 0:3.5:70;
figure
% [hAx,hLine1,hLine2] = plotyy(xx(1:14)./70,mean(list_ave(:,1:14),1),xx(1:14)./70,mean(num_list_ave(:,1:14),1)./40);hold on;
% plot([.2288, .2288],[0,1]); hold on;
% plot([0, .7],[0.5, .5]); hold on;
% plot([0, .7],[0.9,0.9]); hold on;
plot(xx./70,mean(list_ave,1))
hold on
plot(xx./70,mean(num_list_ave,1)/280,'r')
% xlim([xx(1)./70 xx(14)./70])
% title('Multiple Decay Rates')
xlabel('Confidence Threshold')

% ylabel(hAx(1),'ID accuracy') % left y-axis
% ylabel(hAx(2),'ID ratio') % right y-axis

