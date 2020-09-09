function [ acc_nosemi_novoting, acc_nosemi_voting, acc_semi_novoting, acc_semi_voting ]...
    = bias3(num_trace_per, trace_random, exp_id  )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% setpath for library


addpath('svml-master/')
addpath('libsvm-3.22/matlab/')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load data and map to correct speed


ind_speed_tr = [4];
ind_speed_te = [4];

x_old = [];
y_old = [];

[ x_tr,y_tr, y_pred4, y_te4, speed_te4, acc_nosemi_novoting, acc_nosemi_voting, acc_semi_novoting, acc_semi_voting, confi, ~  ]...
    = run_svm([], trace_random, ind_speed_tr, ind_speed_te, 1, x_old, y_old );


ind_speed_tr = [4];
ind_speed_te = [3 5];

x_old = [];
y_old = [];

[ x_tr,y_tr, y_pred, y_te, speed_te, acc_nosemi_novoting, acc_nosemi_voting, acc_semi_novoting, acc_semi_voting, ~, ~  ]...
    = run_svm([],  trace_random, ind_speed_tr, ind_speed_te, 2, x_old, y_old );

ind_speed_tr = [4];
ind_speed_te = [1 2 3 4 5 6 7];

x_old = x_tr;
y_old = y_tr;

[ x_tr,y_tr, y_pred, y_te, speed_te, acc_nosemi_novoting, acc_nosemi_voting, acc_semi_novoting, acc_semi_voting,~,pred_table  ]...
    = run_svm(num_trace_per*3,  trace_random, ind_speed_tr, ind_speed_te,3,x_old, y_old  );

acc = sum(y_pred==y_te)/size(y_pred,1);

ind_rm = find(speed_te==4);
y_pred(ind_rm,:) = [];
y_te(ind_rm,:) = [];
speed_te(ind_rm,:) = [];

y_pred = [y_pred; y_pred4];
y_te = [y_te; y_te4];
speed_te = [speed_te; speed_te4];

acc_after = sum(y_pred==y_te)/size(y_pred,1);

save(['bias3_' num2str(exp_id) '.mat'],'speed_te','y_pred','y_te','acc','acc_after','confi','pred_table','ind_rm');

end

