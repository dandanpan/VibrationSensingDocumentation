detection_rate=[28,28,17;42,41,32];
clear error_average;
thre1=3; thre2=13;
all_number=49;

localization_all_1p=[localization_all(1:thre1,:);localization_all(all_number-thre2:all_number,:)];
ground_truth_1p=[ground_truth(1:thre1,:);ground_truth(all_number-thre2:all_number,:)];
localization_all_error_1p=[localization_all_error(1:thre1),localization_all_error(all_number-thre2:all_number)];
localization_all_2p=localization_all(thre1+1:all_number-thre2-1,:);
ground_truth_2p=ground_truth(thre1+1:all_number-thre2-1,:);
localization_all_error_2p=localization_all_error(thre1+1:all_number-thre2-1);

clear localization_all
clear localization_all_error;
clear ground_truth;
clear all_number
clear thre1;
clear thre2;
save('./result_3p_cross/uncontrol/10_min/localization_result/base3_seperate.mat');