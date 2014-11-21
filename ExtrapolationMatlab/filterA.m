function [Standard_Error, dat_50_100, xtp, fil] = filterA(k1, MAX_ALPHA1, k2, MAX_ALPHA2, k3, MAX_ALPHA3, k4, MAX_ALPHA4)

% filter
Wp = 25/50;             % units *pi rad
Ws = 39.36/50;
Rp = -20*log10(0.95);
Rs = 18; %-20*log10(0.05);  %18, 8
%[od, wn]=cheb2ord(Wp, Ws, Rp, Rs);
%[B,A]=cheby2(od, Rs, wn);
[od, wn]= buttord(Wp, Ws, Rp, Rs);
[B,A] = butter(od, wn);
 dat_300=dlmread('LOG09.txt');%load data, which is sampled at 300 Hz
% dat_300=dlmread('LOG12.txt');%load data, which is sampled at 300 Hz
% dat_300=dlmread('Jason Flight Data.txt');%load data, which is sampled at 300 Hz
% row = 1;


dat_100=dat_300(1:3:end,:);%downsample to 100Hz
dat_50=dat_300(1:6:end,:);%downsample to 50Hz
% dat_25=dat_300(1:12:end,:);%downsample to 25Hz
ratio = round(length(dat_100)/length(dat_50));
% Interpolate before hand since it's a waste of time to actually
% interpolate everytime we extrapolate. The realism is kept by replace the
% extrapolated point by the interpolated point. 
% interData = (dat_50)';
% t = 2:2:length(dat_50);
% x = 1:1:(2*length(dat_50));
% y = interp1(t, interData,x, 'spline');
% plot(t,interData, 'o', x, y)



dat_50_100 = upsample(dat_50, ratio);
dat_50_100 = (dat_50_100)';

dat_100 = transpose(dat_100);

if length(dat_50_100) > length(dat_100)
    dat_50_100 = dat_50_100(:,1:length(dat_100));        
end

if mod(length(dat_50_100),2) == 0              % check if the length of the matrix is odd or even
     L = (length(dat_50_100)/2);                % so vector won't get an extra element if odd.
else
     L = ((length(dat_50_100)-1)/2);
end
 
dat_50 = transpose(dat_50);
temp = zeros(1,2);
xtp = dat_50_100;
fil = dat_50_100;
y = zeros(1,3);
for row=1:4
    switch row
        case 1
            MAX_ALPHA = MAX_ALPHA1;
            k = k1;
        case 2
            MAX_ALPHA = MAX_ALPHA2;
            k = k2;
        case 3
            MAX_ALPHA = MAX_ALPHA3;
            k = k3;
        otherwise
            MAX_ALPHA = MAX_ALPHA4;
            k = k4;
    end
    for i=1:L
%     slope = dat_50_100(1,ratio*i-1) - dat_50_100(1,ratio*i-3);
        if i==1 
            dat_50_100(row,ratio*i) = dat_50(row,i);        % set 2nd pt = 1st pt
            tp = dat_50_100(row, 1:ratio*i);                % extract data from begin to current pt
            x = filter(B, A, tp);                           % filter
            fil(row, ratio*i) = x(length(x));
            fil(row, ratio*i) = round(fil(row, ratio*i));  
            xtp(row, ratio*i) = dat_50_100(row,ratio*i);
        else
        
        % The line below means that there's an optimal slope that would
        % give the best alpha. That alpha would in turn give the smallest
        % standard error. Using fminsearch, we are looking for value k and
        % slope. With slope and k found, we then can compute alpha. The
        % idea is that we assume the general shape of alpha(slope) to be 
        % piecewise linear (linearly increasing and then level out).
        % This implies that there will be a point where slope will keep on
        % increasing and alpha would remain the same because any further
        % increase in alpha would NOT result in a smaller standard error.
        
%         alpha = k*slope;        % Note: slope is the slope between 2 data points,
                                % find optimal alpha by finding optimal k
                                % and optimal slope
            slope = dat_50_100(row,ratio*i-1) - dat_50_100(row,ratio*i-3);
            alpha = k*abs(slope);
            alpha = min(alpha, MAX_ALPHA);
            
             temp(2)=dat_50_100(row,ratio*i-1);
             temp(1)=dat_50_100(row,ratio*i-3);
             y = interPol(temp); 
             dat_50_100(row, ratio*i-2) = y(2);        

            %dat_50_100(row, ratio*i-2) =              
            dat_50_100(row,ratio*i) = dat_50_100(row,ratio*i-1) + alpha*((dat_50_100(row,ratio*i-1) - dat_50_100(row,ratio*i-3)));
            tp = dat_50_100(row, 1:ratio*i);
            x = filter(B, A, tp);
            fil(row, ratio*i) = x(length(x));
            fil(row, ratio*i) = round(fil(row, ratio*i));  
            xtp(row, ratio*i) = dat_50_100(row,ratio*i);
        % dat_50_100 is storing all interpolation
        end
    end    
end

temp(2)=dat_50_100(row,17719);
temp(1)=dat_50_100(row,17717);
y = interPol(temp); 
dat_50_100(row, 17718) = y(2);  
diff = zeros(4, length(dat_50_100));
% diff(row,:) = dat_50_100(row,:) - dat_100(row,:);

% range = 1:length(diff);
%  subplot(2,1,1), plot(range,diff,'o')
%  subplot(2,1,2), plot(range,dat_50_100(row,:),'o',range,dat_100(row,:),'-r')

    Standard_Error =  zeros(1,4);
for row=1:4
    diff(row,:) = fil(row,:) - dat_100(row,:);
    Standard_Error(1,row) = std(diff(row,:));
end
end

