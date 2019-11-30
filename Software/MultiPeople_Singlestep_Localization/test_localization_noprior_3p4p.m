close all;
clear ;
%% for cross data
% load('./result_side_by_side/trial_side_5.mat');
% load('./result_follow/trial5_follow_2p_3step_straight_rep6.mat');
% load('./result_3p_cross/control/sidebyside/trial5.mat');
% based on the last step localization and 
% load('./result_3p_cross/uncontrol/10_min/baseline/follow2_base3.mat');
% load('./result_3p_cross/uncontrol/10_min/baseline/sidebyside_trail2_base3.mat');
% load('./result_3p_cross/uncontrol/10_min/baseline/person1_base3.mat');
load('./result_oldpeople/person1_trail1.mat');
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

% %% follow ground truth right:back; left:front
% right_ground_truth=[2.49,-0.63;2.49,0;2.49,0.63;2.49,1.26;2.49,1.89;2.49,2.52;2.49,3.15;2.49,3.78];
% left_ground_truth=[2.49,0;2.49,0.63;2.49,1.26;2.49,1.89;2.49,2.52;2.49,3.15;2.49,3.78];
% 
% % %% uncontrol 3p cross ground truth
%  first_ground_truth=[1.17,-0.63;1.17,0;1.17,0.63;1.17,1.26;1.17,1.89;1.17,2.52;1.17,3.15;1.17,3.78];
%  second_ground_truth=[1.83,-0.4;1.839,0.13;1.83,0.66;1.83,1.19;1.83,1.72;1.83,2.25;1.83,2.8;1.83,3.33];
%  third_ground_truth=[2.29,-0.4;2.29,0.25;2.29,0.9;2.29,1.54;2.29,2.196;2.29,2.84;2.29,3.489];

% % %% uncontrol 4p cross ground truth
%  first_ground_truth=[0.91,-0.2;0.91,0.43;0.91,1.26;0.76,2;0.76,2.7;0.76,3.4;0.76,4.1;0.76,4.8];
%  second_ground_truth=[1.83,0;1.72,0.63;1.63,1.4;1.52,2.2;1.52,2.8;1.52,3.4;1.52,4.0];
%  third_ground_truth=[2.33,4.2;2.33,3.65;2.33,3.1;2.33,2.5;2.33,1.95;2.33,1.4;2.33,0.85;2.33,0.3;2.33,-0.2];
%  forth_ground_truth=[2.9,4.4;2.9,3.8;2.9,3.2;2.9,2.7;2.9,2.05;2.9,1.4;2.9,0.8;2.9,0.2];

% % %% uncontrol 4p sidebyside ground truth
%  first_ground_truth=[0.61,-0.65;0.73,0;0.85,0.7;0.97,1.4;1.09,2.1;1.21,2.8;1.21,3.5];
%  second_ground_truth=[1.31,-0.65;1.31,0;1.31,0.75;1.31,1.5;1.31,2.2;1.31,2.8;1.31,3.5];
%  third_ground_truth=[1.98,-0.7;1.98,0;1.98,0.6;1.98,1.4;1.98,1.9;1.98,2.55;1.98,3.2];
%  forth_ground_truth=[2.44,-0.5;2.44,0;2.44,0.65;2.44,1.35;2.44,2;2.44,2.6;2.44,3.1];

% %% control 3p cross1 ground truth
% first_ground_truth=[0.91,0;0.91,0.63;0.91,1.26;0.91,1.89;0.91,2.52;0.91,3.15;0.91,3.78];
% second_ground_truth=[1.45,0;1.45,0.63;1.45,1.26;1.45,1.89;1.45,2.52;1.45,3.15;1.45,3.78]; % for trail 2-5
% % second_ground_truth=[1.45,0.1;1.45,0.8;1.45,1.5;1.45,2.2;1.45,2.8;1.45,3.5];  % for trail 1
% third_ground_truth=[2.49,3.78;2.49,3.15;2.49,2.52;2.49,1.89;2.49,1.26;2.49,0.63;2.49,0;2.49,-0.63];

% %% control 3p cross inter ground truth
% first_ground_truth=[1.17,0;1.17,0.63;1.17,1.26;1.17,1.89;1.17,2.52;1.17,3.15;1.17,3.78];  % for normal trail
% first_ground_truth=[1.17,-0.63;1.17,0;1.17,0.63;1.17,1.26;1.17,1.89;1.17,2.52;1.17,3.15;1.17,3.78]; % for trail 3
% second_ground_truth=[1.83,3.15;1.83,2.52;1.83,1.89;1.83,1.26;1.83,0.63;1.83,0;1.83,-0.63]; % for normal trail
% third_ground_truth=[2.49,0;2.49,0.63;2.49,1.26;2.49,1.89;2.49,2.52;2.49,3.15;2.49,3.78];
% 

% % %%  control 3p sidebyside inter ground truth
% first_ground_truth=[1.17,0;1.17,0.63;1.17,1.26;1.17,1.89;1.17,2.52;1.17,3.15;1.17,3.78];
% second_ground_truth=[1.83,0;1.83,0.63;1.83,1.26;1.83,1.89;1.83,2.52;1.83,3.15;1.83,3.78];
% third_ground_truth=[2.49,0;2.49,0.63;2.49,1.26;2.49,1.89;2.49,2.52;2.49,3.15;2.49,3.78];


%% 1 person ground truth
% first_ground_truth=[1.17,0;1.17,0.63;1.17,1.26;1.17,1.89;1.17,2.52;1.17,3.15;1.17,3.78];


%% uncontrol 10 min results
% % trial 1
% first_ground_truth=[1.12,-0.63;1.21,0.3;1.31,1.16;1.67,1.89;1.98,2.62;2.29,3.35;2.6,4.08];
% second_ground_truth=[1.93,-0.63;1.93,0.1;2.2,0.73;2.33,1.5;2.63,2;2.63,2.7;2.63,3.4];


% % trial 2
% first_ground_truth=[2.18,-0.63;2.13,0.1;2.1,0.75;2.33,1.5;2.33,2.15;2.45,2.8];
% second_ground_truth=[1.12,0;1.32,0.63;1.32,1.35;1.83,2;1.93,2.65;2.13,3.3];

% % trial 3
% first_ground_truth=[1.21,-0.63;1.21,0;1.31,0.73;1.21,1.36;1.25,2.1;1.05,2.7;1,3.3;1,3.95];
% second_ground_truth=[2.18,-0.63;2.13,0;2.23,0.73;2.13,1.46;2.23,2.1;2.34,2.7;2.49,3.3;2.49,3.95];


% % trial 4
% first_ground_truth=[1.02,-0.6;1.12,0.1;1.12,0.75;1.22,1.35;1.3,2;1.52,2.5;1.72,3;1.92,3.5];
% second_ground_truth=[2.13,-0.53;2.23,0.2;2.13,0.83;2.28,1.38;2.28,2;2.4,2.65;2.6,3.1;2.8,3.65];

% % trial 5
% first_ground_truth=[2.49,-0.3;1.98,0.1;1.82,0.7;1.42,1.26;1.21,1.89;1.21,2.5;0.9,3;0.5,3.6];
% second_ground_truth=[0.5,3.7;0.9,3.4;1.2,3;1.4,2.4;1.8,1.8;1.98,1.2;2.13,0.53;2.23,-0.2];

%% old people 
% trial 1
first_ground_truth=[1.07,0.18;0.81,0.61;1.32,0.81;0.91,0.97;0.76,1.42;1.32,1.52;0.91,1.78;0.76,1.8;1.32,2.33];
first_ground_truth=[];
second_ground_truth=[];

localization_1=[];
localization_1_error=[];
localization_2=[];
localization_2_error=[];
localization_3=[];
localization_3_error=[];
localization_4=[];
localization_4_error=[];
num_step_1=0;
num_step_2=0;
num_step_3=0;
num_step_4=0;

for i=1:length(tdoa_4c) 
    if(i==9)
        i
    end
    
    
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
        if (find([1,3,6,8,10,11,13,16]==i)) % trial1 right
%             if (i==9 || i==11)
%                 
%             end
            num_step_1=num_step_1+1;

        %% for person 1
%        first_ground_truth=[1.21,0.3;1.31,1.16;1.67,1.89;1.98,2.62;2.29,3.35;2.6,4.08];
%         first_ground_truth=[2.18,-0.63;2.13,0.1;2.1,0.75;2.33,1.5;2.33,2.15;2.45,2.8];
%         first_ground_truth=[1.21,-0.63;1.21,0;1.31,0.73;1.21,1.36;1.25,2.1;1.05,2.7;1,3.3;1,3.95];
%         first_ground_truth=[1.02,-0.6;1.12,0.1;1.12,0.75;1.22,1.35;1.3,2;1.52,2.5;1.72,3;1.92,3.5];
%         first_ground_truth=[2.49,-0.3;1.98,0.1;1.82,0.7;1.42,1.26;1.21,1.89;1.21,2.5;0.9,3;0.5,3.6];
        
        first_ground_truth=[1.07,0.18;0.81,0.61;1.32,0.81;0.91,0.97;0.76,1.42;1.32,1.52;0.91,1.78;0.76,1.8;1.32,2.33];

 
 
         first_ground_truth=first_ground_truth([1,2,3,4,5,6,8,9],:);
 
            [localization,scores] = Select_loc_noprior(...
            tdoa_4c{i},all_score_4c{i},matchedposition_4c{i},all_scale_4c{i},...
            tdoa_3c{i},all_score_3c{i},matchedposition_3c{i},all_scale_3c{i});
        
        %% calculate the error
            localization_1=[localization_1;localization'];
            localization_1_error(num_step_1)=norm(localization_1(num_step_1,:)-first_ground_truth(num_step_1,:),2)
        end
        
%         %% for 2 person:
%         if (find([7,12,16,20]==i)) % trial1 right
% %             if (i==8 || i==10)
% %                 
% %             end
%             
%             num_step_2=num_step_2+1;
%         
%            
% %            second_ground_truth=[1.93,-0.63;1.93,0.1;2.2,0.73;2.33,1.5;2.63,2;2.63,2.7;2.63,3.4]; 
% %          second_ground_truth=[1.12,0;1.32,0.63;1.32,1.35;1.83,2;1.93,2.65;2.13,3.3];
% %             second_ground_truth=[2.18,-0.63;2.13,0;2.23,0.73;2.13,1.46;2.23,2.1;2.34,2.7;2.49,3.3;2.49,3.95];
% %             second_ground_truth=[2.13,-0.53;2.23,0.2;2.13,0.83;2.28,1.38;2.28,2;2.4,2.65;2.6,3.1;2.8,3.65];
% %             second_ground_truth=[0.5,3.7;0.9,3.4;1.2,3;1.4,2.4;1.8,1.8;1.98,1.2;2.13,0.53;2.23,-0.2];
%                 
%            second_ground_truth=[1.31,-0.65;1.31,0;1.31,0.75;1.31,1.5;1.31,2.2;1.31,2.8;1.31,3.5];
%  
%  
%  
% 
%            second_ground_truth=second_ground_truth([2,4,5,6],:);
%  
%  
% 
% 
%             [localization,scores] = Select_loc_noprior(...
%                 tdoa_4c{i},all_score_4c{i},matchedposition_4c{i},all_scale_4c{i},...
%                 tdoa_3c{i},all_score_3c{i},matchedposition_3c{i},all_scale_3c{i});
%         
%         %% calculate the error
%             localization_2=[localization_2;localization'];
%             localization_2_error(num_step_2)=norm(localization_2(num_step_2,:)-second_ground_truth(num_step_2,:),2)
%         end
%         
%         %% for third person
%         if (find([6,13,19]==i)) % trial1 right
% %             if (i==8 || i==10)
% %                 
% %             end
%             
%             num_step_3=num_step_3+1;
%         
%             third_ground_truth=[1.98,-0.7;1.98,0;1.98,0.6;1.98,1.4;1.98,1.9;1.98,2.55;1.98,3.2];
%  
%  
%  
%             third_ground_truth=third_ground_truth([1,4,6],:);
% 
%             [localization,scores] = Select_loc_noprior(...
%                 tdoa_4c{i},all_score_4c{i},matchedposition_4c{i},all_scale_4c{i},...
%                 tdoa_3c{i},all_score_3c{i},matchedposition_3c{i},all_scale_3c{i});
%         
%         %% calculate the error
%             localization_3=[localization_3;localization'];
%             localization_3_error(num_step_3)=norm(localization_3(num_step_3,:)-third_ground_truth(num_step_3,:),2)
%         end
%         
%         %% for 4th person
%         if (find([8,9,11,15,18]==i)) % trial1 right
% %             if (i==8 || i==10)
% %                 
% %             end
%             
%             num_step_4=num_step_4+1;
%         
%              forth_ground_truth=[2.44,-0.5;2.44,0;2.44,0.65;2.44,1.35;2.44,2;2.44,2.6;2.44,3.1];
%  
% 
%              forth_ground_truth=forth_ground_truth([2,3,4,5,6],:);
% 
%             [localization,scores] = Select_loc_noprior(...
%                 tdoa_4c{i},all_score_4c{i},matchedposition_4c{i},all_scale_4c{i},...
%                 tdoa_3c{i},all_score_3c{i},matchedposition_3c{i},all_scale_3c{i});
%         
%         %% calculate the error
%             localization_4=[localization_4;localization'];
%             localization_4_error(num_step_4)=norm(localization_4(num_step_4,:)-forth_ground_truth(num_step_4,:),2)
%         end
end

%% for 1 person localization
localization_all_once=localization_1;
localization_all_error_once=localization_1_error;
ground_truth_once=first_ground_truth;
error_average_once=median(localization_all_error_once);
filename='./result_oldpeople/person1_trail1_om.mat';
load(filename);
if (~exist('localization_all'))
    localization_all=localization_all_once;
    localization_all_error=localization_all_error_once;
    ground_truth=ground_truth_once;
    error_average=error_average_once;
else
    localization_all=[localization_all;localization_all_once];
    localization_all_error=[localization_all_error,localization_all_error_once];
    ground_truth=[ground_truth;ground_truth_once];
    error_average=mean(localization_all_error);
end
save(filename,'localization_all','localization_all_error','ground_truth','error_average');

% %% for 3 person localization
% localization_all_once=[localization_1;localization_2;localization_3;localization_4];
% localization_all_error_once=[localization_1_error,localization_2_error,localization_3_error,localization_4_error];
% ground_truth_once=[first_ground_truth;second_ground_truth;third_ground_truth;forth_ground_truth];
% error_average_once=median(localization_all_error_once);
% filename='./result_oldpeople/person1_trail1_om.mat';
% load(filename);
% if (~exist('localization_all'))
%     localization_all=localization_all_once;
%     localization_all_error=localization_all_error_once;
%     ground_truth=ground_truth_once;
%     error_average=error_average_once;
% else
%     localization_all=[localization_all;localization_all_once];
%     localization_all_error=[localization_all_error,localization_all_error_once];
%     ground_truth=[ground_truth;ground_truth_once];
%     error_average=mean(localization_all_error);
% end
% save(filename,'localization_all','localization_all_error','ground_truth','error_average');
% figure;
% plot(localization_1(:,1),localization_1(:,2),'bo');
% hold on
% plot(localization_2(:,1),localization_2(:,2),'ro');
% plot(localization_3(:,1),localization_3(:,2),'go');
