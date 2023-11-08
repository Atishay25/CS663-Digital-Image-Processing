% myPCADenoising2

function im2 = myPCADenoising2(im1, sigma)
    patch_size = 7;
    nbh_size = 31;
    half_size_nbh = 15;
    [h, w] = size(im1);
    im2 = zeros(h,w);
    denoised_patches = [];      % to store denoised patches for each reference patch
    for j = 1:(w-patch_size+1)
        for i = 1:(h-patch_size+1)
            patch = im1(i:i+patch_size-1, j:j+patch_size-1);        % reference patch
            neighborhood = im1(max(1,i-half_size_nbh):min(h,i+half_size_nbh), max(1,j-half_size_nbh):min(w,j+half_size_nbh));
            n_patches = im2col(neighborhood, [patch_size, patch_size], 'sliding');      % neighborhood patches
            dist = sum((n_patches - patch(:)).^2);
            [~,indices] = sort(dist);       % getting K most similar patched based on mse
            K = 200;
            sz = size(dist,2);
            if sz < 200
                K = sz;
            end 
            P = n_patches(:, indices(1:K));
            N = size(P,2);
            C = P *(P');
            [V, ~] = eig(C);
            alpha = V' * P;
            alpha_ref = V' * patch(:);      % alpha of reference patch
            alpha_bar = max(0, ((1/N)*sum(alpha.^2,2)) - sigma^2);
            for q = 1:patch_size^2          % weiner update
                alpha_ref(q) = alpha_ref(q) / (1 + sigma^2 / alpha_bar(q));
            end
            curr_denoised_patch = V*alpha_ref;      % denoised reference patch
            denoised_patches = [denoised_patches, curr_denoised_patch];
        end
    end 
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