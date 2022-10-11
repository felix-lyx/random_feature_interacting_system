function f = SF_food_on_sheep(r)

s_l = 0.45;
s_a = 65.;
f = (s_a)*( exp(-r/s_l) );

return