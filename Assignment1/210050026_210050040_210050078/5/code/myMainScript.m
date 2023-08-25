im1 = imread("../images/goi1.jpg");
im2 = imread("../images/goi2.jpg");

im1 = double(im1);
im2 = double(im2);


num = 12;
pts1 = ones(3, num);
pts2 = ones(3, num);

for i=1:num
    figure(1);
    imshow(im1/255);
    [pts1(1,i), pts1(2,i)] = ginput(1);
    figure(2);
    imshow(im2/255);
    [pts2(1,i), pts2(2,i)] = ginput(1);
end

inv_pts1 = pinv(pts1);
tform = pts2 * inv_pts1;

im1_transformed_c = Image_wrap_c(im1, tform, size(im2));


figure;
imshow(im1_transformed_c/255);
title('Image 1 Transformed using nearest neighbour interpolation ');



im1_transformed_d = Image_wrap_d(im1, tform, size(im2));

figure;
imshow((im1_transformed_d / 255));
title('Image 1 Transformed using Bilinear Interpolation');



function value = bilinearInterpolation(image, x, y)
    x_floor = floor(x);
    y_floor = floor(y);
    
    dx = x - x_floor;
    dy = y - y_floor;
    
    value = (1 - dx) * (1 - dy) * image(y_floor, x_floor) + ...
            dx * (1 - dy) * image(y_floor, x_floor + 1) + ...
            (1 - dx) * dy * image(y_floor + 1, x_floor) + ...
            dx * dy * image(y_floor + 1, x_floor + 1);
end


function transformed_Image = Image_wrap_d(Image1, tform, required_Size)
    transformed_Image = 255 * ones(required_Size, 'like', Image1);
    [rows, cols, ~] = size(transformed_Image);
    
    for r = 1:rows
        for c = 1:cols
            arr = ones(3,1);
            arr(1,1) = c;
            arr(2,1) = r;
            transformed = inv(tform) * arr;
            x = transformed(1);
            y = transformed(2);
            
            if x >= 1 && x <= size(Image1, 2) && y >= 1 && y <= size(Image1, 1)
                transformed_Image(r, c, :) = bilinearInterpolation(Image1, x, y);
            end
        end
    end
end




function transformed_Image = Image_wrap_c(Image1, tform, required_Size)
    transformed_Image = 255 * ones(required_Size, 'like', Image1);
    [rows, cols] = size(transformed_Image);
    for r = 1:rows
        for c = 1:cols
            % transformed = tform.transformPointsInverse([c, r]);
            arr = ones(3,1);
            arr(1,1) = c;
            arr(2,1) = r;
            transformed = inv(tform) * arr;
            x = round(transformed(1));
            y = round(transformed(2));
            % disp([r,c;y,x]);
            if x >= 1 && x <= size(Image1, 2) && y >= 1 && y <= size(Image1, 1)
                transformed_Image(r, c) = Image1(y, x);
            end
            
        end
    end
end
