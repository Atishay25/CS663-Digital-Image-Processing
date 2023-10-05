%% MyMainScript

%% FOR RUNNING THE CODE AGAIN (WITH SIGMA = 10), 
%% CHANGE THE VALUE OF VARIABLE sd AS REQUIRED ON LINE NUMBER 19

%% Code runs with sigma for Gaussian Noise stored in variable 'sd' 
%% I have set sd = 5, you can change it to 10 
%% if you want to run for sigma = 10, on line 19

tic;
clear; clc;

barbara = double(imread('./barbara256.png'));      % reading image barbara256
kodak = double(imread('./kodak24.png'));           % reading image kodak24

figure(1); imshow(barbara/255); title('Original Barbara256');           % Original Images
figure(2); imshow(kodak/255); title('Original Kodak24');                

sd = 5;       % Sigma for running code, set it as 5 or 10

barbara_n = barbara + sd * randn(size(barbara));          % Noisy Image with Gaussian Noise
kodak_n = kodak + sd * randn(size(kodak));                

figure(3); imshow(barbara_n/255); title("Noisy Barbara256 with \sigma = " + num2str(sd));
figure(4); imshow(kodak_n/255); title("Noisy Kodak24 with \sigma = " + num2str(sd));

sig_s = [2;0.1;3];          % List of \sigma_s and \sigma_r for bilateral filter
sig_r = [2;0.1;15];

for i = 1:3
    filtered_barbara = myMeanShiftFilter(barbara_n, sig_r(i), sig_s(i));
    filtered_kodak = myMeanShiftFilter(kodak_n, sig_r(i), sig_s(i));
    hold on;
    figure(2*i+3); imshow(filtered_barbara/255);
    title("Filtered Barbara256 with \sigma = " + num2str(sd) + ", \sigma_r = " + num2str(sig_r(i)) + ", \sigma_s = " + num2str(sig_s(i)));
    saveas(gcf, "barbara_filtered_" + num2str(sig_s(i)) + "_" + num2str(sig_r(i)) + "_" + num2str(sd)+ ".png");
    hold off;
    figure(2*i+4); imshow(filtered_kodak/255);
    hold on;
    title("Filtered Kodak24 with \sigma = " + num2str(sd) + ", \sigma_r = " + num2str(sig_r(i)) + ", \sigma_s = " + num2str(sig_s(i)));
    saveas(gcf, "kodak_filtered_" + num2str(sig_s(i)) + "_" + num2str(sig_r(i)) + "_" + num2str(sd)+ ".png");
    hold off;
end
toc;

function mean_shift_filtered = myMeanShiftFilter(img, sigma_r, sigma_s)
    dim = size(img);                            % dimension of image
    mean_shift_filtered = zeros(dim);           % Output image
    w = ceil(3*sigma_s)+1;                      % window size
    epsilon = 0.01;                             % epsilon of Gradient Accent
    for i = 1:dim(1)
        for j = 1:dim(2)
            v = [i j img(i,j)];         % feature vector
            while true
                imin = max(i-w,1);      % adjusting window size
                imax = min(i+w,dim(1));
                jmin = max(j-w,1);
                jmax = min(j+w,dim(2));
                I_patch = img(imin:imax,jmin:jmax);
                [Y, X] = meshgrid(jmin:jmax, imin:imax);
                G_r = exp(-(I_patch-v(3)).^2 /(2*sigma_r^2));     
                G_s = exp(-((X-v(1)).^2 + (Y-v(2)).^2)/(2*sigma_s^2));
                G = G_s.*G_r;
                deno = sum(G,'all');
                prev_v = v;
                v = [sum(G.*X,'all')/deno sum(G.*Y,'all')/deno sum(G.*I_patch,'all')/deno];
                if norm(v - prev_v) < epsilon  
                    break;
                end
            end
            mean_shift_filtered(i,j) = v(3);
        end
    end
end
