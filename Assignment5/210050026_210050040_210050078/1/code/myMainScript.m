% myMainScript
% It displays the noisy version of both images 
% and then the denoised image whichever is uncommented

clear; clc;
tic;

barbara = double(imread("./barbara256.png"));
stream = double(imread("./stream.png"));

stream = stream(1:256,1:256);       % tasking top 256x256 of stream image

sigma = 20;             % adding gaussian noise
barbara1 = barbara + randn(size(barbara))*sigma;
stream1 = stream + randn(size(stream))*sigma;

figure(1);
imshow(barbara1/255);
title("Noisy Barbara")
%saveas(figure(1), "barbara_noisy", "png");

figure(2);
imshow(stream1/255);
title("Noisy Stream");
%saveas(figure(2), "stream_noisy", "png");


% COMMENT/UNCOMMENT BELOW LINES TO CHOOSE THE IMAGE
% FOR WHICH DENOISING IS TO BE DONE
im_original = barbara;      % im_original = original image
im1 = barbara1;             % im1 = noisy image
%im_original = stream;
%im1 = stream1;

% COMMENT/UNCOMMENT BELOW LINES TO CHOOSE WHICH
% DENOISING TECHNIQUE TO USE
im2 = myPCADenoising1(im1, sigma);      % im2 = denoised image
%im2 = myPCADenoising2(im1, sigma);
%im2 = mybilateralfilter(im1,15,3);

% Calculating RMSE value
rmse = norm(im2-im_original)/norm(im_original);
fprintf("RMSE: %f\n", rmse);
    
% displaying the denoised image
figure(3);
imshow(im2/255);
title("Denoised Image");
%saveas(figure(3), "barbara_pca_denoising1", "png");

toc;

