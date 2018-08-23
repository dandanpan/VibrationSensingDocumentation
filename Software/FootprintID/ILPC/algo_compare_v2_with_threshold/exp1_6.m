function [ acc_nosemi_novoting, acc_nosemi_voting, acc_semi_novoting, acc_semi_voting ]...
    = exp1_6( trace_random, exp_id  )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% setpath for library


addpath('./svml-master/')
addpath('./libsvm-3.22/matlab/')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load data and map to correct speed


ind_speed_tr = [4];
ind_speed_te = [4];

x_old = [];
y_old = [];

[ x_tr,y_tr, y_pred4, y_te4, speed_te4,x_te,exact_speed_te, acc_nosemi_novoting, acc_nosemi_voting, acc_semi_novoting, acc_semi_voting ,modellibsvm ,pred_table_svm ]...
    = run_svm( trace_random, ind_speed_tr, ind_speed_te, 1, x_old, y_old );


ind_speed_tr = [4];
ind_speed_te = [3 5];

x_old = [];
y_old = [];

[ x_tr,y_tr, y_pred, y_te, speed_te,x_te,exact_speed_te, acc_nosemi_novoting, acc_nosemi_voting, acc_semi_novoting, acc_semi_voting  ,~ ,~]...
    = run_svm( trace_random, ind_speed_tr, ind_speed_te, 2, x_old, y_old );

ind_speed_tr = [4];
ind_speed_te = [1 2 3 4 5 6 7];

x_old = x_tr;
y_old = y_tr;

[ x_tr,y_tr, y_pred, y_te, speed_te,x_te, exact_speed_te,acc_nosemi_novoting, acc_nosemi_voting, acc_semi_novoting, acc_semi_voting ,~ ,pred_table_score]...
    = run_svm( trace_random, ind_speed_tr, ind_speed_te,3,x_old, y_old  );

acc = sum(y_pred==y_te)/size(y_pred,1);

ind_rm = find(speed_te==4);
y_pred(ind_rm,:) = [];
y_te(ind_rm,:) = [];
speed_te(ind_rm,:) = [];
pred_table_score(ind_rm,:) = [];

y_pred = [y_pred; y_pred4];
y_te = [y_te; y_te4];
speed_te = [speed_te; speed_te4];
pred_table_score = [pred_table_score; pred_table_svm];

acc_after = sum(y_pred==y_te)/size(y_pred,1);

% acc_uncontrol = sum(y_pred(find(speed_te==8))==y_te(find(speed_te==8)))/size(y_pred(find(speed_te==8)),1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ind_un =find(speed_te==8);
% ind_4_l = find(exact_speed_te(:,1)>=0.49);
% ind_4_u = find(exact_speed_te(:,1)<=0.52);
% ind_4 = intersect(ind_4_l, ind_4_u);
% 
% method1 = intersect(ind_un,ind_4);
% method5 = setdiff(ind_un,ind_4);
% 
% [y_predlibsvm, acc, confi] = svmpredict(y_te(method1), sparse(x_te(method1,:)), modellibsvm,'-b 0');
% 
% num_trace = size(y_predlibsvm,1)/7;
% 
% for i = 1:num_trace
%     tmp = y_predlibsvm(7*(i-1)+1:7*i);
%     y_predlibsvm(7*(i-1)+1:7*i) = mode(tmp);
% end
% 
% y_pred_final = [y_pred(method5); y_predlibsvm];
% y_te_final = [y_te(method5); y_te(method1)];
% 
% confi_table = [pred_table_score(method5,:); confi];
% 
% acc_uncontrol_final = sum(y_pred_final==y_te_final)/size(y_te_final,1)


save([num2str(exp_id) '.mat']);
% save([num2str(exp_id) '.mat'],'speed_te','y_pred','y_te','acc','acc_after','acc_uncontrol_final','confi_table');

end

