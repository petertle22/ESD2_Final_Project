import cv2 
import numpy as np 


def getBallCenterFromImage(file):
	# Read image
	img = cv2.imread(file, cv2.IMREAD_COLOR)

	# Convert to grayscale
	gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

	# Blur using a 3 x 3 kernel
	grayBlurred = cv2.blur(gray, (3, 3))

	detectedCircles = cv2.HoughCircles(grayBlurred, cv2.HOUGH_GRADIENT, 1, 20, 
									param1 = 50, param2 = 50, minRadius = 40, 
									maxRadius = 80)
	
	if detectedCircles is not None:
		detectedCircles = np.uint16(np.around(detectedCircles)) 

		for pt in detectedCircles[0, :]: 
			a, b, r = pt[0], pt[1], pt[2] 

			# Draw the circumference of the circle. 
			cv2.circle(img, (a, b), r, (0, 255, 0), 2) 
			return (a, b)


b = 60               # baseline [mm] how far eyes are away from each other
f = 6                # focal length [mm] focal length of eye
pixelSize = .006     # pixel size [mm] 
xNumPix = 752        # total number of pixels in x direction of the sensor [px]
yNumPix = 480 

cxLeft = xNumPix / 2  # left camera x center [px]
cxRight = xNumPix / 2 # right camera x center [px
cyLeft = yNumPix / 2
cyRight = yNumPix /2 

x1, y1 = getBallCenterFromImage("../ESD2_L3/left9.jpg")
x2, y2 = getBallCenterFromImage("../ESD2_L3/right9.jpg")

Z_mm = (b * f)/(abs((x1-cxLeft)-(x2-cxRight))*pixelSize)
X_mm = (Z_mm * (x1-cxLeft)*pixelSize)/f
Y_mm = (Z_mm * (y1-cyLeft)*pixelSize)/f

print("(", X_mm/1000, ",", Y_mm/1000, ",", Z_mm/1000, ")")