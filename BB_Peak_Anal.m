% Hello there
% here is a function to extract the peaks of an orbit. The inputs are
%       TRAJ: The trajectory of the bouncing ball
%       A: the amplitude of the table oscillation

function heights = BB_Peak_Anal(TRAJ,A)
    L = length(TRAJ);
    DIFF = TRAJ(1:L-1) - TRAJ(2:L);
    PROD = DIFF(1:L-2) .* DIFF(2:L-1);
    CHANGES = find(PROD <= 0) + 1;
    CRIT_POINTS = TRAJ(CHANGES);
    heights = CRIT_POINTS(CRIT_POINTS > A / 1000);
end