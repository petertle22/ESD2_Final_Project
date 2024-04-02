%VARIABLES%
%Mode
% mode 
% ShotNum
% ShotType
% MatchType
% t = 0;
actaul= 1.5;

%Test Images
emptyLeftImage=imread("testImages/LeftEmptyCourt.jpg");
emptyRightImage=imread("testImages/rightEmptyCourt.jpg");
leftTestImage1=imread("testImages/leftImage1.jpg");
leftTestImage2=imread("testImages/leftImage2.jpg");
leftTestImage3=imread("testImages/leftImage3.jpg");
leftTestImage4=imread("testImages/leftImage4.jpg");
leftTestImage5=imread("testImages/leftImage5.jpg");
rightTestImage1=imread("testImages/rightImage1.jpg");
rightTestImage2=imread("testImages/rightImage2.jpg");
rightTestImage3=imread("testImages/rightImage3.jpg");
rightTestImage4=imread("testImages/rightImage4.jpg");
rightTestImage5=imread("testImages/rightImage5.jpg");

%camera settings
b = 100;                 % baseline [mm]
f = 2.56;                  % focal length [mm]
ps = .006;              % pixel size [mm]
xNumPix = 752;          % total number of pixels in x direction of the sensor [px]
cxLeft = xNumPix/2;     % left camera x center [px]
cxRight = xNumPix/2;    % right camera x center [px]


% %Get Frame n from UNITY%
% ballXYZ_t = getShotn(t);
% [leftImage, rightImage] = getImages(CamPosition, ballXYZ_t);
leftImage=[leftTestImage1,leftTestImage2,leftTestImage3,leftTestImage4,leftTestImage5];
rightImage=[rightTestImage1,rightTestImage2,rightTestImage3,rightTestImage4,rightTestImage5];
%Empty frame load and proccessed 
%load [emptyLeft, emptyRight] %Binarized, sobel filtered
for i= 1:length(rightImage) 
    
emptyLeftGray = rgb2gray(emptyLeftImage);
imshow(emptyLeftGray);

emptyRightGray = rgb2gray(emptyRightImage);
imshow(emptyRightGray);

%FPGA Image Processing
if(i==1)
rightGray = rgb2gray(rightTestImage1);
imshow(rightGray);

leftGray = rgb2gray(leftTestImage1);
imshow(leftGray);

elseif(i==2)
rightGray = rgb2gray(rightTestImage2);
imshow(rightGray);

leftGray = rgb2gray(leftTestImage2);
imshow(leftGray);
 

elseif(i==3)
rightGray = rgb2gray(rightTestImage3);
imshow(rightGray);

leftGray = rgb2gray(leftTestImage3);
imshow(leftGray);

elseif(i==4)
rightGray = rgb2gray(rightTestImage4);
imshow(rightGray);

leftGray = rgb2gray(leftTestImage4);
imshow(leftGray);
 
elseif(i==5)
rightGray = rgb2gray(rightTestImage5);
imshow(rightGray);

leftGray = rgb2gray(leftTestImage5);
imshow(leftGray);

 end
processedLeft = emptyLeftGray - leftGray;
processedRight = emptyRightGray - rightGray;

imshow(processedLeft);
imshow(processedRight);

leftBinarize=imbinarize(processedLeft);
imshow(leftBinarize);
rightBinarize=imbinarize(processedRight);
imshow(rightBinarize);
%Centroid detection algorithm
xLeft=zeros(1,length(rightImage));
xRight=zeros(1,length(rightImage));
xLeft(i) = sphereCenterX(leftBinarize);
xRight(i) = sphereCenterX(rightBinarize);

%Convert to depth
d = (abs((xLeft-cxLeft)-(xRight-cxRight))*ps);  % disparity [mm]•
Z = (b * f)./d;                                  % depth [mm]
Z= Z/1000;                                     %depth [m]
disp(['The depth is ' num2str(Z) ' [m]'])
end

scatter(d,Z)
title("Disparity vs Depth")
xlabel("Disparity [pixels]")
ylabel("Depth [m]")

%Graph accuracy of calculated depth vs actual
figure;
scatter(Z, actual, 'filled');
hold on;

plot([z actaul],'k--');
xlabel('Depth');
ylabel('Real Depth');
title('Depth vs. Real Depth');

axis equal;
grid on;