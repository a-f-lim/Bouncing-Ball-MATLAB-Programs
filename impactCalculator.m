% Hello there, this is a script to calculate where the ball and table meet
% next in the bouncing ball model using the phase maps
%       s(t_k) = s(t_{k-1}) + v_k * (delta t) - 1/2 * g (delta t)^2
%       v_{k+1} = (1 + e) * s'(t_k) - e * v_k
% where s(t) = A * sin( omega * t + theta_0 ) is the path of the table
% and the ball is governed by free fall in between consecutive impacts.

function t_imp = impactCalculator(v,theta_0,A,T)
    %reinitialize variables to get things in meters and seconds
    T = T / 1000; A = A / 1000;
    dt = T / 100;
    omega = 2 * pi / T;
    
    % define the functions of motion, as well as the distance function
    y_0 = A * sin(theta_0);
    % ball
    y = @(t) y_0 + v * t - (9.81 / 2) * t ^ 2;
    % table oscillations
    s = @(t) A * sin(omega * t + theta_0);
    % ball - table
    d = @(t) y(t) - s(t);
    
    %solving for the time of impact
    t = 0;
    while d(t) >= 0
        t = t + dt;
    end
    t_imp = fzero(d,[t - dt, t+dt]);
end