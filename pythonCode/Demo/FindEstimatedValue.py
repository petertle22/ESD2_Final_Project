import cv2
import numpy as np

def findEstimatedValue(positionArray, tUsedArray, estimatedTimeBallHitsGround, order = 1):
    coefficients = np.polyfit(tUsedArray, positionArray, order)
    return np.polyval(coefficients, estimatedTimeBallHitsGround)


pos =  [0, -2.083, 0   , 2]
time = [-2,-1.167,-0.33, 0]
print(findEstimatedValue(pos, time, 2.5, 2))