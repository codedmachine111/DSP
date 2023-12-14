clc 
clear
x = [3,-1,0,1,3,2,0,1,2,1];
h = [1,1,1];

M = 3;
L = 3;
N = L + M -1;

% Overlap add

% get sub arrays
x1 = calcPadding(x,L,M,1);
x2 = calcPadding(x,L,M,4);
x3 = calcPadding(x,L,M,7);
x4 = calcPadding(x,L,M,10);

% padding Impulse Response (M-1)
hnew = calcPadding(h,3,M,1);

% Circular conv.
y1 = int8(real(circConv(x1,hnew,N)))
y2 = int8(real(circConv(x2,hnew,N)))
y3 = int8(real(circConv(x3,hnew,N)))
y4 = int8(real(circConv(x4,hnew,N)));

% Add overlap
y = [];
j=1;
k=1;
for i =1:length(y1)
    if(i > L)
        y(j) = y1(i) + y2(k);
        j = j+1;
        k = k+1;
    elseif(i <= L)
        y(j) = y1(i);
        j = j+1;
    end
end
k=1;
for i =M:length(y2)
   if(i > length(y2)-M+1)
        y(j) = y2(i) + y3(k);
        j = j+1;
        k = k+1;
   elseif(i == L)
        y(j) = y2(i);
        j = j+1;
   end
end
k=1;
for i =M:length(y3)
   if(i > length(y3)-M+1)
        y(j) = y3(i) + y4(k);
        j = j+1;
        k = k+1;
   elseif(i == L)
        y(j) = y3(i);
        j = j+1;
   end
end
for i =M:length(y4)
   if(i == L)
    y(j) = y4(i);
    j = j+1;
   end
end
y
