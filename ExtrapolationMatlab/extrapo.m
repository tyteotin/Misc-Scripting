function [ Out ] = extrapo(dat_50, dat_100)
% Crappy up-sample algorithm that overshoots tons of data compared to
% original down-sample of the same frequency
%   Inputs are matrices that are down-sampled from 300Hz, one is preferably
%   half of the other in term of frequency.
%   1st param = lower freq, 2nd param higher freq
%   Adding the difference between 2 previous, already received data points
%   to the current data point to predict the next one. The first data point
%   is always given, and the second data point is always equal to the
%   first. Out is a matrix that carries the same data as the lower
%   frequency down-sample input for every ODD elements. This algorithm will
%   try to predict every EVEN elements based on the previous 2 elements.

dat_25_50 = zeros(size(transpose(dat_50)));
dat_50_100 = zeros(size(transpose(dat_100)));
dat_50 = transpose(dat_50);
dat_100 = transpose(dat_100);

if mod(length(dat_50_100),2) == 0              % check if the length of the matrix is odd or even
    L = (length(dat_50_100)/2);                % so vector won't get an extra element if odd.
else
    L = ((length(dat_50_100)-1)/2);
end    
for j=1:4
for k=1:length(dat_50)
    dat_50_100(j,2*k-1) = dat_50(j,k);        % passing all data from 50Hz to 100Hz
end
end

for i=1:L
    if i==1
        dat_50_100(1,2*i) = dat_50(1,i);
    else
        dat_50_100(1,2*i) = dat_50_100(1,2*i-1) + (dat_50_100(1,2*i-1) - dat_50_100(1,2*i-2));
    end
end
 
diff = dat_50_100(1,:) - dat_100(1,:);
percentError = nnz(diff)/length(dat_100);
disp('Percent Error: ');
disp(percentError)
range_100 = 1:length(dat_100);
up = dat_50_100(1,:);
down = dat_100(1,:);
plot(range_100,up,'o',range_100,down,'-r')
title('up 100Hz vs down 100Hz')
xlabel('number of data')
ylabel('Data Value ( Voltage)')


end

