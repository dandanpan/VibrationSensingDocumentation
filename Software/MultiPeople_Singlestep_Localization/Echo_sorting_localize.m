function [d_best, sort_number,best_score] = Echo_sorting_localize(geophone_position,D, d1, cell_distance,already_matching,first_peak)


geophone_number=length(cell_distance);

s_best=1e6; % let s_best be bigger enough
position=zeros(2,1);
sort_number=zeros(geophone_number,1);
sort_number(1)=first_peak;
peaks_num_everygeophone=zeros(geophone_number,1);
for i=2:geophone_number
    peaks_num_everygeophone(i)=length(cell_distance{i});
end

for i=1:peaks_num_everygeophone(2) % tai chou le
    d=[d1;cell_distance{2}(i)]; % d is column vector
    
    for j=1:peaks_num_everygeophone(3)
        d=[d1;cell_distance{2}(i);cell_distance{3}(j)];
        
        for k=1:peaks_num_everygeophone(4)
            [first_peak,i,j,k]
            check=1;       % check if it is the same matching of peaks
            [a,already_matching_num]=size(already_matching);
            for checki=1:already_matching_num % remove the same matching
                if([first_peak;i;j;k]==already_matching(:,checki))
                    check=0;
                    break;
                end
            end
            if(check==1)
                d=[d1;cell_distance{2}(i);cell_distance{3}(j);cell_distance{4}(k)];
                D_augment=[D,d;d',0]; % D_augment is 5*5
                [score,new_position]=sstress_score_localize(geophone_position,d)
                score
                if(score<s_best)
                    s_best=score;
                    position=new_position;
                    sort_number(2:geophone_number)=[i,j,k];
                end
            end
        end

    end
end

d_best=position;
best_score=s_best;
% sort_number is sort_number
end



