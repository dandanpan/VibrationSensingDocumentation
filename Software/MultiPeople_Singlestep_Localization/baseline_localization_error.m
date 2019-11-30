close all;
clear ;

%% for cross data
% load('./result_side_by_side/trial_side_5.mat');
% load('./result_follow/trial5_follow_2p_3step_straight_rep6.mat');
load('./result_1person/baseline/trial1_baseline1.mat');
% based on the last step localization and 
last_step_person1=[2.28;-0.63]; % right
last_step_person2=[0.965;4.44]; %left
direction_person1=[0;1];
direction_person2=[0;-1];

% %% cross ground truth positions
% right_ground_truth=[2.49,0;2.49,0.63;2.49,1.26;2.49,1.89;2.49,2.52;2.49,3.15;2.49,3.78];
% left_ground_truth=[1.17,3.15;1.17,2.52;1.17,1.89;1.17,1.26;1.17,0.63;1.17,0;1.17,-0.63];

% %% sidebyside ground truth positions
% right_ground_truth=[2.49,0;2.49,0.63;2.49,1.26;2.49,1.89;2.49,2.52;2.49,3.15;2.49,3.78];
% left_ground_truth=[1.17,0;1.17,0.63;1.17,1.26;1.17,1.89;1.17,2.52;1.17,3.15;1.17,3.78];

%% follow ground truth right:back; left:front
right_ground_truth=[2.49,-0.63;2.49,0;2.49,0.63;2.49,1.26;2.49,1.89;2.49,2.52;2.49,3.15;2.49,3.78];
left_ground_truth=[2.49,0;2.49,0.63;2.49,1.26;2.49,1.89;2.49,2.52;2.49,3.15;2.49,3.78];

% %% for side by side data
% load('./result_022719/new_trial_cross_2p_result_2.mat');
% % based on the last step localization and 
% last_step_person1=[2.28;-0.63]; % right
% last_step_person2=[0.965;-0.63]; % left
% direction_person1=[0;1];
% direction_person2=[0;1];

localization_left=[];
localization_left_error=[];
localization_right=[];
localization_right_error=[];
num_step_left=0;
num_step_right=0;

for i=1:length(tdoa_4c) 
    
    
    %% cross 
%     if (find([1,3,5,7,9,12,14]==i)) % trial1 right
%     if (find([2,4,6,8,10,13]==i))  % trial2 right 
%     if (find([2,4,6,8,10,12,14]==i))  % trial3 right 
%       if (find([1,3,5,7,9,11,14]==i))  % trial4 right 
%       if (find([2,4,5,6,9,12,15]==i))  % trial5 right
%           if (find([2,4,6,8,11,13]==i))  % trial1 left
%           if(find([1,3,5,7,9,11,14]==i))  % trial2 left
%         if(find([1,3,5,7,9,11]==i))  % trial3 left
%         if(find([2,4,6,8,10,15]==i))  % trial4 left
%         if(find([1,3,11,14,16]==i))  % trial4 left

%% sidebyside
        if (find([5,7,8,10,11,12]==i)) % trial1 right
%             if (i==9 || i==11)
%                 
%             end
            num_step_right=num_step_right+1;

        %% for person 2
         right_ground_truth=[2.49,-0.63;2.49,0;2.49,0.63;2.49,1.26;2.49,1.89;2.49,2.52;2.49,3.15;2.49,3.78];

         right_ground_truth=right_ground_truth([1,4,5,6,7,8],:);
% right_ground_truth=[2.49,0;2.49,0.63;2.49,1.26;2.49,1.89;2.49,2.52;2.49,3.15;2.49,3.78];


            if(~isempty(matchedposition_4c{i}))
                localization=matchedposition_4c{i}(:,1);
            elseif(~isempty(matchedposition_3c{i}))
                localization=matchedposition_3c{i}(:,1);
            else
                disp(i);
                fprintf('no localization');
            end
            
            
        
        %% calculate the error
            localization_right=[localization_right;localization'];
            localization_right_error(num_step_right)=norm(localization_right(num_step_right,:)-right_ground_truth(num_step_right,:),2)
        end
        
        %% for left person:
        if (find([1,2,4,6]==i)) % trial1 right
%             if (i==8 || i==10)
%                 
%             end
            
            num_step_left=num_step_left+1;
            
            left_ground_truth=[2.49,0;2.49,0.63;2.49,1.26;2.49,1.89;2.49,2.52;2.49,3.15;2.49,3.78];
            left_ground_truth=left_ground_truth([1,2,3,4],:);

%          left_ground_truth=[1.17,0;1.17,0.63;1.17,1.26;1.17,1.89;1.17,2.52;1.17,3.15;1.17,3.78];

            if(~isempty(matchedposition_4c{i}))
                localization=matchedposition_4c{i}(:,1);
            elseif(~isempty(matchedposition_3c{i}))
                localization=matchedposition_3c{i}(:,1);
            else
                disp(i);
                fprintf('no localization');
            end
            
        
        %% calculate the error
            localization_left=[localization_left;localization'];
            localization_left_error(num_step_left)=norm(localization_left(num_step_left,:)-left_ground_truth(num_step_left,:),2)
        end
end

%
% %% right: get the mean and var
right_average=mean(localization_right_error);
right_sigma=var(localization_right_error);
save('./paper_result/baseline/random_choose_scale/follow/trail5_localization_result','localization_right',...
    'right_ground_truth','localization_right_error','right_average','right_sigma');

load('./paper_result/baseline/random_choose_scale/follow/class1_result');
if (~exist('class1_loc'))
    class1_loc=[];
    class1_loc_ground_truth=[];
end

% class1_loc=[class1_loc;localization_right(1,:)];
class1_loc=[class1_loc;localization_right(4:6,:)];

% class1_loc_ground_truth=[class1_loc_ground_truth;right_ground_truth(1,:)];
class1_loc_ground_truth=[class1_loc_ground_truth;right_ground_truth(4:6,:)];
save('./paper_result/baseline/random_choose_scale/follow/class1_result','class1_loc','class1_loc_ground_truth');

load('./paper_result/baseline/random_choose_scale/follow/class2_result');
if (~exist('class2_loc'))
    class2_loc=[];
    class2_loc_ground_truth=[];
end
class2_loc=[class2_loc;localization_right(1,:)];
% class2_loc=[class2_loc;localization_right(3,:)];
class2_loc_ground_truth=[class2_loc_ground_truth;right_ground_truth(1,:)];
% class2_loc_ground_truth=[class2_loc_ground_truth;right_ground_truth(3,:)];
save('./paper_result/baseline/random_choose_scale/follow/class2_result','class2_loc','class2_loc_ground_truth');

load('./paper_result/baseline/random_choose_scale/follow/class3_result');
if (~exist('class3_loc'))
    class3_loc=[];
    class3_loc_ground_truth=[];
end

% class3_loc=[class3_loc;localization_right(2:4,:)];
class3_loc=[class3_loc;localization_right(2:3,:)];
% class3_loc_ground_truth=[class3_loc_ground_truth;right_ground_truth(2:4,:)];
class3_loc_ground_truth=[class3_loc_ground_truth;right_ground_truth(2:3,:)];
save('./paper_result/baseline/random_choose_scale/follow/class3_result','class3_loc','class3_loc_ground_truth');

% %% left:get the mean and var

load('./paper_result/baseline/random_choose_scale/follow/trail5_localization_result');
left_average=mean(localization_left_error);
left_sigma=var(localization_left_error);
save('./paper_result/baseline/random_choose_scale/follow/trail5_localization_result','localization_right',...
    'right_ground_truth','localization_right_error','right_average','right_sigma',...
    'localization_left','left_ground_truth','localization_left_error','left_average','left_sigma');

load('./paper_result/baseline/random_choose_scale/follow/class1_result');

class1_loc=[class1_loc;localization_left(1:2,:)];
% class1_loc=[class1_loc;localization_left(1,:)];

class1_loc_ground_truth=[class1_loc_ground_truth;left_ground_truth(1:2,:)];
% class1_loc_ground_truth=[class1_loc_ground_truth;left_ground_truth(1,:)];
save('./paper_result/baseline/random_choose_scale/follow/class1_result','class1_loc','class1_loc_ground_truth');

load('./paper_result/baseline/random_choose_scale/follow/class2_result');
% class2_loc=[class2_loc;localization_left(4:6,:)];
class2_loc=[class2_loc;localization_left(3,:)];
% class2_loc_ground_truth=[class2_loc_ground_truth;left_ground_truth(4:6,:)];
class2_loc_ground_truth=[class2_loc_ground_truth;left_ground_truth(3,:)];
save('./paper_result/baseline/random_choose_scale/follow/class2_result','class2_loc','class2_loc_ground_truth');

load('./paper_result/baseline/random_choose_scale/follow/class3_result');
% class3_loc=[class3_loc;localization_left(7,:)];
class3_loc=[class3_loc;localization_left(4,:)];
% class3_loc_ground_truth=[class3_loc_ground_truth;left_ground_truth(7,:)];
class3_loc_ground_truth=[class3_loc_ground_truth;left_ground_truth(4,:)];
save('./paper_result/baseline/random_choose_scale/follow/class3_result','class3_loc','class3_loc_ground_truth');



% error=class3_loc-class3_loc_ground_truth;
% class3_error_final=sqrt(sum(error.^2,2));
% class3_error_average=mean(class3_error_final);
% class3_error_sigma=var(class3_error_final);
% clear error
% % 
% error=class2_loc-class2_loc_ground_truth;
% class2_error_final=sqrt(sum(error.^2,2));
% class2_error_average=mean(class2_error_final);
% class2_error_sigma=var(class2_error_final);
% clear error
% % 
% error=class1_loc-class1_loc_ground_truth;
% class1_error_final=sqrt(sum(error.^2,2));
% class1_error_average=mean(class1_error_final);
% class1_error_sigma=var(class1_error_final);
% clear error
% % 

% %&&&&&&&&&&&&&&&&&&&&&&& cross &&&&&&&&&&&&&&&&&&&&&&&
% % %% right: get the mean and var
% right_average=mean(localization_right_error);
% right_sigma=var(localization_right_error);
% save('./paper_result/cross_localization_result/trail5_localization_result','localization_right',...
%     'right_ground_truth','localization_right_error','right_average','right_sigma');
% 
% load('./paper_result/cross_localization_result/class1_result');
% % class1_loc=[];
% class1_loc=[class1_loc;localization_right(5:6,:)];
% % class1_loc_ground_truth=[];
% class1_loc_ground_truth=[class1_loc_ground_truth;right_ground_truth(5:6,:)];
% save('./paper_result/cross_localization_result/class1_result','class1_loc','class1_loc_ground_truth');
% 
% load('./paper_result/cross_localization_result/class2_result');
% % class2_loc=[];
% class2_loc=[class2_loc;localization_right(1,:)];
% % class2_loc_ground_truth=[];
% class2_loc_ground_truth=[class2_loc_ground_truth;right_ground_truth(1,:)];
% save('./paper_result/cross_localization_result/class2_result','class2_loc','class2_loc_ground_truth');
% 
% load('./paper_result/cross_localization_result/class3_result');
% % class3_loc=[];
% class3_loc=[class3_loc;localization_right(2:4,:)];
% class3_loc=[class3_loc;localization_right(7,:)];
% % class3_loc_ground_truth=[];
% class3_loc_ground_truth=[class3_loc_ground_truth;right_ground_truth(2:4,:)];
% class3_loc_ground_truth=[class3_loc_ground_truth;right_ground_truth(7,:)];
% save('./paper_result/cross_localization_result/class3_result','class3_loc','class3_loc_ground_truth');



% % %% left:get the mean and var
% 
% load('./paper_result/cross_localization_result/trail5_localization_result');
% left_average=mean(localization_left_error);
% left_sigma=var(localization_left_error);
% save('./paper_result/cross_localization_result/trail5_localization_result','localization_right',...
%     'right_ground_truth','localization_right_error','right_average','right_sigma',...
%     'localization_left','left_ground_truth','localization_left_error','left_average','left_sigma');
% 
% load('./paper_result/cross_localization_result/class1_result');
% class1_loc=[class1_loc;localization_left(3:4,:)];
% % class1_loc=[class1_loc;localization_left(6,:)];
% class1_loc_ground_truth=[class1_loc_ground_truth;left_ground_truth(3:4,:)];
% % class1_loc_ground_truth=[class1_loc_ground_truth;left_ground_truth(6,:)];
% save('./paper_result/cross_localization_result/class1_result','class1_loc','class1_loc_ground_truth');
% 
% load('./paper_result/cross_localization_result/class2_result');
% % class2_loc=[];
% class2_loc=[class2_loc;localization_left(1,:)];
% % class2_loc_ground_truth=[];
% class2_loc_ground_truth=[class2_loc_ground_truth;left_ground_truth(1,:)];
% save('./paper_result/cross_localization_result/class2_result','class2_loc','class2_loc_ground_truth');
% 
% load('./paper_result/cross_localization_result/class3_result');
% % class3_loc=[];
% class3_loc=[class3_loc;localization_left(2,:)];
% class3_loc=[class3_loc;localization_left(5,:)];
% % class3_loc_ground_truth=[];
% class3_loc_ground_truth=[class3_loc_ground_truth;left_ground_truth(2,:)];
% class3_loc_ground_truth=[class3_loc_ground_truth;left_ground_truth(5,:)];
% save('./paper_result/cross_localization_result/class3_result','class3_loc','class3_loc_ground_truth');
% 
% error=class1_loc-class1_loc_ground_truth;
% error_final=sqrt(sum(error.^2,2));
% error_average=mean(error_final);
% error_sigma=var(error_final);