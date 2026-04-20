% BIFURCATION DIAGRAM (Improved)
% Generates a bifurcation diagram for the bouncing ball model by tracking
% impact phases as the table amplitude varies.
%
% This version improves upon the original by:
%   - Properly handling transients at the first amplitude
%   - Using consistent transient elimination at each amplitude
%   - Better error handling and edge case management
%   - More flexible amplitude scanning
%   - Returns both plot data and figure handle
%
% Inputs:
%   v         (m/s):  initial velocity of ball (upward positive)
%   theta_0   (rad):  initial phase angle of table oscillation
%   Amps      (mm):   vector of amplitudes to scan (can be increasing or decreasing)
%   e         (--):   coefficient of restitution (0 < e <= 1)
%   T         (ms):   period of table oscillation
%   n_trans   (int):  number of impacts to skip as transients (default: 300)
%   n_sample  (int):  number of phases to record at each amplitude (default: 150)
%   verbose   (bool): print progress information (default: true)
%
% Outputs:
%   Points_to_Plot (array): [amplitude, phase] pairs for plotting
%   fig (handle):           figure handle to the plotted bifurcation diagram

function [Points_to_Plot, fig] = bifurcationDiagram(v, theta_0, Amps, e, T, n_trans, n_sample, verbose)
    % Set default parameters
    if nargin < 6
        n_trans = 300;      % Default transient skip count
    end
    if nargin < 7
        n_sample = 150;     % Default sample count per amplitude
    end
    if nargin < 8
        verbose = true;     % Default verbose mode
    end
    
    % Validate inputs
    if isempty(Amps)
        error('Amps cannot be empty');
    end
    if n_trans < 0 || n_sample <= 0
        error('n_trans must be non-negative and n_sample must be positive');
    end
    
    % Initialize state at first amplitude with transient elimination
    if verbose
        fprintf('\n========== BIFURCATION DIAGRAM GENERATOR ==========\n');
        fprintf('Initializing system at first amplitude A = %g mm\n', Amps(1));
    end
    
    % Eliminate transients at the first amplitude
    theta = theta_0;
    v = v;
    [phases_init, theta, v] = getImpPhases(v, theta, Amps(1), e, T, n_trans);
    
    if length(phases_init) < n_trans
        if verbose
            fprintf('Warning: Only %d transient impacts recorded at A = %g mm (requested %d)\n', ...
                    length(phases_init), Amps(1), n_trans);
        end
    end
    
    % theta and v already updated by getImpPhases initialization call
    
    % Arrays to store bifurcation data
    amp_plot = [];
    theta_plot = [];
    
    % ========== MAIN AMPLITUDE SWEEP LOOP ==========
    n_amps = length(Amps);
    for idx = 1:n_amps
        A = Amps(idx);
        
        if verbose
            fprintf('Amplitude %d/%d: A = %g mm ... ', idx, n_amps, A);
        end
        
        % Record impacts at this amplitude
        % Request n_trans + n_sample total impacts
        % We skip the first n_trans (transients) and plot the rest
        total_impacts = n_trans + n_sample;
        [phases, theta, v] = getImpPhases(v, theta, A, e, T, total_impacts);
        
        n_phases = length(phases);
        
        if n_phases == 0
            if verbose
                fprintf('ERROR: No impacts recorded\n');
            end
            continue;
        end
        
        % Determine which phases to plot (skip transients)
        if n_phases <= n_trans
            % Didn't reach past transients; only plot final phase
            if verbose
                fprintf('WARNING: Only %d impacts (< %d transients); plotting endpoint\n', ...
                        n_phases, n_trans);
            end
            theta_to_plot = phases(end);
        else
            % Plot phases after transient elimination
            theta_to_plot = phases(n_trans+1:end);
        end
        
        % Add to plot arrays
        n_to_plot = length(theta_to_plot);
        amp_plot_ADD_ON = A * ones(1, n_to_plot);
        theta_plot_ADD_ON = theta_to_plot(:)';
        
        amp_plot = [amp_plot, amp_plot_ADD_ON];
        theta_plot = [theta_plot, theta_plot_ADD_ON];
        
        if verbose
            fprintf('recorded %d phases (transient: %d, sample: %d)\n', ...
                    n_to_plot, min(n_trans, n_phases), max(0, n_to_plot));
        end
        
        % State (theta, v) is already updated by getImpPhases
    end
    
    Gamma_plot = (amp_plot / 1000) * ((2 * pi / (T / 1000)) ^ 2 / 9.81);
    % ========== PLOTTING ==========
    if verbose
        fprintf('\nGenerating plot ... ');
    end
    
    fig = figure(5);
    clf;
    hold on;
    
    scatter(Gamma_plot, theta_plot, 1, 'black', 'filled');
    
    grid on;
    xlabel('Normalized Acceleration ( \Gamma = A\omega^2 / g)', 'FontSize', 12);
    ylabel('Impact Phase (rad)', 'FontSize', 12);
    title('Bouncing Ball Bifurcation Diagram', 'FontSize', 13, 'FontWeight', 'bold');
    axis([Gamma_plot(1), Gamma_plot(end), -pi, pi]);
    
    hold off;
    
    if verbose
        fprintf('Done.\n');
        fprintf('Total points plotted: %d\n', length(amp_plot));
        fprintf('========== COMPLETE ==========\n\n');
    end
    
    % Package output
    Points_to_Plot = [amp_plot', theta_plot'];
end