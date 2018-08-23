init();

fo=240;
fs = 1000;
t=(0:1/fs:1-1/fs);  
x=sin(2*pi*fo*t).*exp(-20*t);  
y=[zeros(1,250) x(1:length(x)-250)];
z=[zeros(1,500) x(1:length(x)-500)];

t = t';
signals = [x' y' z'];

delays = [0 250/fs 500/fs]

plot(t,x,t,y,t,z);

tdoaCalc = XcorrTdoaCalculator();
xcorrLag = tdoaCalc.calculate(t, signals)

tdoaCalc = FirstPeakTdoaCalculator();
peakLag = tdoaCalc.calculate(t, signals)