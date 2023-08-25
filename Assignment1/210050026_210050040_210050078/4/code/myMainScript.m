%% MyMainScript

tic;
%% Your code here
clear; clc;

J1 = imread('T1.jpg');      % reading image J1
J1 = double(J1);
J2 = imread('T2.jpg');      % reading image J2
J2 = double(J2);
J3 = imrotate(J2,28.5,'bilinear','crop');       % Rotate J2 to form J3

thetas = [-45:1:45];                % Array of thetas
thetas = transpose(thetas);
bin_width = 10;                     % Bin width of 10 for histograms
ncc = zeros(length(thetas),1);      % NCC
je = zeros(length(thetas),1);       % Joint Entropy
qmi = zeros(length(thetas),1);      % QMI

for i = 1:length(thetas)
    J4 = imrotate(J3+1, thetas(i),'bilinear','crop');       % To avoid unoccupied pixels, adding 1
    J4 = J4-1;                  % All valid pixels must be having > 0 values
    check = J4~=-1;             % Selecting those valid pixels for further calculations
    J1_valid = J1(check);       
    J4_valid = J4(check);

    mean_J1 = mean(J1_valid,'all');     % NCC Calculation
    mean_J4 = mean(J4_valid,'all');
    num_ncc = sum((J1_valid - mean_J1).*(J4_valid - mean_J4),'all');
    deno_ncc = sqrt(sum((J1_valid - mean_J1).^2,'all')*sum((J4_valid - mean_J4).^2,'all'));
    ncc(i) = abs(num_ncc/deno_ncc);

    n_bins = floor(255/bin_width) + 1;  % Joint Histogram Calculation for JE
    joint_histogram = zeros(n_bins);
    J1_scaled = floor(J1_valid./(bin_width)) + 1;
    J4_scaled = floor(J4_valid./(bin_width)) + 1;
    for j1 = 1:n_bins
        for j2 = 1:n_bins
            n_pixels = and((J1_scaled == j1),(J4_scaled == j2));
            joint_histogram(j1,j2) = sum(n_pixels,'all');
        end
    end
    dim = size(J1_valid);
    hw = dim(1) * dim(2);
    joint_histogram = joint_histogram./(hw);
    b = joint_histogram ~= 0;
    je(i) = -1 * sum(joint_histogram(b).*log2(joint_histogram(b)), 'all');      % Joint Entropy 
    p1 = sum(joint_histogram);                                   % Calculating Marginals from Joint Histogram
    p2 = sum(joint_histogram,2);
    qmi(i) = sum((joint_histogram - (p1 .* p2)).^2,'all');       % QMI calculation
end

[min_je, idx_je] = min(je);
[max_qmi, idx_qmi] = max(qmi);

% PLOTS OF NCC, Joint Entropy AND QMI %
figure(1);
plot(thetas, ncc); xticks(-45:10:45); title('Normalized Cross-Correlation'); xlabel('theta'); ylabel('NCC'); grid on;
figure(2);
hold on;
plot(thetas, je); xticks(-45:10:45); title('Joint Entropy'); xlabel('theta'); ylabel('Joint Entropy'); grid on;
text(thetas(idx_je)+3,min_je,['JE_{min} at theta = ' num2str(thetas(idx_je))], 'Color', 'blue');
hold off;
figure(3); 
hold on;
plot(thetas, qmi); xticks(-45:10:45); title('Quadratic Mutual Information'); xlabel('theta'); ylabel('QMI'); grid on;
text(thetas(idx_qmi)+3,max_qmi,['QMI_{max} at theta = ' num2str(thetas(idx_qmi))], 'Color', 'red');
hold off;

% Joint Histogram for optimal rotation using Joint Entropy %
J4 = imrotate(J3+1, thetas(idx_je), 'bilinear','crop');
J4 = J4-1; 
check = J4~=-1; 
J1_valid = J1(check); 
J4_valid = J4(check);
n_bins = floor(255/bin_width) + 1;
joint_histogram = zeros(n_bins);
J1_scaled = floor(J1_valid./(bin_width)) + 1;
J4_scaled = floor(J4_valid./(bin_width)) + 1;
for j1 = 1:n_bins
   for j2 = 1:n_bins
       n_pixels = and((J1_scaled == j1),(J4_scaled == j2));
       joint_histogram(j1,j2) = sum(n_pixels,'all');
   end
end

dim = size(J1_valid);
hw = dim(1) * dim(2);
joint_histogram = joint_histogram./(hw);

% PLOT OF Joint Histogram %
figure(4); 
imagesc([0:bin_width:255], [0:bin_width:255], joint_histogram); 
colormap('jet'); colorbar; xlabel('J4 Intensities'); ylabel('J1 Intensities');
title('Joint Histogram between J1 and J4');

% Other images of J1, J2, J3, J4 for displaying results of rotation and alignment %
figure(5); imshow(J1/255); title('Image J1');
figure(6); imshow(J2/255); title('Image J2');
figure(7); imshow(J3/255); title('Image J3 (rotated J2 by 28.5 anti-clockwise)');
figure(8); imshow(J4/255); title('Image J4 (Aligned J3 with respect to J1)');

toc;