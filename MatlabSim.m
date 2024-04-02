%VARIABLES%
%Mode
% mode 
% ShotNum
% ShotType
% MatchType
% t = 0;
ZValues=zeros(1,5);
actaulValues=zeros(1,5);
actaulValues=[1.5,2.5,5.5,2.5,1.5];
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
cameraHeight = 9;


% %Get Frame n from UNITY%
% ballXYZ_t = getShotn(t);
% [leftImage, rightImage] = getImages(CamPosition, ballXYZ_t);
leftImage=[leftTestImage1,leftTestImage2,leftTestImage3,leftTestImage4,leftTestImage5];
rightImage=[rightTestImage1,rightTestImage2,rightTestImage3,rightTestImage4,rightTestImage5];
%Empty frame load and proccessed 
%load [emptyLeft, emptyRight] %Binarized, sobel filtered
emptyLeftGray = rgb2gray(emptyLeftImage);

emptyRightGray = rgb2gray(emptyRightImage);
for i = 1:5

%FPGA Image Processing
if(i==1)
rightGray = rgb2gray(rightTestImage1);

leftGray = rgb2gray(leftTestImage1);

elseif(i==2)
rightGray = rgb2gray(rightTestImage2);

leftGray = rgb2gray(leftTestImage2);
 

elseif(i==3)
rightGray = rgb2gray(rightTestImage3);

leftGray = rgb2gray(leftTestImage3);

elseif(i==4)
rightGray = rgb2gray(rightTestImage4);

leftGray = rgb2gray(leftTestImage4);
 
elseif(i==5)
rightGray = rgb2gray(rightTestImage5);

leftGray = rgb2gray(leftTestImage5);

 end
processedLeft = emptyLeftGray - leftGray;
processedRight = emptyRightGray - rightGray;
leftBinarize=imbinarize(processedLeft);
rightBinarize=imbinarize(processedRight);
%Centroid detection algorithm
xLeft = findSphereCenter(leftBinarize);
xRight = findSphereCenter(rightBinarize);

%Convert to depth
d = (abs((xLeft-cxLeft)-(xRight-cxRight))*ps);  % disparity [mm]•
Z = (b * f)/d;                                  % depth [mm]
Z= Z/1000;                                     %depth [m]
AdjustedZ = cameraHeight - Z;
ZValues(i)=AdjustedZ;
disp(['The depth is ' num2str(AdjustedZ) ' [m]'])
end

figure;
subplot(2,2,1);
imshow(rightTestImage5);
title('Image before processing');

subplot(2,2,2);
imshow(rightGray);
title('Right image Gray Scaled');

subplot(2,2,3);
imshow(processedRight);
title('Right Gray image minus empty Gray');

subplot(2,2,4);
imshow(rightBinarize);
title('Right Gray image minus empty Gray');

figure;
scatter(d,AdjustedZ)
title("Disparity vs Depth")
xlabel("Disparity [pixels]")
ylabel("Depth [m]")

%Graph accuracy of calculated depth vs actual
figure;
scatter(AdjustedZ, actaulValues, 'filled');
hold on;

plot([ZValues actaulValues],'k--');
xlabel('Depth');
ylabel('Real Depth');
title('Depth vs. Real Depth');

axis equal;
grid on;