% Hello there. This is a script that combines both the impactCalculator and
% stickySol scripts to generate the trajectory of a bouncing ball system
% over some period of time. If (from the table's POV) the ball travels
% upward, then we use impactCalculator. Otherwise (travels downward), we 
% use the stickySol script. The inputs are as follows:
% 
%       v (m/s):    an initial velocity
%       theta_0:    an initial phase for where the table starts
%       A (mm):     an amplitude of oscillation for the table
%       e:          a coefficient of restitution b/w the ball and table
%       T (ms):     the period of oscillation for the table 
%       imp_count:  how many times the simulation lets the ball bounce for
%                   after takeoff
% 
% The calculator will run for [secs] seconds of ball, providing the angles
% theta_i, i from 1 to imp_count at which the ball hits the table.

function [imp_phases,theta,v] = getImps(v,theta,A,e,T,imp_count)
    %reinitialize variables to get things in meters and seconds
    T = T / 1000; A = A / 1000;
    omega = 2 * pi / T;
    t = 0;
    
    imp_phases = zeros(1,imp_count);
    
    %once the ball becomes unstuck, it must hit a parabolic arc
    %this variable will denote past states of "sticky" or "bouncy"
    bounce_stuck = 1;
    
    % the important part: ball motion
    for Iter = 1:imp_count
        table_vel = A * omega * cos(theta);

        if v <= table_vel && bounce_stuck  %if sticky now AND was "bounce" before
            tau = stickySol(theta,1000*A,1000*T);
            v = A * omega * cos(omega * tau + theta);
            bounce_stuck = 0; %indicates that the previous state was "sticky"
        else %if not sticky OR was previously sticky
            tau = impactCalculator(v,theta,1000*A,1000*T);
            v = (1 + e) * A * omega * cos(omega * tau + theta) - e * (v - 9.81 * tau);
            bounce_stuck = 1; %indicates that the previous state was bouncy
        end
        
        %shift the new starting points forward by tau
        t = t + tau;
        theta = omega * tau + theta;
        theta = mod(theta + pi,2 * pi) - pi;
        imp_phases(Iter) = theta;
    end
end