%Hello there. 
%
%The following is code to compute a FFT on a discrete signal x_n
%   X (list) = discrete signal data
%   T (seconds) = time between consecutive datapoints in X

function FFT = BB_FFT(T,X)
    %here are the parameters
    Fs = 1/T;             % Sampling frequency
    N = numel(X);         % size of discrete signal dataset
    t = (0:N-1)*T;        % Time vector
    
    %plotting the corruption
    figure(2), clf
    plot(1000*t,X,"LineWidth",1)
    title("Signal In Question")
    xlabel("t (milliseconds)")
    ylabel("X(t)")
    
    %computing the FFT, please let there be a way to uncover f > 1000 Hz
    FFT = fft(X);
    
    %plotting the output of the FFT
    figure(3), clf
    f = Fs/N*(0:N-1);
    plot(f,abs(FFT) / N,"LineWidth",1) 
    title("A Frequency Spectrum of x(t)")
    xlabel("f (Hz)")
    ylabel("|X(f)| (relative)")
end