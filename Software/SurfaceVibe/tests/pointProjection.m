function [ProjPoint, length_q] = pointProjection(vector, q)
    
    
    p0 = vector(1,:);
    p1 = vector(2,:);
    length_q = 1;
    
    a = [p1(1) - p0(1), p1(2) - p0(2); p0(2) - p1(2), p1(1) - p0(1)];
    b = [q(1)*(p1(1) - p0(1)) + q(2)*(p1(2) - p0(2)); ...
        p0(2)*(p1(1) - p0(1)) - p0(1)*(p1(2) - p0(2))];
    
    ProjPoint = a\b;
    
end