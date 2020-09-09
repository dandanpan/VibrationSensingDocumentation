function [] = cv_sys( num, num_exp, down_set)

acc_list1 = [];
acc_list2 = [];
acc_list3 = [];
acc_list4 = [];
tmp = 1:10;

rand_exp = 0;
if isempty(down_set)
   rand_exp = 1; 
end


for i = 1:num_exp
    trace_random = circshift((1:10)',i)';
    if rand_exp
        down_set = sort(randsample(7,3)');
    end

    if num == 1
        [ acc_nosemi_novoting, acc_nosemi_voting, acc_semi_novoting, acc_semi_voting ]...
        = exp1_1( trace_random, [i num],down_set);
    elseif num == 2
        [ acc_nosemi_novoting, acc_nosemi_voting, acc_semi_novoting, acc_semi_voting ]...
        = exp1_2( trace_random, [i num],down_set);
    elseif num == 3
        [ acc_nosemi_novoting, acc_nosemi_voting, acc_semi_novoting, acc_semi_voting ]...
        = exp1_3( trace_random, [i num],down_set);
    elseif num == 4
        [ acc_nosemi_novoting, acc_nosemi_voting, acc_semi_novoting, acc_semi_voting ]...
        = exp1_4( trace_random, [i num],down_set);
    elseif num == 5
        [ acc_nosemi_novoting, acc_nosemi_voting, acc_semi_novoting, acc_semi_voting ]...
        = exp1_5( trace_random, [i num],down_set);
    elseif num == 6
        [ acc_nosemi_novoting, acc_nosemi_voting, acc_semi_novoting, acc_semi_voting ]...
        = exp1_6( trace_random, [i num],down_set);
    elseif num == 7
        [ acc_nosemi_novoting, acc_nosemi_voting, acc_semi_novoting, acc_semi_voting ]...
        = exp1_7( trace_random, [i num],down_set);
    elseif num == 8
        [ acc_nosemi_novoting, acc_nosemi_voting, acc_semi_novoting, acc_semi_voting ]...
        = exp1_8( trace_random, [i num],down_set);
    end
 
    acc_list1 = [acc_list1 acc_nosemi_novoting];
    acc_list2 = [acc_list2 acc_nosemi_voting];
    acc_list3 = [acc_list3 acc_semi_novoting];
    acc_list4 = [acc_list4 acc_semi_voting];
    
    
    
end

% save(['cv_exp' num2str(num) '.mat'],'acc_list1','acc_list2','acc_list3','acc_list4');

end

