% GET IMPACT PHASES
% Simulates a bouncing ball on a sinusoidally oscillating table and records
% the phase angles at which impacts occur.
%
% Uses simplified state machine approach: tracks whether the ball was 
% previously in sticky or bouncing phase to determine the next phase.
%
% Inputs:
%   v         (m/s):  initial velocity of ball (upward positive)
%   theta_0   (rad):  initial phase angle of table oscillation
%   A         (mm):   amplitude of table oscillation
%   e         (--):   coefficient of restitution (0 < e <= 1)
%   T         (ms):   period of table oscillation
%   imp_count (int):  number of impacts to record
%
% Outputs:
%   phases    (rad):  phase angles of the first imp_count impacts
%                     phases(i) is the phase when the i-th impact occurs

function [phases, theta, v] = getImpPhases(v, theta_0, A, e, T, imp_count)
    % Convert to consistent units (meters, seconds)
    T = T / 1000;
    A = A / 1000;
    
    % Parameters
    omega = 2 * pi / T;
    g = 9.81;
    
    % Initialize
    theta = theta_0;
    phases = [];
    
    % State tracking: whether the ball was previously in sticky phase
    % 1 = previously sticky (or starting state), 0 = previously bouncing
    bounce_stuck = 1;
    
    % ========== MAIN SIMULATION LOOP ==========
    % Iterate until imp_count true impacts are recorded.
    impact_idx = 0;
    max_events = max(10 * imp_count, 1000);
    event_idx = 0;
    while impact_idx < imp_count
        event_idx = event_idx + 1;
        if event_idx > max_events
            warning('getImpPhases:maxEvents', ...
                    'Stopped after %d events before reaching %d impacts.', ...
                    max_events, imp_count);
            break;
        end

        % Current table velocity
        table_vel = A * omega * cos(theta);
        
        if v <= table_vel && bounce_stuck
            % ===== ENTER STICKY PHASE =====
            % Time to unstick from table
            tau = stickySolCalc(1000*A, 1000*T, theta);
            
            if isinf(tau)
                % Ball remains stuck indefinitely
                break;
            end
            
            % Velocity when leaving sticky phase
            v = A * omega * cos(omega * tau + theta);
            bounce_stuck = 0;  % Mark as previously sticky
            
        else
            % ===== ENTER BOUNCING PHASE =====
            % Time to next impact
            tau = impactCalculator(v, theta, 1000*A, 1000*T);
            
            % Velocity after impact (with restitution)
            v = (1 + e) * A * omega * cos(omega * tau + theta) - e * (v - g * tau);
            bounce_stuck = 1;  % Mark as previously bouncing
        end
        
        % Update phase angle
        theta = omega * tau + theta;
        
        % Normalize phase to [-pi, pi]
        theta = mod(theta + pi, 2 * pi) - pi;
        
        % Record only true impacts (not sticky release events)
        if bounce_stuck == 1
            impact_idx = impact_idx + 1;
            phases = [phases, theta];
        end
    end
    
    % Ensure output is column vector
    phases = phases(:);
end
