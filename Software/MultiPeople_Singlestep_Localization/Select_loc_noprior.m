%% select the final localization from different scales' results and information from other steps
function [localization, scores] = Select_loc_noprior(...
    tdoa_4c,all_score_4c,matchedposition_4c,all_scale_4c,...
    tdoa_3c,all_score_3c,matchedposition_3c,all_scale_3c)

%% draw the all localization
% geophones positions and persons positions
geophone_number=4;
%% the porterhall geophone position
% geophone_position=[3.37,0.2,3.37,0.2;3.05,2.03,1.02,0];
% the old people geophone position trail 1 
geophone_position=[0.1,1.55,0.1,1.55;0.61,1.12,1.63,2.14];
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

% select 4 channels and 3 channels
number_4c=size(tdoa_4c,1);
final_score_4c=zeros(number_4c,1);
number_3c=size(tdoa_3c,1);
final_score_3c=zeros(number_3c,1);
% PorterHall: remove the localizations which are not 
x_thre=[0,3.5];
y_thre=[-1,4];

% oldpeople: remove the localizations which are not
x_thre=[0.1,1.5];
y_thre=[0,3];
if number_4c>0
    remove_4c_x=[find(matchedposition_4c(1,:)<x_thre(1)),find(matchedposition_4c(1,:)>x_thre(2))];
    remove_4c_y=[find(matchedposition_4c(2,:)<y_thre(1)),find(matchedposition_4c(2,:)>y_thre(2))];
    remove_4c=union(remove_4c_x,remove_4c_y);
    
    
    all_score_4c(remove_4c)=[];
    matchedposition_4c(:,remove_4c)=[];
end

if number_3c>0
    remove_3c_x=[find(matchedposition_3c(1,:)<x_thre(1)),find(matchedposition_3c(1,:)>x_thre(2))];
    remove_3c_y=[find(matchedposition_3c(2,:)<y_thre(1)),find(matchedposition_3c(2,:)>y_thre(2))];
    remove_3c=union(remove_3c_x,remove_3c_y);
    all_score_3c(remove_3c)=[];
    matchedposition_3c(:,remove_3c)=[];
end

%% selected the best localization from 4channel results
if(~isempty(all_score_4c))
    %% get the trust region
    low_trust=1;
    high_trust=3;
    trust_region=intersect(find(all_score_4c>low_trust),find(all_score_4c<high_trust));
    if (~isempty(trust_region))
        [t,pos]=sort(all_score_4c(trust_region));
        localization_4c=matchedposition_4c(:,trust_region(pos(1)));
        plot(localization_4c(1),localization_4c(2),'k*');
        scores_4c=t(1)
    else
        [t,pos]=sort(all_score_4c);
        if(length(all_score_4c)>=2 && t(1)<low_trust)
            localization_4c=1/2*(matchedposition_4c(:,pos(1))+matchedposition_4c(:,pos(2)));
            plot(localization_4c(1),localization_4c(2),'k*');
            scores_4c=mean(t(1:2));
        else
            localization_4c=matchedposition_4c(:,pos(1));
            plot(localization_4c(1),localization_4c(2),'k*');
            scores_4c=t(1)
        end
    end
end
%% selected the best localization from 3channel results
if(~isempty(all_score_3c))
    [t,pos]=sort(all_score_3c);
    localization_3c=matchedposition_3c(:,pos(1));

    plot(localization_3c(1),localization_3c(2),'k*');
    scores_3c=t(1);
end
% use the mean of several similar localization
if (length(all_score_4c)>=length(all_score_3c) || length(all_score_4c)>=3 )
    localization=localization_4c;
    scores=scores_4c;
else
    localization=localization_3c;
    scores=scores_3c;
end

