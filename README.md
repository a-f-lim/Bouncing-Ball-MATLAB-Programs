BB_Traj(v,theta_0,alpha,A,T,N): takes in an initial velocity (v), table phase shift (theta_0), coefficient of restitution (alpha), amplitude of oscillation in mm (A), 
and period of oscillation in ms (T); calculates the trajectory of the ball at t=0,dt,...,(N-1)dt for some input N.

BB_FFT(T,X): takes in the length of time (T) between consecutive points in the discrete signal (X) and compute the discrete Fourier transform of the signal.
Usually, X is the output of BB_Traj and T is the dt from BB_Traj, which is dt = 0.0001 s.
