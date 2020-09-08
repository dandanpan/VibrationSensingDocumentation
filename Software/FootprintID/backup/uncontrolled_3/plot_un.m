clear all
close all
clc

confusion_table_1 = zeros(10);
acc1 = [];
for i = 1:10
    if i >= 10
        load([num2str(i) '   1.mat']);
    else
        load([num2str(i) '  1.mat']);
    end
    acc_uncontrol = sum(y_pred == y_te)/length(y_te);
    acc1 = [acc1, acc_uncontrol];
    for j = 1:size(confusion_table,1)
        for k = 1:size(confusion_table,2)
            confusion_table_1(j,k) = confusion_table_1(j,k) + confusion_table(j,k);
        end
    end
end
confusion_table_1 = confusion_table_1./10;

confusion_table_2 = zeros(11);
acc2 = [];
for i = 1:10
    if i >= 10
        load([num2str(i) '   6.mat']);
    else
        load([num2str(i) '  6.mat']);
    end
    acc2 = [acc2, acc_uncontrol_final];
    for j = 1:size(confusion_table,1)
        for k = 1:size(confusion_table,2)
            confusion_table_2(j,k) = confusion_table_2(j,k) + confusion_table(j,k);
        end
    end
end
confusion_table_2 = confusion_table_2./10;


mean(acc1)
mean(acc2)

figure;
errorbar(mean(acc1), std(acc1));hold on;
errorbar(mean(acc2), std(acc2));hold off;

%%
figure;
subplot(1,2,1);
imagesc(confusion_table_1./70);
subplot(1,2,2);
imagesc(confusion_table_2./70);


