function [ acc_nosemi_novoting, acc_nosemi_voting, acc_semi_novoting, acc_semi_voting ]...
    = exp1_1( trace_random, exp_id  )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 0.2893 0.3849
% setpath for library


addpath('svml-master/')
addpath('libsvm-3.22/matlab/')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load data and map to correct speed

load uncontrol2.mat
i1 = find(speedIDLabel==1);
i2 = find(speedIDLabel==2);
i3 = find(speedIDLabel==3);
i4 = find(speedIDLabel==4);
i5 = find(speedIDLabel==5);
i6 = find(speedIDLabel==6);
i7 = find(speedIDLabel==7);
i8 = find(speedIDLabel==8);

speedIDLabel(i1) = 4;
speedIDLabel(i2) = 5;
speedIDLabel(i3) = 6;
speedIDLabel(i4) = 7;
speedIDLabel(i5) = 3;
speedIDLabel(i6) = 2;
speedIDLabel(i7) = 1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ind_trace_tr = trace_random(1:6);
ind_trace_te = [trace_random(7:10) 11];


ind_speed_tr = [4];
ind_speed_te = [8];

% ind_speed_tr = [3 4 5];
% ind_speed_te = [1 2 6 7];

using_speed_feature = 1;
using_smart_semi = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% training and test data generation

x_tr = [];
x_te = [];

y_tr = [];
y_te = [];

for i = ind_trace_tr
    
    ind_select = find(traceIDLabel==i);
    speed_select = [];
    for j = ind_speed_tr    
        speed_select = [speed_select; find(speedIDLabel==j)];
    end
    both_select = intersect(ind_select,speed_select);
    if using_speed_feature
        x_tr = [x_tr; stepInfoAll(both_select,5) stepPattern(both_select,:)];
    else
        x_tr = [x_tr; stepPattern(both_select,:)];
    end
    y_tr = [y_tr; personIDLabel(both_select,:)];
    
end
speed_te =[];
for i = ind_trace_te
    ind_select = find(traceIDLabel==i);
    speed_select = [];
   
    for j = ind_speed_te
        speed_select = [speed_select; find(speedIDLabel==j)];
    end
    both_select = intersect(ind_select,speed_select);
    
    if using_speed_feature
        
        x_te = [x_te; stepInfoAll(both_select,5) stepPattern(both_select,:)];
    else
        x_te = [x_te; stepPattern(both_select,:)];
    end
    y_te = [y_te; personIDLabel(both_select,:)];
    
    speed_te = [speed_te; speedIDLabel(both_select)];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% training and test data scaling to [0 1]

num_dim = size(x_tr,2);

x_tr_scale = zeros(size(x_tr));
x_te_scale = zeros(size(x_te));

for d = 1:num_dim
    up = max(x_tr(:,d));
    low = min(x_tr(:,d));
    
    
    x_tr_scale(:,d) = (x_tr(:,d)-low)/(up-low);
    x_te_scale(:,d) = (x_te(:,d)-low)/(up-low);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% evaluated by libsvm

m = svmtrain(y_tr, sparse(x_tr_scale), '-c 16 -g 1 -b 1 -q');
[y_pred, acc, confi] = svmpredict(y_te, sparse(x_te_scale), m,'-b 1');

acc_nosemi_novoting = sum(y_pred==y_te)/size(y_pred,1);

num_trace = size(y_pred,1)/7;

y_conf = zeros(size(y_pred));

for i = 1:num_trace
    tmp = y_pred(7*(i-1)+1:7*i);
    y_pred(7*(i-1)+1:7*i) = mode(tmp);
    y_conf(7*(i-1)+1:7*i) = sum(tmp== mode(tmp));
end

acc_nosemi_voting = sum(y_pred==y_te)/size(y_pred,1);

confusion_table = confusionmat(y_te, y_pred);

acc_semi_novoting=acc_nosemi_novoting;
acc_semi_voting=acc_nosemi_voting;

save([num2str(exp_id) '.mat'],'speed_te','y_pred','y_te','confusion_table');
end

% acc_list = [];
% for i = 1:7
%     ind_per = find(y_te == i);
%     pred_per = y_pred(ind_per);
%     label_per = y_te(ind_per);
%     acc_per = sum(pred_per==label_per)/size(pred_per,1);
%     acc_list = [acc_list acc_per];
% end