init();

s = Surface([40 40]);
s.addSensor(0,0);
s.addSensor(1,0);
s.addSensor(0,1);
s.addSensor(1,1);
s.addSensor(0.5,0.5);
s.addSensor(0.75,0.25);

renderer = SurfaceRenderer(s);
locations = [5 5; 15 15; 25 25; 35 35];
renderer.addPoints(locations);

renderer.plot();

renderer.addPoints([10 10; 10 15; 10 20; 10 25]);

renderer.plot();
