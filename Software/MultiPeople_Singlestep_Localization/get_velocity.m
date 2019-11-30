function velocity=get_velocity(a,b,distance1,distance2)

t=abs(a-b)/25600;
distance=abs(distance1-distance2);
velocity=distance/t;

end
