function [] = bias_sys( num, num_exp )

if num == 1
    num_trace_hist = [1 1 1 1 1 1 1 1 1 6];
elseif num == 2
    num_trace_hist = [2 2 2 2 2 2 2 2 2 5];
elseif num == 3
    num_trace_hist = [3 3 3 3 3 3 3 3 3 4];
elseif num == 4
    num_trace_hist = [1 1 1 1 1 6 6 6 6 6];
elseif num == 5
    num_trace_hist = [2 2 2 2 2 5 5 5 5 5];
elseif num == 6
    num_trace_hist = [3 3 3 3 3 4 4 4 4 4];
elseif num == 7
    num_trace_hist = [1 6 6 6 6 6 6 6 6 6];
elseif num == 8
    num_trace_hist = [2 5 5 5 5 5 5 5 5 5];
elseif num == 9
    num_trace_hist = [3 4 4 4 4 4 4 4 4 4];
end
% num_trace_hist = [2 2 2 2 2 2 2 2 2 5];
% num_trace_hist = [3 3 3 3 3 3 3 3 3 4];
%
% num_trace_hist = [1 1 1 1 1 6 6 6 6 6];
% num_trace_hist = [2 2 2 2 2 5 5 5 5 5];
% num_trace_hist = [3 3 3 3 3 4 4 4 4 4];
%
% num_trace_hist = [1 6 6 6 6 6 6 6 6 6];
% num_trace_hist = [2 5 5 5 5 5 5 5 5 5];
% num_trace_hist = [3 4 4 4 4 4 4 4 4 4];

acc_list1 = [];
acc_list2 = [];
acc_list3 = [];
acc_list4 = [];

for i = 1:num_exp
    num_trace_per = num_trace_hist(randperm(10));
    
    [ acc_nosemi_novoting, acc_nosemi_voting, acc_semi_novoting, acc_semi_voting ]...
        = bias_fun( num_trace_per );
    
    acc_list1 = [acc_list1 acc_nosemi_novoting];
    acc_list2 = [acc_list2 acc_nosemi_voting];
    acc_list3 = [acc_list3 acc_semi_novoting];
    acc_list4 = [acc_list4 acc_semi_voting];
    
end

save(['bias' num2str(num) '.mat'],'acc_list1','acc_list2','acc_list3','acc_list4');

end

