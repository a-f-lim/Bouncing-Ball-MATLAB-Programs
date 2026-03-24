Throughout all programs, the following input scheme is standardized:

	v (m/s): an initial velocity

	theta_0/theta: an initial phase for where the table starts
        
	A/Amps (mm): amplitude(s) of oscillation for the table
        
	e: a coefficient of restitution between the ball and table
        
	T (ms): the period of oscillation for the table 

t_imp = impactCalculator(v,theta_0,A,T)

In the case where the ball's velocity relative to the table is positive, this program computes the time when the ball and table next hit each other (t_imp).

t_unstuck = stickySol(theta_0,A,T)

In the case where the ball's velocity relative to the table is negative, this program computes the time when the ball stops moving with the table (t_unstuck). If this never happens, t_unstuck = Inf.

[theta,v] = getTraj(v,theta,A,e,T,secs)

This program provides a height vs. time graph for both the ball and the table after some number of seconds (secs). The outputs are the phase at which the last recorded impact happened (theta) and the velocity at which the ball leaves the table after said impact (v).

[imp_phases,theta,v] = getImps(v,theta,A,e,T,imp_count)

This program computes the phases of the first number of impacts (imp_count) from an initial starting point, which is stored in imp_phases. The outputs theta and v mean the same as in getTraj.

Points_to_Plot = bifurcationDiagram(v,theta,Amps,e,T)

This program generates a bifurcation diagram for the long term behavior of the bouncing ball model through its impact phases as the amplitude varies throughout the array Amps. The pairs (A,theta) recorded on the bifurcation diagram are returned in Points_to_Plot.

phaseVariance(PtP)

PtP is shorthand for points to plot, which is a list of ordered pairs (A,theta). The program generates a visual of where in amplitude space that period doubling/chaotic cascading occurs that is easier to see than directly from the bifurcation diagram.
