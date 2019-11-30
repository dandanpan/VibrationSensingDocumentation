function [d_best,best_score] = Echo_sorting_velocity_scale(geophone_position,D,tdoa_pairs,velocity)

geophone_number=length(tdoa_pairs(1,:));

s_best=1e6; % let s_best be bigger enough
[peaks_num_everygeophone,~]=size(tdoa_pairs);
d_best=zeros(2,length(peaks_num_everygeophone));
best_score=zeros(length(peaks_num_everygeophone),1);
position=zeros(2,1);
for i=1:peaks_num_everygeophone % tai chou le
    d=tdoa_pairs(i,:)'; % d is column vector
    % record score for testing
    score_all=zeros(length(velocity),1);
    s_best=1e6; % let s_best be bigger enough
    for j=1:length(velocity);
        d_velocity=d*velocity(j);
        D_augment=[D,d_velocity;d_velocity',0]; % D_augment is 5*5
        [score,new_position]=sstress_score_new(geophone_position,d_velocity);
        score_all(j)=score;
        if(score<s_best)
            s_best=score;
            position=new_position;
        end
    end
    d_best(:,i)=position;
    best_score(i)=s_best;
% sort_number is sort_number
end
end



