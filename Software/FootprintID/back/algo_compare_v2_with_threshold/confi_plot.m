clear all
close all
% clc

% list_ave = [];
% num_list_ave = [];

figure;
for cutoff = 1:4
    list_ave = [];
    num_list_ave = [];
    for i = 1:10
        if i <10
            data_name = [num2str(i) '  6.mat'];
        else
            data_name = [num2str(i) '   6.mat'];
        end

       [list, num_list] = confi_trace1(data_name,cutoff-1);
       list_ave = [list_ave; list];
       num_list_ave = [num_list_ave; num_list];

    end
    list_ave(isnan(list_ave))=1;
    % list_ave = list_ave/10;
    % num_list_ave = num_list_ave/10;
    xx = 0:3.5:70;
    hold on; all_count = mean(num_list_ave(:,1));
    if cutoff == 4
        [hAx,hLine1,hLine2] = plotyy(xx(1:14)./70,mean(list_ave(:,1:14),1),xx(1:14)./70,mean(num_list_ave(:,1:14),1)./all_count);hold on;
    else
        plot(xx(1:14)./70,mean(list_ave(:,1:14),1)); hold on;
        plot(xx(1:14)./70,mean(num_list_ave(:,1:14),1)./all_count); hold on;
    end
end
legend('\mu \pm 3\sigma ID accuracy', '\mu \pm 3\sigma confident ID ratio',...
       '\mu \pm 2\sigma ID accuracy', '\mu \pm 2\sigma confident ID ratio',...
       '\mu \pm 1\sigma ID accuracy', '\mu \pm 1\sigma confident ID ratio',...
       '\mu ID accuracy', '\mu confident ID ratio');
% list_ave(isnan(list_ave))=1;
% % list_ave = list_ave/10;
% % num_list_ave = num_list_ave/10;
% xx = 0:3.5:70;
% figure
% [hAx,hLine1,hLine2] = plotyy(xx(1:14)./70,mean(list_ave(:,1:14),1),xx(1:14)./70,mean(num_list_ave(:,1:14),1)./279);hold on;
% plot([.227, .227],[0,1]); hold on;
% plot([0, .7],[0.5, .5]); hold on;
% plot([0, .7],[0.847, 0.847]); hold on;
% plot(xx./70,mean(list_ave,1))
% hold on
% plot(xx./70,mean(num_list_ave,1)/280,'r')
% xlim([xx(1)./70 xx(14)./70])
% title('Multiple Decay Rates')
xlabel('Confidence Threshold')

ylabel(hAx(1),'ID accuracy') % left y-axis
ylabel(hAx(2),'Confident ID ratio') % right y-axis

