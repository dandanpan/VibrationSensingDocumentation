%% plot area comparison
total_acc = [];
for areaID = 1:5
    area_acc = [];
    switch(areaID)
        case 1
            area_name = '1  2  3';
        case 2
            area_name = '2  3  4';
        case 3
            area_name = '3  4  5';
        case 4
            area_name = '4  5  6';
        case 5
            area_name = '5  6  7';
    end
    if areaID == 6
        area_name = '1  3  6';
    end
    for i = 1:10
        if i >= 10
            load([num2str(i) '   1' area_name '.mat']);
        else
            load([num2str(i) '  1' area_name '.mat']);
        end
        acc = sum(y_pred == y_te)/length(y_te);
        area_acc = [area_acc, acc];
    end
    total_acc = [total_acc; area_acc];
end
case_acc = mean(total_acc,2);

%%
total_acc2 = [];
for areaID = 1:5
    area_acc = [];
    switch(areaID)
        case 1
            area_name = '1  2  3';
        case 2
            area_name = '2  3  4';
        case 3
            area_name = '3  4  5';
        case 4
            area_name = '4  5  6';
        case 5
            area_name = '5  6  7';
    end
    if areaID == 6
        area_name = '1  3  4';
    end
    for i = 1:10
        if i >= 10
            load([num2str(i) '   6' area_name '.mat']);
        else
            load([num2str(i) '  6' area_name '.mat']);
        end
        acc = sum(y_pred == y_te)/length(y_te);
        area_acc = [area_acc, acc];
    end
    total_acc2 = [total_acc2; area_acc];
end
case_acc2 = mean(total_acc2,2);

%%
figure;
bar([case_acc, case_acc2]);
