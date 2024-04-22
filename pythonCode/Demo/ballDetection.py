import cv2
import numpy as np

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
    #processedLeft = np.uint8(processedLeft)
    #processedRight = np.uint8(processedRight)

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
         tuple: A tuple containing two values:
            - cx : x-coordinate of centroid pixel.
            - cy : y-coordinate of centroid pixel.

    """
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
            cx, cy = 0, 0  # Centroid not found
        return cx, cy
    else:
        return 0, 0  # No contours found
