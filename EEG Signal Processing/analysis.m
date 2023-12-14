x= load("rec1_seizure_1min.mat");
y = load("rec1_befseizure_1min.mat");
z = load("rec1_aftseizure_1min.mat");

y = y.y;
x = x.y;

x_pad = zeros(1,16384);
for i=1:length(x)
    x_pad(i) = x(i);
end

y_pad = zeros(1,16384);
for i=1:length(y)
    y_pad(i) = y(i);
end


[rows,cols] = size(x);

t = 1:1:length(x_pad);

whos;
start_time = tic;

% X = calcDFT(x,cols);
% size(X)

X = calcDIFFFT(x_pad,length(x_pad));
fftshift(X);

Y = calcDIFFFT(y_pad, length(y_pad));
fftshift(Y);

% X = calcDFT(x,length(x));
% fftshift(X);
% 
% Y = calcDFT(y, length(y));
% fftshift(Y);

% Z = DFT(z);
% fftshift(Z);

m1 = mean(x);
disp("Mean of Seizure signal: " + num2str(m1))
m2 = mean(y);
disp("Mean of Non-Seizure signal: " + num2str(m2))

% m3 = mean(z);

s1 = std(x);
disp("Standard deviation of Seizure signal: " + num2str(s1))

s2 = std(y);
disp("Standard deviation of Non-Seizure signal: " + num2str(s2))

% s3 = std(z);

abx = abs(X);
phx = angle(X);

aby = abs(Y);
phy = angle(Y);

% abz = abs(Z);
% phz = angle(Z);

whos;
elapsed_time = toc(start_time);
mem_info = whos;
mem_used = sum([mem_info.bytes]);

disp(['Elapsed time: ' num2str(elapsed_time) ' seconds'])
disp(['Total memory used: ' num2str(mem_used / (1024 ^ 2)) ' MB'])

% Plotting the NON-SEIZURE TIME SIGNAL BEFORE EPILEPSY
subplot(3,3,1);
plot(t,y_pad)
xlabel("Time")
ylabel("Amplitude")
title("Non Seizure time signal")

subplot(3,3,4);
plot(t,aby)
xlabel("Frequency")
ylabel("Amplitude")
title("FFT Amplitude spectrum")

subplot(3,3,7);
plot(t,phy)
xlabel("Frequency")
ylabel("Amplitude")
title("FFT Phase spectrum")

% Plotting the SEIZURE TIME SIGNAL
subplot(3,3,2);
plot(t,x_pad)
xlabel("Time")
ylabel("Amplitude")
title("Seizure time signal")

subplot(3,3,5);
plot(abx)
xlabel("Frequency")
ylabel("Amplitude")
title("FFT Amplitude spectrum")

subplot(3,3,8);
plot(t,phx)
xlabel("Time")
ylabel("Amplitude")
title("FFT Phase spectrum")


