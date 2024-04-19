# ZynqServer_3.py is a simulation of the final implementation EXCLUDING the FPGA Processing.
# 1. Open Server and await client connection and transfer protocol
# 2. Respond to transfer protocol requests
# 3. Reach determination and send STOP Command to client
# 4. Send determination to client
from numpysocket import NumpySocket
from matplotlib import pyplot as plt
import cv2
import numpy as np
import time
import mmap
import struct
import sys, random
import ctypes
import copy
import TCP_communication as tcp

# CONSTANTS
STOP_CMD = -1
#----------------------------------------------------------------------------------------------------------


# Open Server
npSocket = NumpySocket()
npSocket.startServer(9999)
print("Server Started")

# ENTER INFINITE MAIN LOOP
while True:
    # TOP TRANSFER PROTOCOL MANAGEMENT
    cmd = int(npSocket.receiveCmd())  # Await Transfer Protocol cmd
    if cmd == 0: # INIT PARAMETERS
        # Get init parameters from client
        mode, matchType, shotType = tcp.getInitParameters(npSocket)

    elif cmd == 1: # Process Shot
        # Initialize Variables
        t = 1  # initialize to start of shot
        frame = 0  # current frame counter
        coordinates = np.zeros((5, 0), dtype=int)  # Initialize a 2D array with 5 rows and dynamic columns

        # Process All Frames
        while True:  # While more frames to process
            # Send request for frame at t
            tcp.requestFrame(t, frame, npSocket)
            # Receive frame for t
            frame_data = tcp.receiveFrame(npSocket)
            # Access the individual images from frame
            ballLeftGray = frame_data['ballLeftGray']
            emptyLeftGray = frame_data['emptyLeftGray']
            ballRightGray = frame_data['ballRightGray']
            emptyRightGray = frame_data['emptyRightGray']
            # If frame is empty, stop processing
            if np.all(frame_data == 0) :
                print("All Frames Received")
                break

            # Start Processing Current Frame
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
            def find_centroid(binary_image):
                contours, _ = cv2.findContours(binary_image, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
                if contours:
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

            xLeft, yLeft = find_centroid(processedLeft)
            xRight, yRight = find_centroid(processedRight)

            # Append results to coordinates array
            new_coords = np.array([[xLeft], [yLeft], [xRight], [yRight], [t]])
            coordinates = np.hstack((coordinates, new_coords))  # Append new frame data as a new column

            # 6. Stereo Calculate X,Y,Z at t
            # IMPLEMENT: TBD
            
            # 7. Update t
            end_time = time.time()
            t += int((end_time - start_time) * 1000)  # Convert processing time to ms
            frame += 1  # Increment frame counter

        print("Exiting infinite while loop")
        # Calculate Result
        # IMPLEMENT: TBD
        
        # Send Stop Command
        tcp.sendCMD(STOP_CMD, npSocket)  # Stop Command: Tell Client to stop sending frames and instead request the result back

    elif cmd == 2: # Send Results
        if mode == 1:  # Coeff Mode
            pass  # IMPLEMENT: TBD
        elif mode == 2:  # Shot Mode
            pass  # IMPLEMENT: TBD
        else:  # DEBUGGING MODE
            # Send Coordinate Information
            numFramesMsg = np.array(coordinates.shape[1], dtype=np.uint32)
            npSocket.send(numFramesMsg)
            xLeftMsg = np.ascontiguousarray(coordinates[0, :], dtype=np.uint32)
            yLeftMsg = np.ascontiguousarray(coordinates[1, :], dtype=np.uint32)
            xRightMsg = np.ascontiguousarray(coordinates[2, :], dtype=np.uint32)
            yRightMsg = np.ascontiguousarray(coordinates[3, :], dtype=np.uint32)
            tMsg = np.ascontiguousarray(coordinates[4, :], dtype=np.uint32)
            npSocket.send(xLeftMsg)
            npSocket.send(yLeftMsg)
            npSocket.send(xRightMsg)
            npSocket.send(yRightMsg)
            npSocket.send(tMsg)

    else:
        print("Exit Command. Close Server")
        npSocket.close()  # Close Server
        break  # Break out of the loop for any other value
