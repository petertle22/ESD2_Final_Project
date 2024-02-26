figure
firstFrame = imread("left1_3.jpg");
imshow(firstFrame)

figure
secondFrame = imread("left2_3.jpg");
imshow(secondFrame)


figure
diff = secondFrame - firstFrame;
imshow(diff)

grayDiff = rgb2gray(diff);

thresholdValue = 10;
binaryDiff = imbinarize(grayDiff, thresholdValue/255);

figure
imshow(binaryDiff)