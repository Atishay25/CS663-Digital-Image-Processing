% myPCADenoising1

function im2 = myPCADenoising1(im1, sigma)
    patch_size = 7;
    [h, w] = size(im1);
    P = im2col(im1, [patch_size, patch_size], 'sliding');      % patches (vectorized)
    N = size(P,2);
    C = P *(P');
    [V, ~] = eig(C);    % eigen-coeffs
    alpha = V' * P;
    alpha_bar = max(0, ((1/N)*sum(alpha.^2,2)) - sigma^2);
    alpha_denoised = zeros(size(alpha));        % weiner update
    for i = 1:patch_size^2
        alpha_denoised(i, :) = alpha(i, :) / (1 + sigma^2 / alpha_bar(i));
    end
    denoised_patches = V * alpha_denoised;      % denoised patches
    im2 = zeros(h,w);
    counter = zeros(h,w);
    index = 1;
    for j = 1:(w-patch_size+1)         % averaging
        for i = 1:(h-patch_size+1)
            im2(i:i+patch_size-1, j:j+patch_size-1) = im2(i:i+patch_size-1, j:j+patch_size-1) + reshape(denoised_patches(:, index), patch_size, patch_size);
            counter(i:i+patch_size-1, j:j+patch_size-1) = counter(i:i+patch_size-1, j:j+patch_size-1) + 1;
            index = index + 1;
        end
    end
    im2 = im2 ./ counter;
end