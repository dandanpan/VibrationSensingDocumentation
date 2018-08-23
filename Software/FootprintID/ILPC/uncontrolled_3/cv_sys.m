function [] = cv_sys( num, num_exp )

acc_list1 = [];
acc_list2 = [];
acc_list3 = [];
acc_list4 = [];
tmp = 1:10;

for ii = 1:num_exp
    trace_random = circshift((1:10)',ii)';
    
    if num == 1
        [ acc_nosemi_novoting, acc_nosemi_voting, acc_semi_novoting, acc_semi_voting ]...
        = exp1_1( trace_random, [ii num]);
    elseif num == 2
        [ acc_nosemi_novoting, acc_nosemi_voting, acc_semi_novoting, acc_semi_voting ]...
        = exp1_2( trace_random, [ii num]);
    elseif num == 3
        [ acc_nosemi_novoting, acc_nosemi_voting, acc_semi_novoting, acc_semi_voting ]...
        = exp1_3( trace_random, [ii num]);
    elseif num == 4
        [ acc_nosemi_novoting, acc_nosemi_voting, acc_semi_novoting, acc_semi_voting ]...
        = exp1_4( trace_random, [ii num]);
    elseif num == 5
        [ acc_nosemi_novoting, acc_nosemi_voting, acc_semi_novoting, acc_semi_voting ]...
        = exp1_5( trace_random, [ii num]);
    elseif num == 6
        [ acc_nosemi_novoting, acc_nosemi_voting, acc_semi_novoting, acc_semi_voting ]...
        = exp1_6( trace_random, [ii num]);
    elseif num == 7
        [ acc_nosemi_novoting, acc_nosemi_voting, acc_semi_novoting, acc_semi_voting ]...
        = exp1_7( trace_random, [ii num]);
    elseif num == 8
        [ acc_nosemi_novoting, acc_nosemi_voting, acc_semi_novoting, acc_semi_voting ]...
        = exp1_8( trace_random, [ii num]);
    end
 
    acc_list1 = [acc_list1 acc_nosemi_novoting];
    acc_list2 = [acc_list2 acc_nosemi_voting];
    acc_list3 = [acc_list3 acc_semi_novoting];
    acc_list4 = [acc_list4 acc_semi_voting];
    
end

% save(['cv_exp' num2str(num) '.mat'],'acc_list1','acc_list2','acc_list3','acc_list4');

end

