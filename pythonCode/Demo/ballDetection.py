import cv2
import numpy as np
import matplotlib as plt

def process_images(ballLeftGray, emptyLeftGray, ballRightGray, emptyRightGray):
    """
    process_images takes 2 stereo images (an image with a ball, and an image of the empty court),
    background subtracts the two stereo images and thresholds the product to produce a binarized
    stereo image of an isolate ball in the frame

    :param ballLeftGray: uint8 image of a tennis court with a ball from left camera perspective
    :param emptyLeftGray: uint8 image of empty tennis court from left camera perspective
    :param ballRightGray: uint8 image of a tennis court with a ball from right camera perspective
    :param emptyRightGray: uint8 image of empty tennis court from right camera perspective

    :return : A tuple containing two numpy arrays:
            - processedLeft : Processed binary image of the left view.
            - processedRight : Processed binary image of the right view.
    """ 
    # Ensure images are of type uint8 and have dimensions 752x480
    assert ballLeftGray.dtype == np.uint8 and ballLeftGray.shape == (480, 752)
    assert emptyLeftGray.dtype == np.uint8 and emptyLeftGray.shape == (480, 752)
    assert ballRightGray.dtype == np.uint8 and ballRightGray.shape == (480, 752)
    assert emptyRightGray.dtype == np.uint8 and emptyRightGray.shape == (480, 752)

    # Background subtraction for left and right images
    diffLeft = cv2.absdiff(ballLeftGray, emptyLeftGray)
    diffRight = cv2.absdiff(ballRightGray, emptyRightGray)

    # Binarization of the subtracted images
    _, processedLeft = cv2.threshold(diffLeft, 100, 255, cv2.THRESH_BINARY)
    _, processedRight = cv2.threshold(diffRight, 100, 255, cv2.THRESH_BINARY)

    # Convert images to uint8 if necessary
    processedLeft = np.uint8(processedLeft)
    processedRight = np.uint8(processedRight)

    return processedLeft, processedRight

def find_centroid(binary_image):
    """
    find_centroid receives a processed binary image of a presumable black image with a white ball 
    somewhere in the frame. Returns the x,y pixel coordinates of the centroid.

    :param binary_image : The image to find the centroid within

    :return : A tuple containing three values:
            - ballFound : boolean for if a centroid was detected
            - cx : x-coordinate of centroid pixel.
            - cy : y-coordinate of centroid pixel.
    """
    # BInitialize Variables
    ballFound = True # Boolean for specifying if a ball was found

    # Identfy all possible contours in image
    contours, _ = cv2.findContours(binary_image, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)[-2:]

    # Iterate through all identified contours to find best centroid
    if contours:
        largest_contour = max(contours, key=cv2.contourArea)
        M = cv2.moments(largest_contour)
        if M["m00"] != 0:
            cx = M["m10"] / M["m00"]
            cy = M["m01"] / M["m00"]
        else:
            ballFound = False
            cx, cy = 0, 0  # Centroid not found
        return ballFound, cx, cy
    else:
        return False, 0, 0  # No contours found
    
def calcStereoXYZ(xLeft, yLeft, xRight, yRight):
    """
    calcStereoXYZ receives a centroid's (x,y) coordinate from a stereo camera's left and right perspective 
    and returns the centroid's X,Y,Z position in 3D space [m] in terms of the center of the court on the ground = (0,0,0)

    :param xLeft : The x-coordinate of the centroid from the left camera perspective
    :param yLeft : The y-coordinate of the centroid from the left camera perspective
    :param xRight : The x-coordinate of the centroid from the right camera perspective
    :param yRight : The y-coordinate of the centroid from the right camera perspective

    :return : A tuple containing three values:
            - X : ball's X position [m] in 3D Space
            - Y : ball's Y position [m] in 3D Space
            - Z : ball's Z position [m] in 3D Space
    """
    # CAMERA INTRINSICS
    CAM_B = 100.0 # baseline [mm]
    CAM_F = 2.56 # focal length [mm]
    CAM_PS = 0.006 # pixel size [mm]
    CAM_XNUMPIX = 752.0 # total number of pixels in x direction of the sensor [px]
    CAM_CXLEFT = CAM_XNUMPIX / 2 # left camera x center [px]
    CAM_CXRIGHT = CAM_XNUMPIX / 2 # right camera x center [px]
    CAM_YNUMPIX = 480 # total number of pixels in y direction of the sensor [px]
    CAM_CYLEFT = CAM_YNUMPIX / 2 # left camera y center [px]

    # CAMERA EXTRINSICS
    CAM_HEIGHT = 9000.0 # camera height from ground [mm]

    # Calculate depth from camera [mm]
    disparity = (abs((xLeft - CAM_CXLEFT) - (xRight - CAM_CXRIGHT)) * CAM_PS) # disparity [mm]
    depth = (CAM_B * CAM_F) / disparity # depth [mm]

    # Calculate real-world X,Y,Z [mm]
    X = depth * (xLeft - CAM_CXLEFT) * CAM_PS / CAM_F + CAM_B / 2
    Y = depth * (yLeft - CAM_CYLEFT) * CAM_PS / CAM_F
    Z = CAM_HEIGHT - depth # Centroid's height off of the ground [mm]

    # Convert to Meters and adjust to cordinate system
    X = -(X / 1000)
    Y = -(Y / 1000)
    Z = Z / 1000

    return X, Y, Z

def filterStereoXYZ(ballPositionXYZ_RAW):
    """
    filterStereoXYZ removes invalid entries in an array of ball XYZ positions over time.
    Current implementation:
        - Remove all entries with a depth less than 0m or greater than 8m

    :param ballPositionXYZ_RAW : Array to be filtered

    :return : The filtered 2D numpy array
    """
    # Choose which filter to use
    FILTER_SELECT = 1

    # Simple filter
    valid_columns = []

    # Iterate over each column (frame) in the array
    for i in range(ballPositionXYZ_RAW.shape[1]):
        if (-1 <= ballPositionXYZ_RAW[2, i]) and (ballPositionXYZ_RAW[2, i] <= 8):
            valid_columns.append(ballPositionXYZ_RAW[:, i])

    # Convert the list of arrays back into a 2D NumPy array
    if valid_columns:
        ballPositionXYZ = np.column_stack(valid_columns)
    else:
        # If no valid columns, return an empty array with the same number of rows and zero columns
        ballPositionXYZ = np.empty((ballPositionXYZ_RAW.shape[0], 0))

    if (FILTER_SELECT == 1): #Polyfit, normalize strays to polyfit zone
        valid_columns = []
        buffer_zone = 0.5

        # Extract Z values and corresponding times
        Z = ballPositionXYZ[2, :]
        t = ballPositionXYZ[3, :]

        # Fit a second order polynomial to Z over time
        p = np.polyfit(t, Z, 2)  # Coefficients of the polynomial

        # Iterate over each column (frame) in the array
        for i in range(ballPositionXYZ.shape[1]):
            # Calculate the upper and lower bounds of the buffer zone
            Z_fit = np.polyval(p, ballPositionXYZ[3, i])  # Evaluated polynomial at current time
            upper_bound = Z_fit + buffer_zone
            lower_bound = Z_fit - buffer_zone

            REMOVE = False
            if (REMOVE):
                if (lower_bound <= ballPositionXYZ[2, i]) and (ballPositionXYZ[2, i] <= upper_bound):
                    valid_columns.append(ballPositionXYZ[:, i])
            else:
                if (lower_bound > ballPositionXYZ[2, i]):
                    ballPositionXYZ[2, i] = lower_bound
                elif (upper_bound < ballPositionXYZ[2, i]):
                    ballPositionXYZ[2, i] = upper_bound

        # Convert the list of arrays back into a 2D NumPy array
        if valid_columns:
            filteredXYZ = np.column_stack(valid_columns)
        else:
            # If no valid columns, return an empty array with the same number of rows and zero columns
            filteredXYZ = np.empty((ballPositionXYZ.shape[0], 0))

        return filteredXYZ

    return ballPositionXYZ
    
def findBounceT(ballPositionXYZ):
    """
    findBounceT uses a polyfit on an array of ball XYZ positions over time to estimate the approx. t[ms] 
    in which the ball will reach a Z = 0 (bounce depth)

    :param ballPositionXYZ : Array to estimate bounceT from

    :return : The floating point estimate of t[ms] at which Z = 0
    """
    # Extract just the Z and t values for each frame
    calculatedDepths = ballPositionXYZ[2, :]
    t = ballPositionXYZ[3, :]

    # Find cutoff point just before a bounce
    index = 0
    for depth in calculatedDepths:
        if depth <= 0.1: # Arbitrary cutoff height
            # Cut both arrays at this index (including this index)
            calculatedDepths = calculatedDepths[:index + 1]
            t = t[:index + 1]
        index += 1

    # MAV the data to smooth the curve
    window_size = 1  # Adjust this size to fit the smoothing level you need
    window = np.ones(window_size) / window_size
    calculatedDepths = np.convolve(calculatedDepths, window, 'same')

    # Fit a polynomial to the data to get its coefficients
    coefficients = np.polyfit(t, calculatedDepths, 2) # Use quadratic polyfit because of gravity affecting trajectory
    # Create a polynomial from the coefficients
    p = np.poly1d(coefficients)
    # Find the roots of the polynomial where the depth will be zero
    roots = p.roots
    # Filter roots to find the correct one that comes after the initial depth
    valid_roots = [root for root in roots if root.imag == 0 and root.real >= min(t)]

    # Choose the smallest valid root that occurs after the start
    if valid_roots:
        return min(valid_roots).real
    else:
        return None

def findEstimatedValue(positionArray, tUsedArray, estimatedTimeBallHitsGround, order = 1):
    """
    findEstimatedValue uses a polyfit of a ball's X,Y, or Z position to estimate the coordinate's value
    at a given time guess[ms]

    :param positionArray : Array of ball positions to estimate from
    :param tUsedArray : Array of corresponding times [ms] to estimate from
    :param estimatedTimeBallHitsGround : t value to evaluate function at
    :param order : order of the polyfit used (Linear polyfit by default)

    :return : The estimated X, Y, or Z coordinate at the given t
    """
    # Fit a polynomial to the data
    coefficients = np.polyfit(tUsedArray, positionArray, order)

    # Evaluate and return
    return np.polyval(coefficients, estimatedTimeBallHitsGround)

def getCoefficientOfRestitution(ballPositionXYZ):
    """
    getCoefficientOfRestitution uses a ball's X,Y,Z position over time to calculate the ball/court 
    coefficient of restitution by comparing velocity before and after a bounce

    :param ballPositionXYZ : The ball X,Y,Z,t information to calculate from

    :return : The coefficient of restitution
    """
    positionArray, timeArray = ballPositionXYZ[2, :], ballPositionXYZ[3, :]
    timeOfImpact, idx, N = findBounceT(ballPositionXYZ), 0, len(positionArray)

   # Find the index of the closest time in timeArray to the timeOfImpact
    bounceFrame = np.argmin(np.abs(timeArray - timeOfImpact))

    # Split the arrays into before and after the bounce
    positionBefore = positionArray[:bounceFrame + 1]
    positionAfter = positionArray[bounceFrame:]

    timeBefore = timeArray[:bounceFrame + 1]
    timeAfter = timeArray[bounceFrame:]

    # First order polyfit (linear regression) to get the slope before and after the bounce
    coefficientsBefore = np.polyfit(timeBefore, positionBefore, 1)
    coefficientsAfter = np.polyfit(timeAfter, positionAfter, 1)

    # Extract the slopes
    beforeV = coefficientsBefore[0]  # Slope of the line before the bounce
    afterV = coefficientsAfter[0]    # Slope of the line after the bounce

    # Calculate the ratio of the slopes
    # Ensure afterV is not zero to avoid division by zero
    if afterV == 0:
        return None

    restitutionRatio = abs(afterV / beforeV)
    return restitutionRatio

def getLineDecision(ballPositionXYZ, matchType, shotType):
    """
    getLineDecision analyzes a filtered data set of a ball's X,Y,Z,t position accross a series of frames
    to determine whether the ball bounced within boundary lines (dependent on match/shot type)

    :param ballPositionXYZ : X,Y,Z,t information of the ball
    :param matchType : integer to specify the tpe of match (singles = 1, doubles = 2)
    :param shotType : integer to specify the tpe of shot (serve = 1, volley = 2)

    :return : "In" (1) or "Out" (0)
    """
    pass

def isServeInBound(ballPositionXYZ):
    timeOfImpact = findBounceT(ballPositionXYZ)
    startingX, startingY, startingZ, _ = ballPositionXYZ[0] # Get the starting position of the serve

    bounceX, bounceY = None, None  # Get the bounce location of the serve
    for i in range(len(ballPositionXYZ)):
        thisTime = ballPositionXYZ[3, i]
        if timeOfImpact < thisTime:
            bounceX, bounceY = ballPositionXYZ[:1, i]
            break
    
    if bounceX > startingX: # The serve is going right-to-left relative to the camera
        if startingY > 0: # The serve is going top-right corner to bottom-left corner
            return bounceX <= 6.4 and -4.115 <= bounceY and bounceY <= 0 
        elif startingY < 0: # The serve is going bottom-left corner to top-right corner
            return bounceX <= 6.4 and 0 <= bounceY and bounceY <= 4.115
        else:
            return False

    else: # The serve is going left to right relative to the camera
        if startingY > 0:  # The serve is going top-left corner to bottom-right corner
            return -6.4 <= bounceX and -4.115 <= bounceY and bounceY <= 0 
        elif startingY < 0:
            return -6.4 <= bounceX and 0 <= bounceY and bounceY <= 4.115
        else:
            return False

def isVolleyInBound(ballPositionXYZ):
    timeOfImpact = findBounceT(ballPositionXYZ)
    startingX, startingY, _, _ = ballPositionXYZ[0] # Get the starting position of the serve

    bounceX, bounceY = None, None  # Get the bounce location of the serve
    for i in range(len(ballPositionXYZ)):
        thisTime = ballPositionXYZ[3, i]
        if timeOfImpact < thisTime:
            bounceX, bounceY = ballPositionXYZ[:1, i]
            break
    
    if bounceX > startingX: # The volley is going right-to-left relative to the camera
        return 0 <= bounceX and bounceX <= 11.885 and -5.485 <= bounceY and bounceY <= 5.485
    else: # The volley is going left to right relative to the camera
        return -11.885 <= bounceX and bounceX <= 0 and -5.485 <= bounceY and bounceY <= 5.485
