# ZynqServer_3.py is a simulation of the final implementation EXCLUDING the FPGA Processing.
# 1. Open Server and await client connection and transfer protocol
# 2. Respond to transfer protocol requests
# 3. Reach determination and send STOP Command to client
# 4. Send determination to client
from numpysocket import NumpySocket
import cv2
import numpy as np
import time
import mmap
import struct
import sys, random
import ctypes
import copy

# Open Server
npSocket = NumpySocket()
npSocket.startServer(9999)
print("Server Started")

# ENTER INFINITE MAIN LOOP
while True:
    # TOP TRANSFER PROTOCOL MANAGEMENT
    cmd = npSocket.receiveCmd()  # Await Transfer Protocol cmd
    if cmd == '0': # INIT PARAMETERS
        # RESET ALL FOR NEW SHOT
        mode, matchType, shotType = 0, 0, 0  # Reset the following parameter values

        # Get init parameters
        param = npSocket.receiveCmd()
        mode = param // 100  # The three parameters are received as a single integer. Set mode, matchType, and shotType using the following encoding: param = mode * 100 + matchType * 10 + shotType
        matchType = (param // 10) % 10
        shotType = param % 10
    elif cmd == '1': # Process Shot
        t = 0  # initialize to start of shot
        frame = 0  # current frame counter
        while t < 1775:  # While more frames to process
            # 1. Send request for frame at t
            npSocket.write(t)
            
            # 2. Receive stereoImage for t
            data = npSocket.receive()
            stereoImage = np.reshape(data, (480, 752, 8))
            # Isolate the unique frames
            ballLeftGray = stereoImage[:, :, 0]
            ballLeftGray = np.ascontiguousarray(ballLeftGray, dtype=np.uint8) 
            emptyLeftGray = stereoImage[:, :, 1]
            emptyLeftGray = np.ascontiguousarray(emptyLeftGray, dtype=np.uint8) 
            ballRightGray = stereoImage[:, :, 4]
            ballRightGray = np.ascontiguousarray(ballRightGray, dtype=np.uint8)
            emptyRightGray = stereoImage[:, :, 5]
            emptyRightGray = np.ascontiguousarray(emptyRightGray, dtype=np.uint8)
            
            # Start Processing timer
            start_time = time.time()  # start a timer from 0 to track processing time
            
            # 3. Pass through to FPGA
            FPGA_ENABLE = False
            if FPGA_ENABLE: 
                pass  # NO IMPLEMENTATION YET
            else:
                processedLeft = cv2.threshold(cv2.absdiff(ballLeftGray, emptyLeftGray), 25, 255, cv2.THRESH_BINARY)[1]  # Background subtraction and binarization for left image
                processedRight = cv2.threshold(cv2.absdiff(ballRightGray, emptyRightGray), 25, 255, cv2.THRESH_BINARY)[1]  # Background subtraction and binarization for right image
            
            # 4. Receive processedImage from FPGA
            if FPGA_ENABLE: 
                pass  # NO IMPLEMENTATION YET
                
            # 5. Centroid Detection
            # Initialize coordinates array if not already done
            if 'coordinates' not in locals():
                coordinates = []

            # Define a function to calculate the centroid of binarized images
            def find_centroid(binary_image):
                contours, _ = cv2.findContours(binary_image, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
                if contours:
                    # Assume the largest contour is the ball
                    largest_contour = max(contours, key=cv2.contourArea)
                    M = cv2.moments(largest_contour)
                    if M["m00"] != 0:
                        cx = int(M["m10"] / M["m00"])
                        cy = int(M["m01"] / M["m00"])
                    else:
                        cx, cy = -1, -1  # Centroid not found
                    return cx, cy
                else:
                    return -1, -1  # No contours found

            # Calculate centroids for left and right images
            xLeft, yLeft = find_centroid(processedLeft)
            xRight, yRight = find_centroid(processedRight)

            # Store centroid coordinates with current time 't' in the coordinates array
            coordinates.append((xLeft, yLeft, xRight, yRight, t))
            
            # 6. Stereo Calculate X,Y,Z at t
            # IMPLEMENT: TBD
            
            # 7. Update t
            end_time = time.time()
            t = int((end_time - start_time) * 1000)  # Convert processing time to ms
            
            frame += 1  # Increment frame counter

        # Calculate Result
        # IMPLEMENT: TBD
        
        # Send Stop Command
        npSocket.send(-1)  # Stop Command: Tell Client to stop sending frames and instead request the result back
    elif cmd == '2': # Send Results
        if mode == 1:  # Coeff Mode
            pass  # IMPLEMENT: TBD
        elif mode == 2:  # Shot Mode
            pass  # IMPLEMENT: TBD
        else:  # DEBUGGING MODE
            npSocket.send(mode)
            npSocket.send(len(coordinates))  # Send length of the array of coordinates
            for coord in coordinates:
                npSocket.send(coord)  # Send all xLeft, xRight, and t values for each index in coordinates array
    else:
        print("Exit Command. Close Server")
        npSocket.close()  # Close Server
        break  # Break out of the loop for any other value
