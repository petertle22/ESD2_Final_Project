% === Initialization ===

% Load test images
emptyLeftImage = imread("testImages/LeftEmptyCourt.jpg");
emptyRightImage = imread("testImages/rightEmptyCourt.jpg");
leftTestImage1 = imread("testImages/leftImage1.jpg");
leftTestImage2 = imread("testImages/leftImage2.jpg");
leftTestImage3 = imread("testImages/leftImage3.jpg");
leftTestImage4 = imread("testImages/leftImage4.jpg");
leftTestImage5 = imread("testImages/leftImage5.jpg");
rightTestImage1 = imread("testImages/rightImage1.jpg");
rightTestImage2 = imread("testImages/rightImage2.jpg");
rightTestImage3 = imread("testImages/rightImage3.jpg");
rightTestImage4 = imread("testImages/rightImage4.jpg");
rightTestImage5 = imread("testImages/rightImage5.jpg");

% Load an answer key of correct depths
actualValues = [1.5, 2.5, 5.5, 2.5, 1.5];

% Initialize the camera intrinsics and extrinsics
b = 100;          % baseline [mm]
f = 2.56;         % focal length [mm]
ps = 0.006;       % pixel size [mm]
xNumPix = 752;    % total number of pixels in x direction of the sensor [px]
cxLeft = xNumPix / 2;  % left camera x center [px]
cxRight = xNumPix / 2; % right camera x center [px]
cameraHeight = 9; % camera height [m]

% === PreProcessing ===

% Function to preprocess images (convert to grayscale)
preprocessImage = @(img) rgb2gray(img);

% Preprocess all loaded images
emptyLeftImage = preprocessImage(emptyLeftImage);
emptyRightImage = preprocessImage(emptyRightImage);
leftImages = {leftTestImage1, leftTestImage2, leftTestImage3, leftTestImage4, leftTestImage5};
rightImages = {rightTestImage1, rightTestImage2, rightTestImage3, rightTestImage4, rightTestImage5};

% Convert all test images to grayscale
for i = 1:length(leftImages)
    leftImages{i} = preprocessImage(leftImages{i});
    rightImages{i} = preprocessImage(rightImages{i});
end

% Shift all test images to grayscale
for i = 1:length(leftImages)
    leftImages{i} = shiftImage(leftImages{i}, 0, 0);
    rightImages{i} = shiftImage(rightImages{i}, 0, 0);
end

% === Processing ===
calculatedDepths = zeros(1, 5);
differences = zeros(1, length(leftImages));

for i = 1:length(leftImages)
    % Background subtraction and binarization
    procLeftImg = imbinarize(imabsdiff(leftImages{i}, emptyLeftImage));
    procRightImg = imbinarize(imabsdiff(rightImages{i}, emptyRightImage));
    
    % Find sphere centers
    xLeft = findSphereCenter(procLeftImg);
    xRight = findSphereCenter(procRightImg);
    
    % Calculate depth
    d = abs((xLeft - cxLeft) - (xRight - cxRight)) * ps; % disparity [mm]
    Z = (b * f) / d; % depth [mm]
    Z = Z / 1000; % Convert depth to meters
    AdjustedZ = cameraHeight - Z;
    
    % Store calculated depth
    calculatedDepths(i) = AdjustedZ;
    
    % Calculate the difference between calculated and actual depths
    differences(i) = actualValues(i) - AdjustedZ;
end

% === Results Display ===

% Plot calculated depth vs actual depth
figure;
plot(1:5, actualValues, 'bo-', 1:5, calculatedDepths, 'rx-');
legend('Actual Depth', 'Calculated Depth');
xlabel('Image Set');
ylabel('Depth (m)');
title('Calculated Depth vs. Actual Depth');

% Display differences
disp('Differences between calculated and actual depths:');
disp(differences);

% Display all left background subtracted images with markers
figure;
for i = 1:length(leftImages)
    subplot(2, 3, i);
    imshow(imabsdiff(leftImages{i}, emptyLeftImage));
    hold on;
    % Assuming findSphereCenter function returns the center of the sphere
    xCenter = findSphereCenter(imbinarize(imabsdiff(leftImages{i}, emptyLeftImage)));
    plot(xCenter, size(leftImages{i}, 1) / 2, 'r+', 'MarkerSize', 10);
    title(sprintf('Image %d', i));
end
