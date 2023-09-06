image1 = imread('LC1.png');
image2 = imread('LC2.jpg');

windowSizes = [7, 31, 51, 71];
for i = 1:numel(windowSizes)
    windowSize = windowSizes(i);
    enhancedImage1 = histogram_equalization(image1, windowSize);
    enhancedImage2 = histogram_equalization(image2, windowSize);
    
    figure;
    subplot(1, 2, 1);
    imshow(enhancedImage1);
    title(['Local Enhanced LC1 - Window Size: ' num2str(windowSize)]);
    
    subplot(1, 2, 2);
    imshow(enhancedImage2);
    title(['Local Enhanced LC2 - Window Size: ' num2str(windowSize)]);

    % imwrite(enhancedImage1, ['LC1_Enhanced_' num2str(windowSize) '.jpg']);
    % imwrite(enhancedImage2, ['LC2_Enhanced_' num2str(windowSize) '.jpg']);
end

enhancedImage1 = histeq(image1);
enhancedImage2 = histeq(image2);

% imwrite(enhancedImage1, ['Globally Enhanced LC1.jpg']);
% imwrite(enhancedImage2, ['Globally Enhanced LC2.jpg']);

subplot(1, 2, 1);
imshow(enhancedImage1);
title('Globally Enhanced LC1');

subplot(1, 2, 2);
imshow(enhancedImage2);
title('Globally Enhanced LC2');


function enhancedImage = histogram_equalization(image, windowSize)
    [height, width] = size(image);
    k = (windowSize - 1)/2;
    padded_image = padarray(image, [k, k], 0); % The third argument (0) is the padding value
    enhancedImage = uint8(zeros(height, width));

    for y = 1:height
        for x = 1:width
            intensity = image(y,x);
            window = padded_image(y:y+windowSize-1,x:x+windowSize-1);
            histogram = imhist(window);
            cdf = cumsum(histogram) / sum(histogram);
            enhancedImage(y,x) = uint8(cdf(intensity+1)* 255) ;  % (L - 1) * cdf(intensity + 1)
        end
    end
end
