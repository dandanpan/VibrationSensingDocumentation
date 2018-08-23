acc_list = [];

acc_total_list = [];
acc_trace_total_list = [];


for jj = 1:5
    clear acc_nosemi_voting
    clear acc_semi_novoting
    clear acc_nosemi_voting
    clear acc_semi_voting
    clear speed_te
    clear y_pred
    clear y_te
    clear pred_per
    clear label_per
    
    load(['case1_' num2str(jj) '.mat']);
    
    for ii = 1:7
        ind_per = find(speed_te == ii);
        pred_per = y_pred(ind_per);
        label_per = y_te(ind_per);
        
        acc_per = sum(pred_per==label_per)/size(pred_per,1);
        acc_list = [acc_list acc_per];
    end
    
    if jj == 1
        acc_total_list = [acc_total_list acc_nosemi_novoting];
        acc_trace_total_list = [acc_trace_total_list acc_nosemi_voting];
    else
        acc_total_list = [acc_total_list acc_semi_novoting];
        acc_trace_total_list = [acc_trace_total_list acc_semi_voting];
    end
end

acc_table = reshape(acc_list,[7 5])';
bar(acc_table')