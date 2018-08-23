function [list, num_list] = confi_trace(data_name)

addpath('libsvm-3.22/matlab/')

load(data_name)

ind_un =find(speed_te==8);
ind_4_l = find(exact_speed_te(:,1)>=0.49);
ind_4_u = find(exact_speed_te(:,1)<=0.52);
ind_4 = intersect(ind_4_l, ind_4_u);

method1 = intersect(ind_un,ind_4);
method5 = setdiff(ind_un,ind_4);

[y_predlibsvm, acc, confi] = svmpredict(y_te(method1), sparse(x_te(method1,:)), modellibsvm,'-b 0');

num_trace = size(y_predlibsvm,1)/7;

for i = 1:num_trace
    tmp = y_predlibsvm(7*(i-1)+1:7*i);
    y_predlibsvm(7*(i-1)+1:7*i) = mode(tmp);
end

y_pred_final = [y_pred(method5); y_predlibsvm];
y_te_final = [y_te(method5); y_te(method1)];

confi_table = [pred_table_score(method5,:); confi];

% y_pred_final = [y_pred(method5); y_predlibsvm];
% y_te_final = [y_te(method5); y_te(method1)];
% 
% confi_table = [pred_table_score(method5,:); confi];

acc_uncontrol_final = sum(y_pred_final==y_te_final)/size(y_te_final,1)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
confi_table1 = confi_table;
confi_table = abs(confi_table);
confi_table_norm = zeros(size(confi_table));

for i = 1:size(confi_table,2)
    up = max(confi_table(:,i));
    low = min(confi_table(:,i));
    confi_table_norm(:,i) = (confi_table(:,i)-low)/(up-low);
end

pred_table = [];
count = 0;
for i = 1:10
    for j = i+1:10
        count = count + 1;
        
        pred = confi_table1(:,count);
        pred(pred>=0) = i;
        pred(pred<0) = j;
        pred_table = [pred_table pred];
    end
end

pred_multi = mode(pred_table,2);
pred_multi1 = pred_multi;
num_trace = size(pred_multi,1)/7;
y_conf = zeros(size(pred_multi));

for i = 1:num_trace
    tmp = pred_multi(7*(i-1)+1:7*i);
    pred_multi(7*(i-1)+1:7*i) = mode(tmp);
end

for i = 1:size(pred_multi,1)
    ind = find(pred_table(i,:) == pred_multi1(i));
    
    y_conf(i) = sum(confi_table_norm(i,ind));
end


y_pred_trace = zeros(size(y_conf,1)/7,1);
y_te_trace = zeros(size(y_conf,1)/7,1);
y_conf_trace = zeros(size(y_conf,1)/7,1);

for i = 1:size(y_conf,1)/7
    ind_start = (i-1)*7+1;
    ind_end = (i-1)*7+7;
    y_pred_trace(i) = mode(y_pred_final(ind_start:ind_end));
    y_te_trace(i) = mode(y_te_final(ind_start:ind_end));

    tmp = pred_multi1(7*(i-1)+1:7*i);
    ind = pred_multi1(7*(i-1)+1:7*i) == mode(tmp);
    ind_range = ind_start:ind_end;
    y_conf_trace(i) = sum(y_conf(ind_range(ind)));
end

list = [];
num_list = [];
% for i = min(y_conf_trace):7:max(y_conf_trace)
for i = 0:3.5:70
    acc_uncontrol_select = sum(y_pred_trace(y_conf_trace>i)==y_te_trace(y_conf_trace>i))...
        /size(y_te_trace(y_conf_trace>i),1)
    list = [list acc_uncontrol_select];
    num_list = [num_list sum(y_conf_trace>i)];
end
% figure
% plot(list)
% hold on
% plot(num_list/40,'r')
% 
end


