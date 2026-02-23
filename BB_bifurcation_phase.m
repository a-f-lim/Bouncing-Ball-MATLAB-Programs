% Hello there, here is code for a bifurcation diagram of bouncing ball
% the inputs are as follows:
%       v_0: initial velocity in m/s
%       theta_0: phase shift of the motion
%       A_i: starting amplitude in mm
%       A_f: ending amplitude in mm
%       e: coefficient of restitution
%       T: period of motion for table

function BB_bifurcation_phase(v,theta_0,A_i,A_f,e,T)
    A_i = A_i / 1000; A_f = A_f / 1000;
    T = T / 1000;
    dt = 0.00005;
    verticals = [];
    horizontals = [];

    %some things to make the sine and cosine stuff cleaner
    omega = 2 * pi / T;
    phase = theta_0;

    %initializing the ball's path
    ball_pos = A_i * sin(phase);
    ball_vel = v;
    impact = @(v_T,v_B) (1+e) * v_T - e * v_B;
    Amps = A_i:0.00000025:A_f;

    %iterating the thing over amplitudes:
    for A = Amps
        %iterating the thing to get all the points now:
        for k = 1:100000
            ball_pos = ball_pos + ball_vel * dt;
            %moving the table
            table_pos = A * sin(phase);
            %checking how to change up velocity
            if ball_pos > A %no possibility of an impact
                ball_vel = ball_vel - 9.81 * dt;
                phase = phase + omega * dt;
                continue
            elseif ball_pos < table_pos %only possibility of an impact
                ball_pos = table_pos;
                ball_vel = impact(A * omega * cos(phase), ball_vel);
                if k > 20000
                    horizontals = [horizontals, A];
                    verticals = [verticals, mod(phase + pi,2 * pi) - pi];
                end
            else %in the [-A,A] range but no impact
                ball_vel = ball_vel - 9.81 * dt;
            end
            phase = phase + omega * dt;
        end
    end
    figure(4), clf
    scatter(horizontals, verticals, 2, "black", "filled")
    grid on; axis([A_i,A_f,-pi - 0.01, pi + 0.01])
    title('Bouncing Ball Bifurcation Diagram')
    xlabel("Amplitude (m)")
    ylabel("Impact Phase")
end