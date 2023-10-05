image = double(imread('barbara256.png'));
imgsize = size(image);
D_values = [40,80];

figure;
fftimage = fftshift(fft2(double(image)));
log_fftimage = log(1 + abs(fftimage));
imshow(log_fftimage, []);
title('LAF of Original Image');
% imwrite(mat2gray(log_fftimage), ['LAF_Original.jpg']);

% Using Ideal Filter
for i = 1:length(D_values)
    [X, Y] = meshgrid(1:imgsize(2), 1:imgsize(1));
    center_r = ceil(imgsize(1)/2);
    center_c = ceil(imgsize(2)/2);
    D = D_values(i);
    H_Ideal = (sqrt((X-center_r).^2 + (Y-center_c).^2) <= D);

    F_image = fftshift(fft2(image));
    F_result = F_image .* H_Ideal;
    result = (ifft2(ifftshift(F_result)));

    figure;
    imshow(abs(result), []);
    title(['Final Image using Ideal filter with D = ' num2str(D)]);
    % imwrite(mat2gray(abs(result)), ['Final_Ideal_', num2str(D), '.jpg']);


    figure;
    log_F_result = log(1 + abs(F_result));
    imshow((log_F_result), []);
    title(['LAF of final Image using Ideal filter, D = ' num2str(D)]);
    % imwrite(mat2gray(log_F_result), ['LAF_IdealImage_', num2str(D), '.jpg']);

    figure;
    log_H_Ideal = log(1 + abs(H_Ideal));
    imshow(log_H_Ideal, []);
    title(['LAF of Ideal Filter, D = ' num2str(D)]);
    % imwrite(mat2gray(log_H_Ideal), ['LAF_IdealFilter_', num2str(D), '.jpg']);
end


% Using Gaussian filter
sigma_values = [40, 80];

pad_x = ceil(imgsize(1)/2);
pad_y = ceil(imgsize(2)/2);
image = padarray(image, [pad_x pad_y], 0, 'both');
F_image = fftshift(fft2(image));
for i = 1:length(sigma_values)
    [X, Y] = meshgrid(1:imgsize(2), 1:imgsize(1));
    D = D_values(i);
    H_gauss = fspecial('gaussian', size(image), sigma_values(i));

    [size_x, size_y] = size(image);
    F_result = F_image .* H_gauss;
    result = ifft2(ifftshift(F_result));

    result_unpad = result(1+pad_x:size_x-pad_x,  1+pad_y:size_y-pad_y);
    figure;
    imshow(abs(result_unpad), []);
    title(['Final Image using Gaussian filter with σ = ' num2str(D)]);
    % imwrite(mat2gray(abs(result_unpad)), ['Final_Gaussian_', num2str(D), '.jpg']);

    unpad_F_result = F_result(1+pad_x:size_x-pad_x,  1+pad_y:size_y-pad_y);
    log_unpad_F_result = log(1 + abs(unpad_F_result));
    figure;
    imshow(log_unpad_F_result, []);
    title(['LAF of final Image using Gausian filter, σ = ' num2str(D)]);
    % imwrite(mat2gray(log_unpad_F_result), ['LAF_GaussianImage_', num2str(D), '.jpg']);

    unpad_H = H_gauss(1+pad_x:size_x-pad_x,  1+pad_y:size_y-pad_y);
    log_unpad_H = log(1 + abs(unpad_H));
    figure;
    imshow(log_unpad_H, []);
    title(['LAF of Gaussian Filter, σ = ' num2str(D)]);
    % imwrite(mat2gray(log_unpad_H), ['LAF_GaussianFilter_', num2str(D), '.jpg']);
end
