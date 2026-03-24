% Hello there. This is a script that combines both the impactCalculator and
% stickySol scripts to generate the trajectory of a bouncing ball system
% over some period of time. If (from the table's POV) the ball travels
% upward, then we use impactCalculator. Otherwise (travels downward), we 
% use the stickySol script. The inputs are as follows:
% 
%       v (m/s): an initial velocity
%       theta_0: an initial phase for where the table starts
%       A (mm): an amplitude of oscillation for the table
%       e: a coefficient of restitution between the ball and table
%       T (ms): the period of oscillation for the table 
%       secs (s): how many seconds of the system the code simulates
% 
% The calculator will run for [secs] seconds of ball, providing a graph of 
% height vs. time for both the ball and the table.

function [theta,v] = getTraj(v,theta,A,e,T,secs)
    %reinitialize variables to get things in meters and seconds
    T = T / 1000; A = A / 1000;
    omega = 2 * pi / T;
    dt = T / 250; t = 0; Tau = 0;

    %once the ball becomes unstuck, it must hit a parabolic arc
    %this variable will denote past states of "sticky" or "bouncy"
    bounce_stuck = 1;
    
    %plot the table motion
    figure(1), clf, hold on
    t_table = 0:dt:secs;
    pos_table = A * sin(omega .* t_table + theta);
    plot(t_table,pos_table,'r',LineWidth=1)
    title("Bouncing Ball Height vs. Time Graph")
    xlabel("Time"); ylabel("Height")
    grid on

    % the important part: ball motion
    while t < secs
        table_vel = A * omega * cos(theta);

        if v <= table_vel && bounce_stuck  %if sticky now AND was "bounce" before
            tau = stickySol(theta,1000*A,1000*T);
            pos_ball = @(times) A * sin(omega .* (times - t) + theta);
            v = A * omega * cos(omega * tau + theta);
            bounce_stuck = 0; %indicates that the previous state was "sticky"
        else %if not sticky OR was previously sticky
            tau = impactCalculator(v,theta,1000*A,1000*T);
            pos_ball = @(times) A * sin(theta) + v .* (times - t) - (9.81 / 2) .* (times - t) .^ 2;
            v = (1 + e) * A * omega * cos(omega * tau + theta) - e * (v - 9.81 * tau);
            bounce_stuck = 1; %indicates that the previous state was bouncy
        end
        Tau = min(secs - t,tau);
        N = max(floor(Tau/dt)+1,11);
        t_ball = linspace(t,t+Tau,N);
        plot(t_ball,pos_ball(t_ball),'b',LineWidth=1)    
        
        %shift the new starting points forward by tau
        t = t + Tau;
        theta = omega * Tau + theta;
        theta = mod(theta + pi,2 * pi) - pi;
    end
    theta = theta - omega * (Tau - tau);
    theta = mod(theta + pi,2 * pi) - pi;
end