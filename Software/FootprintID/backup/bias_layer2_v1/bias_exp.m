bias_sys(1,20);
bias_sys(2,20);
bias_sys(3,20);
bias_sys(4,20);
bias_sys(5,20);
bias_sys(6,20);
bias_sys(7,20);
bias_sys(8,20);
bias_sys(9,20);


% num_trace_hist = [1 1 1 1 1 1 1 1 1 6];
% % num_trace_hist = [2 2 2 2 2 2 2 2 2 5];
% % num_trace_hist = [3 3 3 3 3 3 3 3 3 4];
% % 
% % num_trace_hist = [1 1 1 1 1 6 6 6 6 6];
% % num_trace_hist = [2 2 2 2 2 5 5 5 5 5];
% % num_trace_hist = [3 3 3 3 3 4 4 4 4 4];
% % 
% % num_trace_hist = [1 6 6 6 6 6 6 6 6 6];
% % num_trace_hist = [2 5 5 5 5 5 5 5 5 5];
% % num_trace_hist = [3 4 4 4 4 4 4 4 4 4];
%     
% acc_list1 = [];
% acc_list2 = [];
% acc_list3 = [];
% acc_list4 = [];
% 
% for i = 1:20
%     num_trace_per = num_trace_hist(randperm(10));
%     
%     [ acc_nosemi_novoting, acc_nosemi_voting, acc_semi_novoting, acc_semi_voting ]...
%         = bias_fun( num_trace_per );
%     
%     acc_list1 = [acc_list1 acc_nosemi_novoting];
%     acc_list2 = [acc_list2 acc_nosemi_voting];
%     acc_list3 = [acc_list3 acc_semi_novoting];
%     acc_list4 = [acc_list4 acc_semi_voting];
% 
% end