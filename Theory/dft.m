% sine signal
f = 1;     % signal frequency
sps = 10;    % samples per signal period
Fs = sps*f;  % samples per second
dt = 1/Fs;   % seconds per sample (time increment)
t = (0:dt:pi); % 5 seconds of data (time)
s = sin(2*pi*f*t); % 5 seconds of data (sinus)

s
length(s)

N = input("Enter DFT points: ")

if(N == length(s))
    X = calcDFT(s,N)
    u = calcIDFT(X,N)
end

% Original signal
subplot(4,1,1)
stem(t,s)
xlabel("Time")
ylabel("Amplitude")
title("Original Time domain signal")

% Magnitude plot
Y = [];
for i=1:length(X)
    Y(i) = absolute(X(i));
end

% Y = abs(X);
n1 = 0:1:N-1;
subplot(4,1,2)
stem(n1,Y)
xlabel("Samples")
ylabel("Mod(X)")
title("Magnitude plot")

% Phase plot

Z = [];
for i=1:length(X)
    Z(i) = calcAngle(X(i));
end

% Z = angle(X);
subplot(4,1,3)
stem(n1,Z)
xlabel("Samples")
ylabel("Phase(X)")
title("Phase plot")

% IDFT plot
subplot(4,1,4)
stem(n1,u)
xlabel("Time")
ylabel("Amplitude")
title("IDFT Plot to get Time domain signal")

function e = expValue(n,k,N)
    e = exp((-1i * 2 * pi * k * n)/N);
end

function [X] = calcDFT(x,N)
    for k = 0:N-1
        sum =0;
        for i = 1:length(x)
            e = expValue(i-1, k, N);
            y = x(i) * e;
            sum = sum + y;
        end
        X(k+1) = sum;
    end
    X = X;
end

function abs = absolute(n)
    abs = sqrt(((real(n))^2)+((imag(n))^2));
end

function angle = calcAngle(n)
    angle = atan((imag(n))/(real(n)));
end

function [u] = calcIDFT(X, N)
    u = [];
    for n = 0:N-1
        sum = 0;
        for k = 0:N-1
            e = exp((1i * 2 * pi * k * n) / N);
            y = X(k + 1) * e;
            sum = sum + y;
        end
        u(n + 1) = sum / N;
    end
end

