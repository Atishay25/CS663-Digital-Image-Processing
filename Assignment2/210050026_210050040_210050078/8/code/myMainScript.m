%% MyMainScript

%% FOR RUNNING THE CODE AGAIN (WITH SIGMA = 10), 
%% CHANGE THE VALUE OF variable sd AS REQUIRED ON LINE NUMBER 20

%% sd1 = 5 and sd2 = 10 on line 18 and 19
%% Code runs with sigma for Gaussian Noise stored in variable 'sd' 
%% I have set sd = sd1, you can change it to sd2 
%% if you want to run for sigma = 10 on line 20

tic;
clear; clc;

barbara = double(imread('./barbara256.png'));      % reading image barbara256
kodak = double(imread('./kodak24.png'));           % reading image kodak24

figure(1); imshow(barbara/255); title('Original Barbara256');           % Original Images
figure(2); imshow(kodak/255); title('Original Kodak24');                

sd1 = 5;        % Sigma for Gaussian Noise = 5
sd2 = 10;       % Sigma for Gaussian Noise = 10
sd = sd1;       % Sigma for running code, set it as sd1 or sd2

barbara_n1 = barbara + sd * randn(size(barbara));          % Noisy Image with Gaussian Noise
kodak_n1 = kodak + sd * randn(size(kodak));                

figure(3); imshow(barbara_n1/255); title("Noisy Barbara256 with \sigma = " + num2str(sd));
figure(4); imshow(kodak_n1/255); title("Noisy Kodak24 with \sigma = " + num2str(sd));

sig_s = [2;0.1;3];          % List of \sigma_s and \sigma_r for bilateral filter
sig_r = [2;0.1;15];

for i = 1:3
    bf_barbara = mybilateralfilter(barbara_n1, sig_r(i), sig_s(i));         % bilateral filter
    bf_kodak = mybilateralfilter(kodak_n1, sig_r(i), sig_s(i));
    hold on;
    figure(2*i+3); imshow(bf_barbara/255);
    title("Filtered Barbara256 with \sigma = " + num2str(sd) + ", \sigma_r = " + num2str(sig_r(i)) + ", \sigma_s = " + num2str(sig_s(i)));
    hold off;
    figure(2*i+4); imshow(bf_kodak/255);
    hold on;
    title("Filtered Kodak24 with \sigma = " + num2str(sd) + ", \sigma_r = " + num2str(sig_r(i)) + ", \sigma_s = " + num2str(sig_s(i)));
    hold off;
end
toc;

% JUST FOR VERIFYING RESULT USING INBUILT FUNCTION
% function bf = mybilateralfilter(img, sr, ss)
%     bf = imbilatfilt(img, sr*sr, ss);
% end

