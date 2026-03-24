% Hello there. This is a script that generates a bifurcation diagram for
% the bouncing ball model. The bifurcation diagram specifically looks at
% the impact phases as the amplitude is changed. The syntax is essentially
% the same as the getTraj code but we only focus on obtaining phase
% information.
% 
% The inputs are as follows:
% 
%       v (m/s): an initial velocity
%       theta_0: an initial phase for where the table starts
%       Amps (mm): a set of amplitudes of oscillation for the table
%       e: a coefficient of restitution between the ball and table
%       T (ms): the period of oscillation for the table 

function Points_to_Plot = bifurcationDiagram(v,theta,Amps,e,T)
    %arrays to store data for plotting
    amp_plot = [];
    theta_plot = [];
    n = 10; %no. of bounces before we start tracking the impacts (transient)
    N = 30; %no. of phases to record at each amplitude
    
    for A = Amps
        %generating the phases
        [theta_imps,theta,v] = getImps(v,theta,A,e,T,n+N);
        %put everything into the arrays
        amp_plot = [amp_plot, A * ones(1,N)];
        theta_plot = [theta_plot,theta_imps(n+1:end)];
    end

    figure(2), clf
    scatter(amp_plot,theta_plot,2,"black", "filled")
    grid on
    title("Bouncing Ball Bifurcation Diagram")
    xlabel("Amplitudes (mm)"); ylabel("Impact Phases")
    axis([min(Amps),max(Amps),-pi,pi])

    Points_to_Plot = [amp_plot',theta_plot'];
end