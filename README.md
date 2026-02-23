BB_Traj(v,theta_0,alpha,A,T,N,plot): takes in an 
    initial velocity (v)
    table phase shift (theta_0)
    coefficient of restitution (alpha)
    amplitude of oscillation in mm (A)
    period of oscillation in ms (T)
    number of discrete data points (N)
and calculates the trajectory of the ball at t=0,dt,...,(N-1)dt. If a plot is desired, then plot = true. 

BB_FFT(T,X): takes in the 
    length of time between consecutive points (T)
    discrete signal (X) 
    
and computes the discrete Fourier transform of the signal.
Usually, X is the output of BB_Traj and T is the dt from BB_Traj, which is dt = 0.0001 s.

BB_Peak_Anal(TRAJ,A): Under the assumption that the ball does not undergo a sticking-type solution, this takes in a
    trajectory of the ball (TRAJ)
    amplitude of table oscillation in mm (A)
and computes the heights of the ball's path in between impacts

BB_bifurcation_(peak/phase)(v,theta_0,A_i,A_f,e,T): takes in the
    initial velocity (v)
    table phase shift (theta_0)
    starting and ending amplitudes of oscillation in mm (A_i and A_f)
    coefficient of restitution (e)
    period of oscillation in ms (T)
and plots the peaks/impact phases of the ball's trajectory as the amplitude varies from A_i to A_f in intervals of 0.0025 mm.
