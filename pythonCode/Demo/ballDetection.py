import cv2
import numpy as np

def process_images(ballLeftGray, emptyLeftGray, ballRightGray, emptyRightGray):
    # Ensure images are of type uint8 and have dimensions 752x480
    assert ballLeftGray.dtype == np.uint8 and ballLeftGray.shape == (480, 752)
    assert emptyLeftGray.dtype == np.uint8 and emptyLeftGray.shape == (480, 752)
    assert ballRightGray.dtype == np.uint8 and ballRightGray.shape == (480, 752)
    assert emptyRightGray.dtype == np.uint8 and emptyRightGray.shape == (480, 752)

    # Background subtraction for left and right images
    diffLeft = cv2.absdiff(ballLeftGray, emptyLeftGray)
    diffRight = cv2.absdiff(ballRightGray, emptyRightGray)

    # Binarization of the subtracted images
    #_, processedLeft = cv2.threshold(diffLeft, 25, 255, cv2.THRESH_BINARY)
    #_, processedRight = cv2.threshold(diffRight, 25, 255, cv2.THRESH_BINARY)

    # Convert images to uint8 if necessary
    #processedLeft = np.uint8(processedLeft)
    #processedRight = np.uint8(processedRight)

    return diffLeft, diffRight

# Example of how to use the function:
# processedLeft, processedRight = process_images(ballLeftGray, emptyLeftGray, ballRightGray, emptyRightGray)
