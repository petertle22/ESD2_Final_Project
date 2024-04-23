import numpy as np

def getCoefficientOfRestitution(positionArray, timeArray):
    timeOfImpact, idx, N = -1, 0, len(positionArray) # findBounceT()
    lowestHeight, lowestHeightTime, lowestHeightIdx = float("inf"), -1

    while idx < N:
        if lowestHeight > 0 and positionArray[idx] < lowestHeight and timeArray[idx] < timeOfImpact:
            lowestHeight, lowestHeightTime, lowestHeightIdx = positionArray[idx], timeArray[idx], idx
        idx += 1

    idx, risingHeight, risingTime = 0, -1
    while idx < N:
        if timeOfImpact < timeArray[idx] and positionArray[idx] > lowestHeight:
            risingHeight, risingTime = positionArray[idx], timeArray[idx]
            break
    
    numerator = risingHeight / (risingTime - timeOfImpact)
    denominator = lowestHeight / (timeOfImpact - lowestHeightTime)
    return abs(numerator / denominator)
    