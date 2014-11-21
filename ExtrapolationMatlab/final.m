%[err, output, tmp, fi] = maxAlpha_Extrapo(0.2383, 0.4504, 0.1903, 0.4297, 0.3014, 0.4446, 0.2376, 0.4345);
[err, output, tmp, fi] = maxAlpha_Extrapo_B(0.2383, 0.4504, 0.1903, 0.4297, 0.3014, 0.4446, 0.2376, 0.4345);

dat_300=dlmread('LOG09.txt');
% downsample
dat_100=dat_300(1:3:end,:);

N = length(fi(1,:));
row1 = fi(1,:);
fft1 = abs(fft(row1,N));            % using abs since not worry about phase for now

row1_f = tsmovavg(fft1, 's', 100);
row1_f = circshift(row1_f, [0, -50]);
N = floor(length(row1_f)/2);
row1_f_half = row1_f(1:N);
range = ((1:length(row1_f_half))/length(row1_f_half))*50; 

dat_100 = transpose(dat_100);
row1_100Hz = (dat_100(1,:));
N_1 = length(row1_100Hz);
fft1_100Hz = abs(fft(row1_100Hz,N_1));
row1_100_f = tsmovavg(fft1_100Hz, 's', 100);
row1_100_f = circshift(row1_100_f, [0, -50]);
N100 = floor(length(row1_100_f)/2);
row1_100_f_half = row1_100_f(1:N100);
range1_100 = ((1:length(row1_100_f_half))/length(row1_100_f_half))*50; 

figure(2);
plot(range, row1_f_half, '-r', range1_100, row1_100_f_half,'-b');