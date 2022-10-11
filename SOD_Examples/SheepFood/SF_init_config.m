function y_init = SF_init_config(d, N, N_sheep, N_food, R, kind)


sheep(:,1)=10.*(rand(N_sheep,1)-1/2);
sheep(:,2)=-3.*R*ones(N_sheep,1)+1.*rand(N_sheep,1)+5.;

if kind == 1 % heart
    food(:,1)=R.*(1-cos(2*pi*(1:N_food)'/N_food)).*sin(2*pi*(1:N_food)'/N_food)/2.;        %cardioid
    food(:,2)=R.*(1-1.5*cos(2*pi*(1:N_food)'/N_food)).*cos(2*pi*(1:N_food)'/N_food)/2.;    %cardioid
elseif kind == 2 % circle
    food(:,1)=R.*cos(2*pi*(1:N_food)'/N_food);
    food(:,2)=R.*sin(2*pi*(1:N_food)'/N_food);
elseif kind == 3 % actually heart shape
    theta = 2*pi*(1:N_food)'/N_food;
    r = 2 - 2*sin(theta)+sin(theta).*abs(cos(theta))./(sin(theta)+1.4);
    food(:,1)=R.*r/2.5.*cos(2*pi*(1:N_food)'/N_food);
    food(:,2)=R.*r/2.5.*sin(2*pi*(1:N_food)'/N_food)+1;
end

 figure(1); hold on;
% plot(sheep(:,1),sheep(:,2),'o');
 plot(food(:,1),food(:,2),'o'); hold off;

y_init               = [sheep; food];
y_init = y_init';
y_init = y_init(:);

return