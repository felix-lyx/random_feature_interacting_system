function f = SF_sheep_on_sheep(r)

a = -0.02;    % attraction
b = 1.2;     % repulsion
f = -b./((r.^4)/4+0.05)-a;

return