% STICKY SOLUTION CALCULATOR
% Computes the duration for which a ball remains stuck to a sinusoidally
% oscillating table before becoming unstuck and leaving the surface.
%
% Physics Model:
%   Table position:     s(t) = A * sin(omega * t + theta_0)
%   Table acceleration: a(t) = -A * omega^2 * sin(omega * t + theta_0)
%
%   The ball remains stuck while the table's normal force keeps it in contact.
%   The ball becomes unstuck when the table accelerates downward with magnitude
%   greater than gravitational acceleration g, at which point the ball can no
%   longer maintain contact.
%
% Unsticking Condition:
%   |a_table| > g
%   A * omega^2 * |sin(theta)| > g
%   Solution (descending phase): theta_unstuck = pi - arcsin(g / (A * omega^2))
%
% Inputs:
%   A         (mm):   amplitude of table oscillation
%   T         (ms):   period of table oscillation
%   theta_0   (rad):  initial phase angle
%
% Output:
%   t_unstuck (s):    time until ball becomes unstuck
%                     Returns Inf if A * omega^2 < g (ball never unsticks)

function t_unstuck = stickySolCalc(A, T, theta_0)
    % Convert inputs to consistent units (meters, seconds)
    T = T / 1000;
    A = A / 1000;
    
    % Angular frequency
    omega = 2 * pi / T;
    
    % Gravitational acceleration
    g = 9.81;
    
    % Check if unsticking is physically possible
    % Maximum downward acceleration: A * omega^2
    if A * omega^2 < g
        % Table oscillation is too weak to overcome gravity
        % Ball remains stuck indefinitely
        t_unstuck = Inf;
        return;
    end
    
    % Compute unstacking phase angle
    % sin(theta_unstuck) = g / (A * omega^2)
    % Two solutions per period:
    %   theta1 = arcsin(...) in [0, pi/2]  -> ascending phase (invalid)
    %   theta2 = pi - arcsin(...) in [pi/2, pi] -> descending phase (valid)
    % 
    % Only the descending phase solution is physical:
    % The ball unsticks when moving downward (cos(theta) < 0)
    
    theta_unstuck = asin(g / (A * omega^2));

    % Find the first occurrence of theta_unstuck after theta_0
    theta0_mod = mod(theta_0, 2 * pi);
    theta_unstuck = theta_unstuck + 2 * pi * ceil((theta0_mod - theta_unstuck) / (2 * pi));
    
    % Convert phase difference to time
    t_unstuck = (theta_unstuck - theta_0) / omega;
    
    % Sanity check
    if t_unstuck < 0
        error(['Invalid unsticking time computed: ',num2str(t_unstuck)]);
    end
end
