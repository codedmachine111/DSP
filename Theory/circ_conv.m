a = [1,2,3,1];
h = [4,3,2,2];

N = 4;

X = calcDFT(a,N)
H = calcDFT(h,N)

t = 0:1:N;

Z = X.*H

y = calcIDFT(Z,N)

% Magnitude plot 1
X = abs(X);
n1 = 0:1:N-1;
subplot(4,2,3)
stem(n1,X)
xlabel("Samples")
ylabel("Mod(X)")
title("Magnitude plot")

% Magnitude plot 2
H = abs(H);
n1 = 0:1:N-1;
subplot(4,2,4)
stem(n1,H)
xlabel("Samples")
ylabel("Mod(H)")
title("Magnitude plot")


function e = expValue(n,k,N)
    e = exp((-1i * 2 * pi * k * n)/N);
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

