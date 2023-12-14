x = load("EEGFp2_data.mat");

x = x.resultMatrix;
x = x(8200:8230,:);

size(x)

y = [];
k=1;
for i=1:30
    for j=1:500
        y(k) = x(i,j);
        k = k+1;
    end
end

size(y)
save("rec1_aftseizure_1min.mat","y")