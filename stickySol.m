% Hello there, this is a script to calculate where the ball and table
% become unstuck in the bouncing ball model, when table vel > ball vel 
% upon impact. In other words, the relative velocity of the ball is
% downwards with respect to the table, which can't physically happen.
% 
% The ball must become unstuck when the table accelerates downward wiht
% magnitude greater than g, so we first check if A \omega ^ 2 < 9.81. If
% such is the case, then the ball will remain stuck to the table.
% Otherwise, we return the unstuck phase given by
%       theta = arcsin(g / (A * omega ^ 2))
% 
% The variables mean the same things from the impact calculator.
%
% NOTE: calculating the unstuck angle/if it is stuck at all is not
% dependent on the velocity of the ball nor the restitution coefficient, as
% the ball is essentially moving with the table. Therefore until unstuck, 
% v_table = v_ball until theta_unstuck.

function t_unstuck = stickySol(theta_0,A,T)
    %reinitialize variables to get things in meters and seconds
    T = T / 1000; A = A / 1000;
    omega = 2 * pi / T;

    %check if the ball can ever be unstuck
    if A * omega ^ 2 < 9.81
        %return infinite time
        t_unstuck = Inf;
    else %if the table ever accelerates downward more than g
        theta_unstuck = asin(9.81 / (A * omega ^ 2));
        if theta_unstuck < theta_0
            theta_unstuck = theta_unstuck + T;
        end
        t_unstuck = (theta_unstuck - theta_0) / omega;
    end
end