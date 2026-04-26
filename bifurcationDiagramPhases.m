% BIFURCATION DIAGRAM PHASES
% Generates a bifurcation diagram for the bouncing ball model by tracking
% leave-event phases computed from leave times.
%
% Leave events include:
%   - rebound immediately after impact
%   - release after a sticky phase
%
% Inputs:
%   v         (m/s):  initial velocity of ball (upward positive)
%   theta_0   (rad):  initial phase angle of table oscillation
%   Amps      (mm):   vector of amplitudes to scan (increasing or decreasing)
%   e         (--):   coefficient of restitution (0 < e <= 1)
%   T         (ms):   period of table oscillation
%   n_trans   (int):  number of phases to skip as transients (default: 300)
%   n_sample  (int):  number of phases to record at each amplitude (default: 150)
%   verbose   (bool): print progress information (default: true)
%
% Outputs:
%   Points_to_Plot (array): [amplitude, phase] pairs for plotting
%   fig (handle):           figure handle to the plotted bifurcation diagram

function [Points_to_Plot, fig] = bifurcationDiagramPhases(v, theta_0, Amps, e, T, n_trans, n_sample, verbose)
    % Set default parameters
    if nargin < 6
        n_trans = 300;
    end
    if nargin < 7
        n_sample = 150;
    end
    if nargin < 8
        verbose = true;
    end

    % Validate inputs
    if isempty(Amps)
        error('Amps cannot be empty');
    end
    if n_trans < 0 || n_sample <= 0
        error('n_trans must be non-negative and n_sample must be positive');
    end

    T_sec = T / 1000;
    omega = 2 * pi / T_sec;

    % Initialize state at first amplitude with transient elimination
    if verbose
        fprintf('\n========== BIFURCATION DIAGRAM PHASES GENERATOR ==========\n');
        fprintf('Initializing system at first amplitude A = %g mm\n', Amps(1));
    end

    theta = theta_0;

    % Keep the same transient initialization convention as times diagram.
    [leave_init, theta, v] = getLeaveTimes(v, theta, Amps(1), e, T, n_trans + 1);

    if length(leave_init) < (n_trans + 1)
        if verbose
            fprintf(['Warning: Only %d leave events recorded at A = %g mm ' ...
                     '(requested %d for transient elimination)\n'], ...
                    length(leave_init), Amps(1), n_trans + 1);
        end
    end

    % Arrays to store bifurcation data
    amp_plot = [];
    phase_plot = [];

    % ========== MAIN AMPLITUDE SWEEP LOOP ==========
    n_amps = length(Amps);
    for idx = 1:n_amps
        A = Amps(idx);

        if verbose
            fprintf('Amplitude %d/%d: A = %g mm ... ', idx, n_amps, A);
        end

        % Collect leave events at this amplitude.
        total_leave_events = n_trans + n_sample;
        theta_start = theta;
        [leave_times, theta, v] = getLeaveTimes(v, theta, A, e, T, total_leave_events);

        n_leaves = length(leave_times);
        if n_leaves < 1
            if verbose
                fprintf('ERROR: No leave events recorded\n');
            end
            continue;
        end

        % Phase mapping requested by user:
        % theta_k = mod(omega * t_k + theta_o + pi, 2*pi) - pi
        leave_phases = mod(omega * leave_times + theta_start + pi, 2 * pi) - pi;

        % Determine which phases to plot (skip transients)
        if n_leaves <= n_trans
            if verbose
                fprintf('WARNING: Only %d phases (< %d transients); plotting endpoint\n', ...
                        n_leaves, n_trans);
            end
            phase_to_plot = leave_phases(end);
        else
            phase_to_plot = leave_phases(n_trans + 1:end);
        end

        n_to_plot = length(phase_to_plot);
        amp_plot = [amp_plot, A * ones(1, n_to_plot)];
        phase_plot = [phase_plot, phase_to_plot(:)'];

        if verbose
            fprintf('recorded %d phases (transient: %d, sample: %d)\n', ...
                    n_to_plot, min(n_trans, n_leaves), max(0, n_to_plot));
        end
    end

    Gamma_plot = (amp_plot / 1000) * ((2 * pi / (T / 1000)) ^ 2 / 9.81);

    % ========== PLOTTING ==========
    if verbose
        fprintf('\nGenerating plot ... ');
    end

    fig = figure(7);
    clf;
    hold on;

    scatter(Gamma_plot, phase_plot, 1, 'black', 'filled');

    grid on;
    xlabel('Normalized Acceleration ( \Gamma = A\omega^2 / g)', 'FontSize', 12);
    ylabel('Phase (\theta)', 'FontSize', 12);
    title('Bouncing Ball Bifurcation Diagram (\theta vs. \Gamma)', ...
          'FontSize', 13, 'FontWeight', 'bold');

    if ~isempty(Gamma_plot)
        axis([min(Gamma_plot), max(Gamma_plot), -pi, pi]);
    end

    hold off;

    if verbose
        fprintf('Done.\n');
        fprintf('Total points plotted: %d\n', length(amp_plot));
        fprintf('========== COMPLETE ==========\n\n');
    end

    % Package output
    Points_to_Plot = [amp_plot', phase_plot'];
end
