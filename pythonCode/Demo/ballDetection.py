import cv2
import numpy as np
import matplotlib as plt

def process_images(ballLeftGray, emptyLeftGray, ballRightGray, emptyRightGray):
    """
    Receives four distinct grayscale images and returns the background subtracted/binarized product of the two pairs

    Parameters
    ----------
        ballLeftGray : Grayscale image of the left view with the ball present.
        emptyLeftGray : Grayscale background image of the left view without the ball.
        ballRightGray : Grayscale image of the right view with the ball present.
        emptyRightGray : Grayscale background image of the right view without the ball.


    Returns
    -------
         tuple: A tuple containing two numpy arrays:
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
    _, processedLeft = cv2.threshold(diffLeft, 10, 255, cv2.THRESH_BINARY)
    _, processedRight = cv2.threshold(diffRight, 10, 255, cv2.THRESH_BINARY)

    # Convert images to uint8 if necessary
    processedLeft = np.uint8(processedLeft)
    processedRight = np.uint8(processedRight)

    return processedLeft, processedRight

def find_centroid(binary_image):
    """
    Receives a processed binary image of a presumable black image with a white ball 
    somewhere in the frame. Returns the x,y pixel coordinates of the centroid.

    Parameters
    ----------
        binary_image : The image to find the centroid within


    Returns
    -------
        tuple: A tuple containing three values:
            - ballFound : boolean for if a centroid was detected
            - cx : x-coordinate of centroid pixel.
            - cy : y-coordinate of centroid pixel.

    """
    ballFound = True
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
    Given x,y centroid pixel coordinates from a stereo camera, return the Z,Y,Z position in 3D space of the centroid

    Parameters
    ----------
        xLeft : The x-coordinate of the centroid from the left camera perspective
        yLeft : The y-coordinate of the centroid from the left camera perspective
        xRight : The x-coordinate of the centroid from the right camera perspective
        yRight : The y-coordinate of the centroid from the right camera perspective


    Returns
    -------
        tuple: A tuple containing three values:
            - X : ball's X position [m] in 3D Space
            - Y : ball's Y position [m] in 3D Space
            - Z : ball's Z position [m] in 3D Space

    """
    # CONSTANTS
    CAM_B = 100.0 # baseline [mm]
    CAM_F = 2.56 # focal length [mm]
    CAM_PS = 0.006 # pixel size [mm]
    CAM_XNUMPIX = 752.0 # total number of pixels in x direction of the sensor [px]
    CAM_CXLEFT = CAM_XNUMPIX / 2 # left camera x center [px]
    CAM_CXRIGHT = CAM_XNUMPIX / 2 # right camera x center [px]
    CAM_YNUMPIX = 480
    CAM_CYLEFT = CAM_YNUMPIX / 2
    CAM_CYRIGHT = CAM_YNUMPIX / 2
    CAM_HEIGHT = 9000.0 # camera height [mm]

    # Calculate Z
    disparity = (abs((xLeft - CAM_CXLEFT) - (xRight - CAM_CXRIGHT)) * CAM_PS) # disparity [mm]
    depth = (CAM_B * CAM_F) / disparity # depth [mm]

    X = depth * (xLeft - CAM_CXLEFT) * CAM_PS / CAM_F + CAM_B / 2
    Y = depth * (yLeft - CAM_CYLEFT) * CAM_PS / CAM_F
    Z = CAM_HEIGHT - depth # Centroid's height off of the ground [mm]

    # Convert to Meters
    X = -(X / 1000)
    Y = -(Y / 1000)
    Z = Z / 1000

    return X, Y, Z

def filterStereoXYZ(ballPositionXYZ_RAW):
    """
    Filter the ball position data based on Z coordinate constraints.
    Removes any columns from the array where Z < 0 or Z > 9.

    Parameters
    ----------
    ballPositionXYZ_RAW : np.ndarray
        A 2D NumPy array where each column represents a frame and rows represent X, Y, Z, T values respectively.

    Returns
    -------
    np.ndarray
        A filtered 2D NumPy array containing only the columns where the Z value is between 0 and 9 inclusive.
    """
    # Create a list to hold columns that pass the filter
    valid_columns = []

    # Iterate over each column (frame) in the array
    for i in range(ballPositionXYZ_RAW.shape[1]):
        if (0 <= ballPositionXYZ_RAW[2, i]) and (ballPositionXYZ_RAW[2, i] <= 8):
            valid_columns.append(ballPositionXYZ_RAW[:, i])

    # Convert the list of arrays back into a 2D NumPy array
    if valid_columns:
        ballPositionXYZ = np.column_stack(valid_columns)
    else:
        # If no valid columns, return an empty array with the same number of rows and zero columns
        ballPositionXYZ = np.empty((ballPositionXYZ_RAW.shape[0], 0))

    return ballPositionXYZ
    
def findBounceT(ballPositionXYZ):
    """
    Given

    Parameters
    ----------
        

    Returns
    -------
         

    """
    calculatedDepths = ballPositionXYZ[2, :]
    t = ballPositionXYZ[3, :]

    index = 0
    for depth in calculatedDepths:
        if depth <= 0.2:
            # Cut both arrays at this index (including this index)
            calculatedDepths = calculatedDepths[:index + 1]
            t = t[:index + 1]
        index += 1

    # Step 1: Fit a polynomial to the data
    # We choose a polynomial of degree 2 (quadratic) which generally suits the parabolic motion of a bounce.
    # We might need to adjust the degree based on the specific characteristics of the data.
    coefficients = np.polyfit(t, calculatedDepths, 2)

    # Step 2: Create a polynomial from the coefficients
    p = np.poly1d(coefficients)

    # Step 3: Find the roots of the polynomial where the depth will be zero
    roots = p.roots

    # Step 4: Filter roots to find the correct one that comes after the initial depth
    valid_roots = [root for root in roots if root.imag == 0 and root.real >= min(t)]

    # Step 5: Choose the smallest valid root that occurs after the start
    if valid_roots:
        return min(valid_roots).real
    else:
        return None

def findEstimatedValue(positionArray, tUsedArray, estimatedTimeBallHitsGround, order = 1):
    """
    Using a polyfit, this function estimates the X,Y, or Z value at a certain time value given an array 
    of known positions at each frame

    Parameters
    ----------
        positionArray : An array of X,Y, or Z values at a given frame
        tUsedArray : An array of corresponding time values used at each frame
        estimatedTimeBallHitsGround : A time value that the X,Y, or Z position will be stimated at
        order : The order of the polyfit function found (1 by default)


    Returns
    -------
         np value : The estimated X, Y, or Z coordinate at the given t

    """
    coefficients = np.polyfit(tUsedArray, positionArray, order)

    return np.polyval(coefficients, estimatedTimeBallHitsGround)
