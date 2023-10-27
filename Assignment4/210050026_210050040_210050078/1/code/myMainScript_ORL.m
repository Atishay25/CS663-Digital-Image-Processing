% myMainScript for ORL dataset tasks
% This code does all the 3 tasks related to ORL dataset -
% 1. The first section trains the data and plots
%    the recognition rates vs k for test images.
%    Note that you have comment/uncomment the desired lines
%    for changing the implementation from 'eigs/eig' to 'svd'
%    function. Read the comments for which lines to be commented
% 2. The second section shows the reconstruction of a face from ORL
% 3. The third section shows the top 25 eigenfaces

tic;
clear; clc;

X_train = [];        % training images data (first 6 images of first 32 people)
X_test = [];         % testing images data (last 4 images of first 32 people)
y_train = [];        % identity/label of people's faces in train data
y_test = [];         % identity/label of people's faces in test data

k = [1, 2, 3, 5, 10, 15, 20, 30, 50, 75, 100, 150, 170];    

% reading the data
% we are assuming that ORL directory is in the same directory as this code
for i = 1:32
    d = dir("./ORL/s" + num2str(i) + "/*.pgm");         
    for j = 1:length(d)
        img = double(imread(d(j).folder + "/" + d(j).name))/255; 
        if j <= 6
            X_train = [X_train img(:)];
            y_train = [y_train i];
        else
            X_test = [X_test img(:)];
            y_test = [y_test i];
        end
    end
end

train_dim = size(X_train);
test_dim = size(X_test);
k_dim = size(k);

% centering the data 
X_mean = mean(X_train, 2);
X = X_train - X_mean;
test_centered = X_test - X_mean;

% USING EIGS FUNCTION
% NOTE: Comment the below 3 lines and uncomment the lines for SVD
%       to run the code using svd function of MATLAB
L = (X.')*X;
[W, ~] = eigs(L, 192);
V = X*W;

% USING SVD FUNCTION
% NOTE: Uncomment the below line to run the code using SVD function 
%[V, ~, ~] = svd(X);        % use svds

dim = size(V);
for i = 1:dim(2)        % column normalizing V
    V(:,i) = V(:,i)./norm(V(:,i));
end

% calculating recognition rates
rates = zeros(k_dim);
for i = 1:k_dim(2)
    V_k = V(:, 1:k(i));
    alpha_l = (V_k')*X;
    alpha_p = (V_k')*test_centered;
    recognized = 0;
    for p = 1:test_dim(2)
        dist = sum((alpha_l - alpha_p(:,p)).^2);
        [min_val, min_ind] = min(dist);
        if y_test(p) == y_train(min_ind)
            recognized = recognized + 1;
        end
    end
    rates(i) = recognized./test_dim(2);
end

% Plot of rates vs k, when calculated using eigs function

figure(1);
plot(k, rates, 'o-', 'MarkerSize', 5, 'MarkerFaceColor', 'b');
xlim([0, 180]);
xticks(0:20:180);
xlabel('k');
ylabel('Recognition Rate');
title('Recognition Rate vs. k (ORL, using eigs)');
grid on;
saveas(figure(1), "rates_ORL_eigs", "png");


% Plot of rates vs k, when calculated using svd function

% NOTE: Uncomment the below few lines for plotting, when used svd function
%figure(1);
%plot(k, rates, 'o-', 'MarkerSize', 5, 'MarkerFaceColor', 'b');
%xlim([0, 180]);
%xticks(0:20:180);
%xlabel('k');
%ylabel('Recognition Rate');
%title('Recognition Rate vs. k (ORL, using svd)');
%grid on;
%saveas(figure(1), "rates_ORL_svd", "png");

toc;

%%

tic;

% Reconstructing a face from ORL 

k_values = [2, 10, 20, 50, 75, 100, 125, 150, 175];
img_chosen = 84;    % We chose randomly the face number 84 from traning set
img_dim1 = 112;     % This face corresponds to ORL/s14/5.pgm
img_dim2 = 92;  
original_img = X_train(:,img_chosen);
original_img = reshape(original_img, img_dim1, img_dim2);

figure(2);
imshow(original_img);
title("Original Image (ORL/s14/5.pgm)")
saveas(figure(2), "original_image_ORL", "png");

figure(3);
for i = 1:length(k_values)
    k_val = k_values(i);
    alpha_p_k = (V(:, 1:k_val)') * X(:,img_chosen);
    reconstructed_image = X_mean + V(:, 1:k_val) * alpha_p_k;
    reconstructed_image = reshape(reconstructed_image, img_dim1, img_dim2); 
    subplot(3, 3, i); 
    imshow(reconstructed_image);
    title(['k = ', num2str(k_val)], FontSize=8);
end
saveas(figure(3), "image_reconstructed_ORL", "png");
toc;

%%

% This part plots the top 25 Eigenfaces
tic;
num_eigenfaces_to_plot = 25;
figure(4);
for i = 1:num_eigenfaces_to_plot
    eigenface = V(:,i);
    eigenface = reshape(eigenface, img_dim1, img_dim2);
    subplot(5, 5, i); 
    imshow(eigenface, []); 
    %title(num2str(i), FontSize=4);
end
saveas(figure(4), "top_25_eigenfaces_ORL", "png");
toc;
