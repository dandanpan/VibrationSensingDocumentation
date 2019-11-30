%% select the final localization from different scales' results and information from other steps
function [localization, scores,K_score] = SelectLocalization(last_step,direction,...
    tdoa_4c,all_score_4c,matchedposition_4c,all_scale_4c,...
    tdoa_3c,all_score_3c,matchedposition_3c,all_scale_3c)

%% draw the all localization
% geophones positions and persons positions
geophone_number=4;
geophone_position=[3.37,0.2,3.37,0.2;3.05,2.03,1.02,0];
figure;
plot(geophone_position(1,:),geophone_position(2,:),'r*');
hold on
% plot(true_step_position(:,1),true_step_position(:,2),'go');
% plot(localization_auto_person1(1,:),localization_auto_person1(2,:),'bo');
% plot(localization_auto_person2(1,:),localization_auto_person2(2,:),'ko');
if (~isempty(matchedposition_4c))
plot(matchedposition_4c(1,:),matchedposition_4c(2,:),'bo');
hold on
end
if (~isempty(matchedposition_3c))
    plot(matchedposition_3c(1,:),matchedposition_3c(2,:),'go');
end
% search from radius 0.5m - 1m
radius=0.5;
% get prediction from last step
footstep_length=0.7;
prediction=last_step+direction*footstep_length;
sigma=0.3;
% adjust by the scale's number 80-100 is the best almost for every one
alpha=1.3;
scale_select_thre=5;
% select 4 channels and 3 channels
number_4c=size(tdoa_4c,1);
final_score_4c=zeros(number_4c,1);
number_3c=size(tdoa_3c,1);
final_score_3c=zeros(number_3c,1);
% aa
score_prior_4c=zeros(number_4c,1);
score_prior_3c=zeros(number_3c,1);

if number_4c>0
    for i=1:number_4c
        score_prior_4c(i)=exp(10*norm(matchedposition_4c(:,i)-prediction));
         % normalize the prior score
        if (score_prior_4c(i)<1e-3)
            score_prior_4c(i)=1e-3;
        end
        % normalize the score
        if (all_score_4c(i)<1)
            all_score_4c(i)=1;
        end
        final_score_4c(i)=all_score_4c(i)*score_prior_4c(i); % select from scores
        % adjust by the scale's number 80-100 is the best almost for every one
        adjust_coe=1;
        if(all_scale_4c(i)<80 || all_scale_4c(i)>100)
            adjust_coe=alpha*min(abs(all_scale_4c(i)-80),abs(all_scale_4c(i)-100))/scale_select_thre;
        end
        final_score_4c(i)=final_score_4c(i)*adjust_coe; % select from scores
    end
end


minus_3c=1; % 3 channel one is less valuable than 4 channel one
if number_3c>0
    for i=1:number_3c
        score_prior_3c(i)=exp(10*norm(matchedposition_3c(:,i)-prediction));
        % normalize the prior score
        if (score_prior_3c(i)<1e-3)
            score_prior_3c(i)=1e-3;
        end
        % normalize the score
        if (all_score_3c(i)<1)
            all_score_3c(i)=1;
        end
        final_score_3c(i)=all_score_3c(i)*score_prior_3c(i)*minus_3c; % select from scores
        % adjust by the scale's number 80-100 is the best almost for every one
        adjust_coe=1;
        if(all_scale_3c(i)<80 || all_scale_3c(i)>100)
            adjust_coe=alpha*min(abs(all_scale_3c(i)-80),abs(all_scale_3c(i)-100))/scale_select_thre;
        end
        final_score_3c(i)=final_score_3c(i)*adjust_coe; % select from scores
    end
end

[t,pos]=sort([final_score_4c;final_score_3c]);
matchedposition=[matchedposition_4c,matchedposition_3c];
% adjust by the mean of several similar localization
localization=matchedposition(:,pos(1));
plot(localization(1),localization(2),'k*');
scores=t(1);
K_score=min(1,1/20/norm(localization-prediction));
% use the mean of several similar localization
end

