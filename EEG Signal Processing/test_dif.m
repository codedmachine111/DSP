x = load("rec1_seizure.mat");
x = x.ip;
length(x)

y = zeros(1,262144);
length(y)
for i=1:length(x)
    y(i) = x(i);
end

pad = zeros(1,39644);
length(pad)

for i=(length(x)+1):length(pad)
    y(i) = pad(i);
end

X = dif_fft(y,length(y));
fftshift(X);

abx = abs(X);
fftshift(abx);

phx = angle(X);

subplot(3,1,1);
plot(y)
xlabel("Time")
ylabel("Amplitude")
title("Signal before epilepsy")

subplot(3,1,2);
plot(abx)
xlabel("Frequency")
ylabel("Amplitude")
title("FFT Amplitude spectrum")

subplot(3,1,3);
plot(phx)
xlabel("Frequency")
ylabel("Amplitude")
title("FFT Phase spectrum")

function [X] = dif_fft(x,N)
    p=log2(N);                                 % computing the number of conversion stages
    Half=N/2;                                  % half the length of the array
    for stage=1:p                             % stages of transformation
        for index=0:(N/(2^(stage-1))):(N-1)    % series of "butterflies" for each stage
            for n=0:(Half-1)                   % creating "butterfly" and saving the results

                pos=n+index+1;                 % index of the data sample
                
                pow=(2^(stage-1))*n;           % part of power of the complex multiplier
                w=exp((-1i)*(2*pi)*pow/N);     % complex multiplier

                a=x(pos)+x(pos+Half);          % 1-st part of the "butterfly" creating operation
                b=(x(pos)-x(pos+Half)).*w;     % 2-nd part of the "butterfly" creating operation

                x(pos)=a;                      % saving computation of the 1-st part
                x(pos+Half)=b;                 % saving computation of the 2-nd part
            end
        end
    Half=Half/2;                               % computing the next "Half" value
    end
    X=bitrevorder(x);
end
