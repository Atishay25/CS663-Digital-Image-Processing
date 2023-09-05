function bilateral_filter = mybilateralfilter(img, sigma_r, sigma_s)
    dim = size(img);                            % dimension of image
    bilateral_filter = zeros(dim);  
    w = ceil(3*sigma_s);                        % window size
    [X, Y] = meshgrid(-w:w, -w:w);
    G_s = exp(-(X.^2+Y.^2)/(2*sigma_s^2));      % spatial filter
    for i = 1:dim(1)
        for j = 1:dim(2)
            imin = max(i-w,1);          % adjusting window size
            imax = min(i+w,dim(1));
            jmin = max(j-w,1);
            jmax = min(j+w,dim(2));
            I = img(imin:imax,jmin:jmax);
            G_r = exp(-(I-img(i,j)).^2/(2*sigma_r^2));      % range filter
            G_s_patch = G_s((imin:imax)-i+w+1,(jmin:jmax)-j+w+1);
            bilateral_filter(i,j) = sum(G_s_patch.*G_r.*I,'all')/sum(G_s_patch.*G_r,'all');
        end
    end
end

