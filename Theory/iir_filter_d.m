syms s H(s)
clc
Kp = -1;
Op = 4;
Ks = -20;
Os = 8;

nOp= Op/4;
nOs = Os/4;

N = ceil(log((10^(-0.1*Kp) -1)/(10^(-0.1*Ks) -1))/(2*log(nOp/nOs)));

pos=[];
for k=0:4
    theta_k = ((pi * k)/N) + (pi/(2*N)) + pi/2;
    p = cos(theta_k) + 1i*sin(theta_k);
    pos(k+1) = p;
end

pos

Oc = Op/((10^(-0.1*Kp) -1)^(1/(2*N)))

sys = zpk(0,pos,1);
sys