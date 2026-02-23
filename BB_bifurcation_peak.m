% Hello there, here is code for a bifurcation diagram of bouncing ball
% the inputs are as follows:
%       v_0: initial velocity in m/s
%       theta_0: phase shift of the motion
%       A_i: starting amplitude in mm
%       A_f: ending amplitude in mm
%       e: coefficient of restitution
%       T: period of motion for table

function BB_bifurcation_peak(v,theta_0,A_i,A_f,e,T)
    verticals = [];
    horizontals = [];
    TRAJECTORY = BB_Traj(v,theta_0,e,A_i,T,50000,false);
    %iterating the thing over amplitudes:
    for A = A_i:0.00025:A_f
        TRAJECTORY = BB_Traj('s','s',e,A,T,50000,false);
        PEAKS = BB_Peak_Anal(TRAJECTORY(10001:end),A);
        horizontals = [horizontals, A * ones(size(PEAKS))];
        verticals = [verticals, PEAKS];
    end
    figure(4), clf
    scatter(horizontals, verticals, 3, "black", "filled")
    grid on, axis([A_i A_f 0 Inf])
    title('Bouncing Ball Bifurcation Diagram')
    xlabel("Amplitude (m)")
    ylabel("Locally Maximum Height")
end