close all;
clear ;

%% for cross data
load('./paper_result/cross_localization_result/trail3_localization_result.mat');
% based on the last step localization and 
last_step_person1=[2.28;-0.63]; % right
last_step_person2=[0.965;4.44]; %left
direction_person1=[0;1];
direction_person2=[0;1];

direction_person1=localization_right(3,:)'-localization_right(1,:)';
direction_person1=direction_person1/norm(direction_person1);
direction_person2=localization_left(3,:)'-localization_left(1,:)';
direction_person2=direction_person2/norm(direction_person2);

% % %% cross ground truth positions
% right_ground_truth=[2.49,0;2.49,0.63;2.49,1.26;2.49,1.89;2.49,2.52;2.49,3.15;2.49,3.78];
% left_ground_truth=[1.17,3.15;1.17,2.52;1.17,1.89;1.17,1.26;1.17,0.63;1.17,0;1.17,-0.63];

% %% sidebyside ground truth positions
right_ground_truth=[2.49,0;2.49,0.63;2.49,1.26;2.49,1.89;2.49,2.52;2.49,3.15;2.49,3.78];
left_ground_truth=[1.17,0;1.17,0.63;1.17,1.26;1.17,1.89;1.17,2.52;1.17,3.15;1.17,3.78];


% initialization
localization_auto1=localization_right(1,:)';
localization_auto2=localization_left(1,:)';
last_step_person1=localization_auto1;
last_step_person2=localization_auto2;
num_step_left=1;
num_step_right=1;


figure;
geophone_number=4;
geophone_position=[3.37,0.2,3.37,0.2;3.05,2.03,1.02,0];
figure;
plot(geophone_position(1,:),geophone_position(2,:),'r*');
hold on
plot(right_ground_truth(:,1),right_ground_truth(:,2),'go');
plot(left_ground_truth(:,1),left_ground_truth(:,2),'go');


% Kalman parameter
Q_k=eye(2,2)*0.05^2;
R=eye(2,2)*0.1^2;
for i=2:7
        num_step_right=num_step_right+1;
        localization=localization_right(num_step_right,:)';
      %  use Kalman Filter to get final localization
        footstep_length=0.65;
%         direction_person1=((num_step_right-1)*direction_person1+localization_right(i,:)'-localization_right(i-1,:)')...
%             /num_step_right;
        K_score=Q_k*inv(Q_k+R);
        next_prediction=last_step_person1+direction_person1*footstep_length;
        measure=localization;
        updated_step=next_prediction+K_score*(measure-next_prediction);
        last_step_person1=updated_step

        % store the measure
        localization_auto1=[localization_auto1,last_step_person1];
        plot(localization_auto1(1,:),localization_auto1(2,:),'bo');
end

for i=[1,1,1,1,0,0]
        %% for person 2
        num_step_left=num_step_left+i;
        localization=localization_left(num_step_left,:)';
        %use Kalman Filter to get final localization
        footstep_length=0.65;
        K_score=Q_k*inv(Q_k+R);
        if(i==0)
            K_score=zeros(2,2);
        end
        next_prediction=last_step_person2+direction_person2*footstep_length;
        measure=localization;
        updated_step=next_prediction+K_score*(measure-next_prediction);
        last_step_person2=updated_step;

        % store the measure
        localization_auto2=[localization_auto2,last_step_person2];
        plot(localization_auto2(1,:),localization_auto2(2,:),'ko');
end


