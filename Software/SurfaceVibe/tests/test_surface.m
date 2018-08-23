init();

s = Surface([40 40]);
s.addSensor(0,0);
s.addSensor(1,0);
s.addSensor(0,1);
s.addSensor(1,1);
s.addSensor(0.5,0.5);
s.addSensor(0.75,0.25);
s.getSensorPlacements()