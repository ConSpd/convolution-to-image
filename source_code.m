clear;clc;
%% Exercise 1
% Reading the image
I = imread('lena_gray_512.tif');

% Creating the gaussian kernel
k_size = 15;
if k_size <= 0 || mod(k_size,2) == 0
    EX = MException("ksize:InvalidValue","Invalid k_size Value:\nMust be odd and greater than zero");
    throw(EX);
end
k = fspecial('gaussian',[k_size,k_size],20);

% Padding the image
pad_size = [floor(k_size/2) floor(k_size/2)];
I_P = padarray(I,pad_size,0);

% Create new g matrix where the new image will be stored
g = zeros(height(I),width(I));

% Manual Convolution of the Image & Kernel
tic
for x = 1:height(g)
    for y = 1:width(g)
        sum = 0;
        for i = 1:height(k)
            for j = 1:width(k)
                sum = sum + double(I_P(x+i-1,y+j-1))*k(i,j);
            end
        end
        g(x,y) = sum;
    end
end
time_1 = toc;

% Displaying Image
subplot(2,2,1)
imshow(g,[]);
title("Manual Convolution");

% Calculating Error
err1 = immse(double(I),g);
snr1 = psnr(uint8(g),I);
fprintf("With Manual function\nMSE:  %f\nPSNR: %f\nTime: %f\n\n",err1,snr1,time_1);


%% Exercise 2
% With conv2
% Convolution between Padded Image and Kernel
% We use valid so the padding pixels won't be saved at end result
tic
C_conv2 = conv2(I_P,k,'valid');
time_2 = toc;

% Displaying Image
subplot(2,2,2);
imshow(C_conv2,[]);
title('Conv2 Function');

% Calculating Error
err2 = immse(double(I),C_conv2);
snr2 = psnr(uint8(C_conv2),I);
fprintf("With Conv2 function\nMSE:  %f\nPSNR: %f\nTime: %f\n\n",err2,snr2,time_2);


%% Exercise 3
% With imfilter we don't need zero padding
% Input array values outside the bounds of the array are assigned the value X.
% When no padding option is specified, the default is 0.
% We use 'same' keyword so the output stays at size of original image I
tic
C_imfilter = imfilter(I,k,'conv','same');
time_3 = toc;

% Displaying Image
subplot(2,2,3);
imshow(C_imfilter);
title('Imfilter Function');

% Calculating Error
err3 = immse(I,C_imfilter);
snr3 = psnr(C_imfilter,I);
fprintf("With Imfilter function\nMSE:  %f\nPSNR: %f\nTime: %f\n\n",err3,snr3,time_3);


%% Exercise 4

% Padding
N = height(I)+height(k)-1;
I_P2 = [I zeros(height(I),N-width(I)); zeros(N-height(I), N)];
k_P2 = [k zeros(height(k),N-width(k)); zeros(N-height(k), N)];

% Converting to frequency domain and Multiplying
tic
I_Freq = fft2(I_P2);
k_Freq = fft2(k_P2);
prod = I_Freq .* k_Freq;
% Converting to time domain
y_out = ifft2(prod);

% Removing top, down, left, right padding
upper_padding = ceil(height(k)/2);
left_padding = ceil(width(k)/2);
y = y_out(upper_padding:upper_padding+height(I)-1,left_padding:left_padding+width(I)-1);
time_4 = toc;

% Displaying Image
subplot(2,2,4);
imshow(y,[]);
title('Multiplication on Frequency Domain');

% Calculating Error
err4 = immse(double(I),y);
snr4 = psnr(uint8(y),I);
% disp("With frequency multiplication\nMSE:"+err4+"\nPSNR:"+snr4+"\nTime"+time_4);
fprintf("With Frequency multiplication\nMSE:  %f\nPSNR: %f\nTime: %f\n\n",err4,snr4,time_4);
