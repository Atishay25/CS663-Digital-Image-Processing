close all
clear

% Define the size of the image
N = 201;

% Create an empty black image
image = zeros(N, N);

% Set the central row to white (255)
image(101, :) = 255;

% Take the 2D Fourier transform of the image
image_fft = fft2(image);

% Shift the zero frequency components to the center
image_fft_shifted = fftshift(image_fft);

% Calculate the logarithm of the Fourier magnitude
image_log_magnitude = log(abs(image_fft_shifted)+ 1e-6);

% Create a figure and plot the result
figure;
imagesc(image_log_magnitude);
colormap('jet'); % You can change the colormap as needed
colorbar;

% Label the axes
xlabel('u');
ylabel('v');
title('Logarithm of Fourier Magnitude of the Image');
