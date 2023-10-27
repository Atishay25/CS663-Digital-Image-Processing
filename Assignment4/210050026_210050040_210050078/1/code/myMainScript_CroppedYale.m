% myMainScript for all tasks related to Yale dataset

tic;
clear; clc;

img_dim1 = 192;
img_dim2 = 168;
X_train = [];
X_test = [];
y_train = [];
y_test = [];
k = [1, 2, 3, 5, 10, 15, 20, 30, 50, 60, 65, 75, 100, 200, 300, 500, 1000];

% we are assuming that CroppedYale directory is in the
% same directory as this file
yale = dir("./CroppedYale/");
id = 0;
for i = 3:length(yale)
    d = dir(yale(i).folder + "/" + yale(i).name + "/*.pgm");
    if i <= 15
         id = i - 2;
    else
         id = i - 1;
    end
    for j = 1:length(d)
        img = double(imread(d(j).folder + "/" + d(j).name)); 
        if j <= 40
            X_train = cat(2, X_train, img(:));
            y_train = cat(2, y_train, id);
        else
            X_test = cat(2, X_test, img(:));
            y_test = cat(2, y_test, id);
        end
    end
end

% Since reading yale was taking much time, we can save it 
% and load it for next section of training part, if needed to run again
%save("yale_data.mat");
toc;

%%

tic;
%load("yale_data.mat");

train_dim = size(X_train);
test_dim = size(X_test);
k_dim = size(k);

X_mean = mean(X_train, 2);
X = X_train - X_mean;
test_centered = X_test - X_mean;

% using eigs
L = (X.')*X;
[W, D] = eigs(L, train_dim(2));
V = X*W;

dim = size(V);
for i = 1:dim(2)
    V(:,i) = V(:,i)./norm(V(:,i));
end

% NOTE: 
% For (a) part, 
% you would have to comment line 72 and 
% uncomment & run code with the line 71

% For (b) part, 
% you would have to comment line 71 and 
% uncomment & run code with line 72
rates = zeros(k_dim);
for i = 1:k_dim(2)
    V_k = V(:, 1:k(i));      % 1:k(i) for (a) part, all eigencoeffs
    %V_k = V(:, 4:k(i));     % 4:k(i) for (b) part, except top 3
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

% NOTE: comment/uncomment the below for plotting for 
% part (a) and (b) as needed

% plotting recognition rates for (a) part (all eigencoeffs)
figure(1);
plot(k, rates, 'o-', 'MarkerSize', 5, 'MarkerFaceColor', 'b');
xlabel('k');
ylabel('Recognition Rate');
title('CroppedYale (Using All Eigen-coefficients)');
grid on;
saveas(figure(1), "rates_CroppedYale_all", "png");

% plotting recognition rates for (b) part (except top 3 eigencoeffs)
%figure(1);
%plot(k, rates, 'o-', 'MarkerSize', 5, 'MarkerFaceColor', 'b');
%xlabel('k');
%ylabel('Recognition Rate');
%title('CroppedYale (Except Top 3 Eigen-Coefficients)');
%grid on;
%saveas(figure(1), "rates_CroppedYale_except_top_3", "png");

toc;

%%

% Plotting the top 25 eigenfaces

tic;
num_eigenfaces_to_plot = 25;
figure(2);
for i = 1:num_eigenfaces_to_plot
    eigenface = V(:,i);
    eigenface = reshape(eigenface, img_dim1, img_dim2);
    subplot(5, 5, i); 
    imshow(eigenface, []); 
    %title(num2str(i), FontSize=4);
end
saveas(figure(2), "top_25_eigenfaces_CroppedYale", "png");
toc;