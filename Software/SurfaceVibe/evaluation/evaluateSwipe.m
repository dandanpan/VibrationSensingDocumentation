function [ evaluation ] = evaluateSwipe( swipePoints, expectedLine, surface )
%EVALUATESWIPE Compares the computed swipe to a reference line and extracts
% quality metrics. Returns an evaluation structure containing the
% following:
%   1) estimated direction of the swipe
%   2) direction angle error from expected line
%   3) length of the swipe
%   4) length error from expected line
%   5) the perpendicular distances of each point from the expected line

    ep1 = expectedLine(1,:);
    ep2 = expectedLine(2,:);
    expectedAngle = angleBetweenPoints(ep1, ep2);
    expectedLength = distanceBetweenPoints(ep1, ep2);

    % see if we need to rotate the plot here
    if abs(expectedAngle) == 90
        y = swipePoints(:,1);
        x = swipePoints(:,2);    
    else
        x = swipePoints(:,1);
        y = swipePoints(:,2);
    end

    % get the robust line from the swipePoints
    brob = robustfit(x,y);
    
    % generate the start and end points and form the line information
    x1 = min(x); x2 = max(x);
    y1 = brob(2) * x1 + brob(1);
    y2 = brob(2) * x2 + brob(1);
    
    % getting the project points
    swipePointsNum = size(swipePoints,1);
    projPoints = zeros(size(swipePoints));
    for pIdx = 1:swipePointsNum
        if abs(expectedAngle) == 90
            projPoints(pIdx,:) = ProjectPoint([x1 y1;x2 y2],[swipePoints(pIdx,2),swipePoints(pIdx,1)]);
        else
            projPoints(pIdx,:) = ProjectPoint([x1 y1;x2 y2],swipePoints(pIdx,:));
        end
    end
    
    % get points for length calculation
    [~,end1] = min(projPoints(:,1));
    [~,end2] = max(projPoints(:,1));
    
    % direction: find consecutive five points, with minimum distance std
    % and max confidence, then compare their order to that of the x1 to x2
    jumpDist = zeros(swipePointsNum-1);
    for pIdx = 1:swipePointsNum-1
        jumpDist(pIdx) = distPoints(projPoints(pIdx,:),projPoints(pIdx+1,:));
    end
    maxStd = 10000; idealIdx = -1;
    for pIdx = 1:swipePointsNum-4
        testedStd = std(jumpDist(pIdx:pIdx+4));
        if testedStd < maxStd
            maxStd = testedStd;
            idealIdx = pIdx;
        end
    end
    refDir = sign(x1-x2);
    detDir = sign(projPoints(idealIdx,1)-projPoints(idealIdx+4,1));
    if refDir ~= detDir
        [x1, y1, x2, y2] = switchPoints(x1, y1, x2, y2);
    end
    
    if abs(expectedAngle) == 90
        p1 = [y1 x1];
        p2 = [y2 x2]; 
    else
        p1 = [x1 y1];
        p2 = [x2 y2];
    end
    
    % getting angle by averaging the 
    actualAngle = angleBetweenPoints(p1, p2);
    actualLength = distanceBetweenPoints(projPoints(end1,:), projPoints(end2,:));
    distances = distancesFromLine(swipePoints, [p1;p2]);
    
    if expectedAngle == 180 && actualAngle < 0
        actualAngle = actualAngle + 360;
    end
    expectedAngle
    actualAngle
    expectedLength
    actualLength
    
    evaluation = struct('angle', actualAngle, ...
                        'length', actualLength, ...
                        'distances', distances, ...
                        'angleError', actualAngle - expectedAngle, ...
                        'lengthError', actualLength - expectedLength);
    
    % if given a surface, plot the data
    if nargin > 2
        renderer = SurfaceRenderer(surface);
        h=figure;
        renderer.plot(h);
        renderer.addPoints(swipePoints);
        hold on;
        
        % plot the expected line
        plot([ep1(1) ep2(1)], [ep1(2) ep2(2)], 'r', 'LineWidth',2);
        
        % plot the estimated line
        plot([p1(1) p2(1)], [p1(2) p2(2)], 'g', 'LineWidth',2);
        
        % plot the distances between each point to the estimated line
        for i = 1:size(swipePoints,1)
            p = swipePoints(i,:);
            [pp, ~] = ProjectPoint([p1;p2], p);
            plot([p(1), pp(1)], [p(2) pp(2)], 'k');
        end
    end
    
end

function angle = angleBetweenPoints(p1, p2)
     angle = atan2(p2(2)-p1(2),p2(1)-p1(1)) * 180/pi;
end

function distance = distanceBetweenPoints(p1, p2)
    distance = norm(p2-p1);
end

function distances = distancesFromLine(points, line)

    q1 = line(1,:);
    q2 = line(2,:);
    
    nPoints = length(points);
    distances = zeros(nPoints,1);
    for idx = 1:nPoints
        p = points(idx,:);
        d = abs(det([q2-q1;p-q1]))/norm(q2-q1);
        distances(idx) = d;
    end

end

% from: https://www.mathworks.com/matlabcentral/answers/26464-projecting-a-point-onto-a-line
% write function that projects the  point (q = X,Y) on a vector
% which is composed of two points - vector = [p0x p0y; p1x p1y]. 
% i.e. vector is the line between point p0 and p1. 
%
% The result is a point qp = [x y] and the length [length_q] of the vector drawn 
% between the point q and qp . This resulting vector between q and qp 
% will be orthogonal to the original vector between p0 and p1. 
% 
% This uses the maths found in the webpage:
% http://cs.nyu.edu/~yap/classes/visual/03s/hw/h2/math.pdf
function [ProjPoint, length_q] = ProjectPoint(vector, q)
  p0 = vector(1,:);
  p1 = vector(2,:);
  a = [p1(1) - p0(1), p1(2) - p0(2); p0(2) - p1(2), p1(1) - p0(1)];
  b = [q(1)*(p1(1) - p0(1)) + q(2)*(p1(2) - p0(2)); ...
      p0(2)*(p1(1) - p0(1)) - p0(1)*(p1(2) - p0(2))] ;
  ProjPoint = (a\b)';
  length_q = distanceBetweenPoints(ProjPoint, q);
end