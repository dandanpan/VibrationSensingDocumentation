function [score,position] = sstress_score_localize(geophone_position,d_diff)

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



% initialization
geophone_num=length(d_diff);
x0=[0;0];
eps=1e-9;
max_iteration=2000;
d=(d_diff+norm(geophone_position(:,1)-x0,2)).^2;
score_past=sum((sum((geophone_position-x0).^2)-d').^2);
score_new=0;
i=0;
while (i<max_iteration) && (abs(score_past-score_new)>eps)
    
    if(i==0)
        score_new=score_past;
    end
    score_past=score_new;
    
    % ensure the solver can work and use the restrict: not more than 10
    % meters
    x0(find(abs(x0)>=20))=sign(x0(find(abs(x0)>=20)))*20;
    % calculate the parameters ax^3+bx^2+cx+d=0
        %useful vector;
    
    x_minus=-(geophone_position(1,:)-x0(1)); % xi-xj row vector
    y_minus=-(geophone_position(2,:)-x0(2)); % yi-yj row vector
    
    %% update x
    d=(d_diff+norm(geophone_position(:,1)-x0,2)).^2;

    pa=geophone_num;
    pb=3*sum(x_minus);
    pc=3*sum(x_minus.^2)+sum(y_minus.^2)-sum(d);
    pd=sum(x_minus.^3)+sum(x_minus.*(y_minus.^2))-sum(x_minus*d);
    p=[pa,pb,pc,pd];
    solution=real(roots(p));
    for j=1:3
        x_new=x0(1)+solution(j);
        d_new=(d_diff+norm(geophone_position(:,1)-[x_new;x0(2)],2)).^2;
        score_one=sum((sum((geophone_position-[x_new;x0(2)]).^2)-d_new').^2);
        if (score_one<=score_new)
            score_new=score_one;
            x0(1)=x_new;
        end
    end
    
    %% udpate y
    d=(d_diff+norm(geophone_position(:,1)-x0,2)).^2;
    pa=geophone_num;
    pb=3*sum(y_minus);
    pc=3*sum(y_minus.^2)+sum(x_minus.^2)-sum(d);
    pd=sum(y_minus.^3)+sum(y_minus.*(x_minus.^2))-sum(y_minus*d);
    p=[pa,pb,pc,pd];
    solution=real(roots(p));
    for j=1:3
        y_new=x0(2)+solution(j);
        d_new=(d_diff+norm(geophone_position(:,1)-[x0(1);y_new],2)).^2;
        score_one=sum((sum((geophone_position-[x0(1);y_new]).^2)-d_new').^2);
        if (score_one<=score_new)
            score_new=score_one;
            x0(2)=y_new;
        end
    end
    
    i=i+1;
end

score=score_new;
position=x0;


%% test landscape
% figure;
% x=-1.5:0.1:3;
% y=-4:0.1:2;
% [X,Y]=meshgrid(x,y);
% Z=zeros(size(X));
% for i=1:length(x)
%     for j=1:length(y)
%         d_test=(d_diff+norm(geophone_position(:,1)-[x(i);y(j)],2)).^2;
%         Z(j,i)=sum((sum((geophone_position-[x(i);y(j)]).^2)-d_test').^2);
%     end
% end
% mesh(X,Y,Z);

end


