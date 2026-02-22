%Hello there. 
%
%The following is code to compute the trajectory for a ball bouncing
%on a sinusoidally oscillating table
%
%  v (m/s) = initial velocity at which ball leaves table
%  theta_0 = phase shift at which table's motion begins
%  alpha = coefficient of restitution b/w ball and table
%  A (mm) = amplitude of motion of table
%  T (ms) = period of the table
%  N = number of points we want to have
%  note that the timestep between each point of the trajectory is 0.1ms

function X = BB_Traj(v,theta_0,alpha,A,T,N)
    %rescale some stuff
    A = A / 1000;
    T = T / 1000;

    %this is where we will store the heights from t = 0 to (N-1)*dt
    X = zeros(1,N);
    dt = 0.0001;
    
    %some things to make the sine and cosine stuff cleaner
    omega = 2 * pi / T;
    phase = theta_0;

    %initializing the ball's path
    ball_pos = A * sin(phase);
    ball_vel = v;
    impact = @(v_T,v_B) (1+alpha) * v_T - alpha * v_B;
    
    %iterating the thing to get all the points now:
    for k = 1:N
        X(k) = ball_pos;
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
            phase = phase + omega * dt;
        else %in the [-A,A] range but no impact
            ball_vel = ball_vel - 9.81 * dt;
            phase = phase + omega * dt;
        end
    end
    times = 0:dt:(N-1)*dt;
    table_X = A * sin(omega * times + theta_0);
    figure(1), clf
    hold on
    plot(times,X)
    plot(times, table_X)
    title(['Bouncing Ball Model: v_0=', num2str(v),' m/s, \theta_0=',num2str(theta_0)])
    xlabel("t (s)")
    ylabel("height (m)")
end