% IMPACT CALCULATOR
% Computes the time until a ball bouncing on a sinusoidally oscillating 
% table returns to impact with the table.
%
% Physics Model:
%   Table position: s(t) = A * sin(omega * t + theta_0)
%   Ball position:  y(t) = y_0 + v * t - (1/2) * g * t^2
%   where y_0 = A * sin(theta_0) at t=0
%
% Assumptions:
%   - Ball relative velocity is initially positive (ball leaving table)
%   - Elastic/inelastic collisions handled by impact velocity update (external)
%   - Ball under free fall between impacts
%
% Inputs:
%   v         (m/s):  initial velocity of ball (upward positive)
%   theta_0   (rad):  initial phase angle of table oscillation
%   A         (mm):   amplitude of table oscillation
%   T         (ms):   period of table oscillation
%
% Output:
%   t_imp     (s):    time until next impact with table

function t_imp = impactCalculator(v, theta_0, A, T)
    % Convert inputs to consistent units (meters, seconds)
    T = T / 1000;
    A = A / 1000;
    
    % Angular frequency
    omega = 2 * pi / T;
    
    % Initial position of ball (at table surface)
    y_0 = A * sin(theta_0);
    
    % Define ball and table positions
    y = @(t) y_0 + v * t - (9.81 / 2) * t^2;           % ball height
    s = @(t) A * sin(omega * t + theta_0);             % table height
    d = @(t) y(t) - s(t);                              % separation distance
    
    % Bracketing phase: find where ball crosses table (d changes sign)
    dt = T / 100;  % Time step for bracketing
    t = dt;        % Start at dt to avoid d(0) = 0 ambiguity
    
    while d(t) >= 0
        t = t + dt;
    end
    
    % Refinement phase: use fzero for accurate root finding
    % Bracket: [t-dt, t] where d changes sign
    options = optimset('TolX', 1e-10, 'TolFun', 1e-10);
    try
        t_imp = fzero(d, [t - dt, t], options);
    catch
        error('fzero failed to converge on root');
    end
end
