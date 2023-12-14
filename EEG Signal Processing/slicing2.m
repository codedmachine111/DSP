[header, rec] = edfread("p10_Record1.edf");


z=[]
for i=1:10803
    z(i, :) = cell2mat(header.EEGF8_Ref{i});
end

size(z)