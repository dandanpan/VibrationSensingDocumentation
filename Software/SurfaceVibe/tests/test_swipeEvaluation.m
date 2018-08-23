close all;

init();
s = Surface([40 40]);
s.addSensor(0,0);
s.addSensor(1,0);
s.addSensor(0,1);
s.addSensor(1,1);

nPoints = 40;

lines{1} = [20 30; 20 10];
lines{2} = [10 30; 30 10];
lines{3} = [10 20; 30 20];
lines{4} = [10 10; 30 30];
lines{5} = [20 10; 20 30];
lines{6} = [30 10; 10 30];
lines{7} = [30 20; 10 20];
lines{8} = [30 30; 10 10];

for idx = 1%:8
    
    line = lines{idx};
    ep1 = line(1,:);
    ep2 = line(2,:);

    % generate points on a line with some random noise
    xBase = linspace(ep1(1),ep2(1),nPoints); % 40 points between x1 and x2
    yBase = linspace(ep1(2),ep2(2),nPoints); % points between y1 and y2

    % generate x and y with random noise
    swipePoints = zeros(nPoints,2);
    for i = 1:nPoints
        x = xBase(i) + random('Normal',0,2,1,1);
        y = yBase(i) + random('Normal',0,2,1,1);
        swipePoints(i,:) = [x y];
    end

    evaluation = evaluateSwipe(swipePoints, [ep1; ep2], s); 
    
end