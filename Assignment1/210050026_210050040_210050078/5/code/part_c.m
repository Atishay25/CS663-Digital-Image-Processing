im1 = imread("../images/goi1.jpg");
im2 = imread("../images/goi2.jpg");

im1 = double(im1);
im2 = double(im2);

x1 = zeros(1,12);
y1 = zeros(1,12);
x2 = zeros(1,12);
y2 = zeros(1,12);

num = 12;
pts1 = ones(3, num);
pts2 = ones(3, num);

for i=1:num
    figure(1);
    imshow(im1/255);
    % [x1(i), y1(i)] = ginput(1);
    [pts1(1,i), pts1(2,i)] = ginput(1);
    figure(2);
    imshow(im2/255);
    % [x2(i), y2(i)] = ginput(1);
    [pts2(1,i), pts2(2,i)] = ginput(1);
end

% tform = fitgeotform2d([transpose(x1), transpose(y1)], [transpose(x2), transpose(y2)], 'affine');
% tform = p1 * psuedo_inverse(p2))
% tform_matrix = tform.T;
inv_pts1 = pinv(pts1);
tform = pts2 * inv_pts1;

im1_transformed = Image_wrap(im1, tform, size(im2));

% output_filename = 'images/part_c.jpg';  % Change the filename and extension as needed
% imwrite(im1_transformed, output_filename);

figure;
imshow((im1_transformed / 255));
title('Image 1 Transformed');




function transformed_Image = Image_wrap(Image1, tform, required_Size)
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