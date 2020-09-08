% number of experiments
exp_num = 4;

% run experiments for 4 methods
% 1) SVM
% 2) TSVM
% 3) RTSVM
% 4) FootprintID
for exp_id = 4
    cv_sys(exp_id, exp_num, []);
end

% print the average results for the 4 methods
% 1) SVM
% 2) TSVM
% 3) RTSVM
% 4) FootprintID
for exp_id = 1:4
    load(['cv_exp' num2str(exp_id) '.mat']);
    mean(acc_list)
end
