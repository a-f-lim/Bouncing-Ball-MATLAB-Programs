% GET TRAJECTORY
% Combines impactCalculator and stickySolCalc to generate the full trajectory
% of a bouncing ball on a sinusoidally oscillating table.
%
% Physics Model:
%   - BOUNCING PHASE: Ball is in free fall, with impacts governed by 
%     coefficient of restitution e
%   - STICKY PHASE: Ball moves with the table, constrained by surface normal
%   - TRANSITION: Ball enters sticky when v_ball <= v_table
%                 Ball exits sticky when table acceleration exceeds gravity
%
% Inputs:
%   v         (m/s):  initial velocity of ball (upward positive)
%   theta_0   (rad):  initial phase angle of table oscillation
%   A         (mm):   amplitude of table oscillation
%   e         (--):   coefficient of restitution (0 < e <= 1)
%   T         (ms):   period of table oscillation
%   secs      (s):    simulation duration
%   graph     (bool): whether to generate a graph or not of the trajectory
%
% Outputs:
%   theta     (rad):  phase angle at end of simulation
%   v         (m/s):  velocity at end of simulation
%

function [theta_final, v_final] = getTraj(v, theta_0, A, e, T, secs, graph)
    % Convert to consistent units (meters, seconds)
    T_sec = T / 1000;
    A_m = A / 1000;
    
    % Parameters
    omega = 2 * pi / T_sec;
    g = 9.81;
    dt_plot = T_sec / 100;  % Time resolution for plotting
    
    % Initialize time and phase tracking
    t_elapsed = 0;           % Elapsed time in simulation
    theta = theta_0;         % Current phase angle
    
    % Storage for plotting
    t_plot = [];
    y_ball_plot = [];
    y_table_plot = [];
    
    % Initial state
    canBeSticky = true;  % Currently in sticky phase?
    
    % ========== MAIN SIMULATION LOOP ==========
    while t_elapsed < secs
        % Current table position and velocity
        y_table = A_m * sin(theta);
        v_table = A_m * omega * cos(theta);
        
        % Current ball position (at start of this phase)
        y_ball = y_table;
        
        % Determine phase (sticky or bouncing)
        if v <= v_table && canBeSticky
            % ===== ENTER STICKY PHASE =====
            
            % How long will the ball remain stuck?
            t_unstick = stickySolCalc(A, T, theta);
            
            % Actual duration (capped by remaining simulation time)
            t_phase = min(t_unstick, secs - t_elapsed);
            
            % Simulate sticky phase: ball moves with table
            N = max(15, ceil(t_phase / dt_plot));
            t_substeps = linspace(0, t_phase, N);
            t_current_vec = t_elapsed + t_substeps;
            theta_current_vec = theta_0 + omega * t_current_vec;
            y_current_vec = A_m * sin(theta_current_vec);
            
            % Store for plotting
            t_plot = [t_plot, t_current_vec];
            y_table_plot = [y_table_plot, y_current_vec];
            y_ball_plot = [y_ball_plot, y_current_vec];
            
            % Update state at end of sticky phase
            theta = theta_0 + omega * (t_elapsed + t_phase);
            if t_phase == t_unstick
                % Ball unsticks: velocity equals table velocity at unstick moment
                v = A_m * omega * cos(theta);
                canBeSticky = false;
            else
                % Simulation ended while sticky
                v = A_m * omega * cos(theta);
                t_elapsed = secs;
                break;
            end
            
            t_elapsed = t_elapsed + t_phase;
            
        else
            % ===== ENTER BOUNCING PHASE =====
            
            % Time to next impact
            t_impact = impactCalculator(v, theta, A, T);
            
            % Actual duration (capped by remaining simulation time)
            t_phase = min(t_impact, secs - t_elapsed);
            
            % Simulate bouncing phase: free fall
            N = max(15, ceil(t_phase / dt_plot));
            t_substeps = linspace(0, t_phase, N);
            t_current_vec = t_elapsed + t_substeps;
            
            % Ball trajectory during free fall
            y_ball_vec = y_ball + v * t_substeps - (g / 2) * t_substeps.^2;
            
            % Table trajectory (phase advances with time)
            theta_current_vec = theta + omega * t_substeps;
            y_table_vec = A_m * sin(theta_current_vec);
            
            % Store for plotting
            t_plot = [t_plot, t_current_vec];
            y_ball_plot = [y_ball_plot, y_ball_vec];
            y_table_plot = [y_table_plot, y_table_vec];
            
            % Update state at end of bouncing phase
            theta = theta + omega * t_phase;
            
            if t_phase == t_impact && (t_elapsed + t_phase) < secs
                % Impact occurred: apply restitution
                v_ball_before = v - g * t_impact;
                v_table_impact = A_m * omega * cos(theta);
                
                % Restitution equation: v_ball_after = (1+e)*v_table - e*v_ball_before
                v = (1 + e) * v_table_impact - e * v_ball_before;
            else
                % Simulation ended during flight
                v = v - g * t_phase;
                t_elapsed = secs;
                break;
            end
            
            canBeSticky = true;
            t_elapsed = t_elapsed + t_phase;
        end
    end
    
    % ========== PLOTTING ==========
    if graph
        figure(1);
        clf;
        hold on;
        
        plot(t_plot, y_table_plot, 'r-', 'LineWidth', 1.5, 'DisplayName', 'Table');
        plot(t_plot, y_ball_plot, 'b-', 'LineWidth', 1.5, 'DisplayName', 'Ball');
        
        xlabel('Time (s)', 'FontSize', 12);
        ylabel('Height (m)', 'FontSize', 12);
        title('Bouncing Ball on Oscillating Table', 'FontSize', 14);
        grid on;
        legend('FontSize', 11);
        hold off;
    end

    % Final outputs
    theta_final = theta;
    v_final = v;
end
