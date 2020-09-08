clear all
close all
clc

acc1 = [];
for i = 1:10
    if i >= 10
        load([num2str(i) '   1.mat']);
    else
        load([num2str(i) '  1.mat']);
    end
    acc_uncontrol = sum(y_pred == y_te)/length(y_te);
    acc1 = [acc1, acc_uncontrol];
end

acc2 = [];
for i = 1:10
    if i >= 10
        load([num2str(i) '   6.mat']);
    else
        load([num2str(i) '  6.mat']);
    end
    acc2 = [acc2, acc_uncontrol_final];
end

mean(acc1)
mean(acc2)

figure;
errorbar(mean(acc1), std(acc1));hold on;
errorbar(mean(acc2), std(acc2));hold off;

%%
load('1  6.mat');
