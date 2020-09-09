function [] = bias_sys( num, num_exp )

if num == 1
    num_trace_hist = [1 1 1 1 1 1 1 1 1 8];
elseif num == 2
    num_trace_hist = [2 2 2 2 2 2 2 2 2 7];
elseif num == 3
    num_trace_hist = [3 3 3 3 3 3 3 3 3 6];
elseif num == 4
    num_trace_hist = [4 4 4 4 4 4 4 4 4 5];
elseif num == 5
    num_trace_hist = [1 1 1 1 1 8 8 8 8 8];
elseif num == 6
    num_trace_hist = [2 2 2 2 2 7 7 7 7 7];
elseif num == 7
    num_trace_hist = [3 3 3 3 3 6 6 6 6 6];
elseif num == 8
    num_trace_hist = [4 4 4 4 4 5 5 5 5 5];
elseif num == 9
    num_trace_hist = [1 8 8 8 8 8 8 8 8 8];
elseif num == 10
    num_trace_hist = [2 7 7 7 7 7 7 7 7 7];
elseif num == 11
    num_trace_hist = [3 6 6 6 6 6 6 6 6 6];
elseif num == 12
    num_trace_hist = [4 5 5 5 5 5 5 5 5 5];
end


acc_list1 = [];
acc_list2 = [];
acc_list3 = [];
acc_list4 = [];

for i = 1:num_exp
    num_trace_per = num_trace_hist(randperm(10));
%     num_trace_per = num_trace_hist;
    trace_random = circshift((1:10)',i)';
    
    [ acc_nosemi_novoting, acc_nosemi_voting, acc_semi_novoting, acc_semi_voting ]...
        = bias23( num_trace_per,trace_random, [i num] );
    
    acc_list1 = [acc_list1 acc_nosemi_novoting];
    acc_list2 = [acc_list2 acc_nosemi_voting];
    acc_list3 = [acc_list3 acc_semi_novoting];
    acc_list4 = [acc_list4 acc_semi_voting];
    
end

% save(['bias' num2str(num) '.mat'],'acc_list1','acc_list2','acc_list3','acc_list4');

end

