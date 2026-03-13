BB_Traj(v,theta_0,alpha,A,T,N,graph): takes in an 
    initial velocity (v)
    table phase shift (theta_0)
    coefficient of restitution (alpha)
    amplitude of oscillation in mm (A)
    period of oscillation in ms (T)
    number of discrete data points (N)
and calculates the trajectory of the ball at t=0,dt,...,(N-1)dt. If a plot is desired, then graph = true. 

BB_FFT(T,X): takes in the 
    length of time between consecutive points (T)
    discrete signal (X) 
    
and computes the discrete Fourier transform of the signal.
Usually, X is the output of BB_Traj and T is the dt from BB_Traj, which is dt = 0.0001 s.

BB_Peak_Anal(TRAJ,A): Under the assumption that the ball does not undergo a sticking-type solution, this takes in a
    trajectory of the ball (TRAJ)
    amplitude of table oscillation in mm (A)
and computes the heights of the ball's path in between impacts

BB_bifurcation_(peak/phase)(v,theta_0,Amps,e,T): takes in the
    initial velocity (v)
    table phase shift (theta_0)
    the list of amplitudes of oscillation in mm (Amps)
    coefficient of restitution (e)
    period of oscillation in ms (T)
and plots the peaks/impact phases of the ball's trajectory as the amplitude varies across the list.
