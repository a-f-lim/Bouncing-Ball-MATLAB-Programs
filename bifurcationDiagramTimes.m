% BIFURCATION DIAGRAM TIMES
% Generates a bifurcation diagram for the bouncing ball model by tracking
% the normalized time interval from liftoff to the first leave event, then
% between consecutive table-leave events thereafter.
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
%   n_trans   (int):  number of intervals to skip as transients (default: 300)
%   n_sample  (int):  number of intervals to record at each amplitude (default: 150)
%   verbose   (bool): print progress information (default: true)
%
% Outputs:
%   Points_to_Plot (array): [amplitude, delta_t_over_T] pairs for plotting
%   fig (handle):           figure handle to the plotted bifurcation diagram

function [Points_to_Plot, fig] = bifurcationDiagramTimes(v, theta_0, Amps, e, T, n_trans, n_sample, verbose)
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

    % Initialize state at first amplitude with transient elimination
    if verbose
        fprintf('\n========== BIFURCATION DIAGRAM TIMES GENERATOR ==========\n');
        fprintf('Initializing system at first amplitude A = %g mm\n', Amps(1));
    end

    theta = theta_0;

    % To remove n_trans intervals, we need n_trans + 1 leave events.
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
    frac_plot = [];

    % ========== MAIN AMPLITUDE SWEEP LOOP ==========
    n_amps = length(Amps);
    for idx = 1:n_amps
        A = Amps(idx);

        if verbose
            fprintf('Amplitude %d/%d: A = %g mm ... ', idx, n_amps, A);
        end

        % Collect the first n_trans + n_sample leave events at this amplitude.
        % The first plotted interval is intentionally from t = 0 to the first
        % leave event, so the leave-event count aligns with the phase-based
        % bifurcation script.
        total_leave_events = n_trans + n_sample;
        [leave_times, theta, v] = getLeaveTimes(v, theta, A, e, T, total_leave_events);

        n_leaves = length(leave_times);
        if n_leaves < 2
            if verbose
                fprintf('ERROR: Not enough leave events to form intervals\n');
            end
            continue;
        end

        % Leave-event interval fractions: the first interval is t = 0 to the
        % first leave event, then the rest are consecutive differences.
        leave_intervals = diff([0;leave_times]);
        frac_intervals = leave_intervals / T_sec;
        n_intervals = length(frac_intervals);

        % Determine which intervals to plot (skip transients)
        if n_intervals <= n_trans
            if verbose
                fprintf('WARNING: Only %d intervals (< %d transients); plotting endpoint\n', ...
                        n_intervals, n_trans);
            end
            frac_to_plot = frac_intervals(end);
        else
            frac_to_plot = frac_intervals(n_trans + 1:end);
        end

        n_to_plot = length(frac_to_plot);
        amp_plot = [amp_plot, A * ones(1, n_to_plot)];
        frac_plot = [frac_plot, frac_to_plot(:)'];

        if verbose
            fprintf('recorded %d interval fractions (transient: %d, sample: %d)\n', ...
                    n_to_plot, min(n_trans, n_intervals), max(0, n_to_plot));
        end
    end

    Gamma_plot = (amp_plot / 1000) * ((2 * pi / (T / 1000)) ^ 2 / 9.81);

    % ========== PLOTTING ==========
    if verbose
        fprintf('\nGenerating plot ... ');
    end

    fig = figure(6);
    clf;
    hold on;

    scatter(Gamma_plot, frac_plot, 1, 'black', 'filled');

    grid on;
    xlabel('Normalized Acceleration ( \Gamma = A\omega^2 / g)', 'FontSize', 12);
    ylabel('Leave-Interval Fraction (\tau_{k} = t_{k}-t_{k-1} / T)', 'FontSize', 12);
    title('Bouncing Ball Bifurcation Diagram (Leave-Time Intervals)', ...
          'FontSize', 13, 'FontWeight', 'bold');

    if ~isempty(Gamma_plot)
        axis([min(Gamma_plot), max(Gamma_plot), min(frac_plot), max(frac_plot)]);
    end

    hold off;

    if verbose
        fprintf('Done.\n');
        fprintf('Total points plotted: %d\n', length(amp_plot));
        fprintf('========== COMPLETE ==========\n\n');
    end

    % Package output
    Points_to_Plot = [amp_plot', frac_plot'];
end