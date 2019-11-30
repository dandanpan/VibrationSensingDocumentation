function [score,position] = sstress_score_new(geophone_position,d_diff)

% % initialization
% geophone_num=length(d);
% x0=[0;0];
% eps=1e-6;
% max_iteration=2000;
% score_past=sum((sum((geophone_position-x0).^2)-d').^2);
% score_new=0;
% i=0;
% while (i<max_iteration) && (abs(score_past-score_new)>eps)
%     
%     if(i==0)
%         score_new=score_past;
%     end
%     score_past=score_new;
%     
%     
%     % calculate the parameters ax^3+bx^2+cx+d=0
%         %useful vector;
%     x_minus=-(geophone_position(1,:)-x0(1)); % xi-xj row vector
%     y_minus=-(geophone_position(2,:)-x0(2)); % yi-yj row vector
%     
%     %% update x
%     pa=geophone_num;
%     pb=3*sum(x_minus);
%     pc=3*sum(x_minus.^2)+sum(y_minus.^2)-sum(d);
%     pd=sum(x_minus.^3)+sum(x_minus.*(y_minus.^2))-sum(x_minus*d);
%     p=[pa,pb,pc,pd];
%     solution=real(roots(p));
%     for j=1:3
%         x_new=x0(1)+solution(j);
%         score_one=sum((sum((geophone_position-[x_new;x0(2)]).^2)-d').^2);
%         if (score_one<=score_new)
%             score_new=score_one;
%             x0(1)=x_new;
%         end
%     end
%     
%     %% udpate y
%     pa=geophone_num;
%     pb=3*sum(y_minus);
%     pc=3*sum(y_minus.^2)+sum(x_minus.^2)-sum(d);
%     pd=sum(y_minus.^3)+sum(y_minus.*(x_minus.^2))-sum(y_minus*d);
%     p=[pa,pb,pc,pd];
%     solution=real(roots(p));
%     for j=1:3
%         y_new=x0(2)+solution(j);
%         score_one=sum((sum((geophone_position-[x0(1);y_new]).^2)-d').^2);
%         if (score_one<=score_new)
%             score_new=score_one;
%             x0(2)=y_new;
%         end
%     end
%     
%     i=i+1;
% end
% 
% score=score_new;
% position=x0;



% parameter for back searching
beta=0.5;
alpha=0.1;
% initialization
geophone_num=length(d_diff);
% get the min distance sensor and change the tdoa
[value,nearest_sensor]=min(d_diff);
%&&&&&&&&&&&&&&&&&
d_diff=d_diff-value;


%% test landscape
% figure;
% x=-2:0.1:6;
% y=-2:0.1:2;
% [X,Y]=meshgrid(x,y);
% Z=zeros(size(X));
% for i=1:length(x)
%     for j=1:length(y)
%         d_test=(d_diff+norm(geophone_position(:,nearest_sensor)-[x(i);y(j)],2)).^2;
%         Z(j,i)=sum((sum((geophone_position-[x(i);y(j)]).^2)-d_test').^2);
%     end
% end
% contourf(X,Y,Z);


%%

x0=[1;1];
eps=1e-9;
max_iteration=2000;
d=(d_diff+norm(geophone_position(:,nearest_sensor)-x0,2));
score_past=sum((sum((geophone_position-x0).^2)-d.^2').^2);
score_new=0;
i=0;
while (i<max_iteration) && (abs(score_past-score_new)>eps)
    
    if(i==0)
        score_new=score_past;
    end
    score_past=score_new;
    
    
    % calculate the parameters ax^3+bx^2+cx+d=0
        %useful vector;
    x_minus=-(geophone_position(1,:)-x0(1)); % xi-xj row vector
    y_minus=-(geophone_position(2,:)-x0(2)); % yi-yj row vector
    

    
    %% update x
    d=d_diff+norm(geophone_position(:,nearest_sensor)-x0,2);
    pa=sum(x_minus.^3);
    pb=-x_minus.^2*d/d(nearest_sensor)*(x0(1)-geophone_position(1,nearest_sensor));
    pc=x_minus*((y_minus.^2)'-d.^2);
    pd=-(y_minus.^2)*d/d(nearest_sensor)*(x0(1)-geophone_position(1,nearest_sensor));
    pe=sum(d.^3/d(nearest_sensor)*(x0(1)-geophone_position(1,nearest_sensor)));
    grad=(pa+pb+pc+pd+pe);
    % back searching
    t=0.1;
    x_new=x0(1)-t*grad;
    d_new=(d_diff+norm(geophone_position(:,nearest_sensor)-[x_new;x0(2)],2)).^2;
    score_one=sum((sum((geophone_position-[x_new;x0(2)]).^2)-d_new').^2);
    max_iter=50;
    iter=1;
    while (score_one>score_new && iter<max_iter)
        t=beta*t;
        x_new=x0(1)-t*grad;
        d_new=(d_diff+norm(geophone_position(:,nearest_sensor)-[x_new;x0(2)],2)).^2;
        score_one=sum((sum((geophone_position-[x_new;x0(2)]).^2)-d_new').^2);
        iter=iter+1;
    end
    if (score_one<=score_new)
        score_new=score_one;
        x0(1)=x_new;
    end
    
    %% udpate y
    d=d_diff+norm(geophone_position(:,nearest_sensor)-x0,2);
    pa=sum(y_minus.^3);
    pb=-y_minus.^2*d/d(nearest_sensor)*(x0(2)-geophone_position(2,nearest_sensor));
    pc=y_minus*((x_minus.^2)'-d.^2);
    pd=-(x_minus.^2)*d/d(nearest_sensor)*(x0(2)-geophone_position(2,nearest_sensor));
    pe=sum(d.^3/d(nearest_sensor)*(x0(2)-geophone_position(2,nearest_sensor)));
    grad=(pa+pb+pc+pd+pe);
    % back searching
    t=0.1;
    y_new=x0(2)-t*grad;
    d_new=(d_diff+norm(geophone_position(:,nearest_sensor)-[x0(1);y_new],2)).^2;
    score_one=sum((sum((geophone_position-[x0(1);y_new]).^2)-d_new').^2);
    iter=1;
    
    while (score_one>score_new && iter<max_iter)
        t=beta*t;
        y_new=x0(2)-t*grad;
        d_new=(d_diff+norm(geophone_position(:,nearest_sensor)-[x0(1);y_new],2)).^2;
        score_one=sum((sum((geophone_position-[x0(1);y_new]).^2)-d_new').^2);
        iter=iter+1;
    end
    if (score_one<=score_new)
        score_new=score_one;
        x0(2)=y_new;
    end   
    i=i+1;
end

score=score_new;
position=x0;



end


