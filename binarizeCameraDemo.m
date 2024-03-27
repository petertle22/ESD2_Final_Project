figure
firstFrame = imread("testImages/leftImage1.jpg");
%imshow(firstFrame)

figure
secondFrame = imread("testImages/leftImage2.jpg");
imshow(secondFrame)


diff = secondFrame - firstFrame;
%imshow(diff)

grayDiff = rgb2gray(diff);
%imshow(grayDiff)

thresholdValue = 10;
binaryDiff = imbinarize(grayDiff, thresholdValue/255);

figure
imshow(binaryDiff)