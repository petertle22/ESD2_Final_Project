"""
ZynqServer_5.py
"""
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
import ballDetection as ball
from frameGrabber import ImageProcessing
from frameGrabber import ImageFeedthrough
from frameGrabber import ImageWriter

# CONSTANTS
#----------------------------------------------------------------------------------------------------------
# TCP Commands
STOP_CMD = 99999
INIT_CMD = 0
PROCESS_CMD = 1
RESULTS_CMD = 2

# General Mapping
MODE_COEFF = 1
MODE_IN_OUT = 2

# SETTINGS
FPGA_ENABLE = True
WINDSHIFT_ENABLE = False
ACCEL_PROCESSING = True
FRAME_REQUEST_TIMEOUT = 2000
T_SKIP = 20
#----------------------------------------------------------------------------------------------------------
camProcessed = ImageProcessing()
camFeedthrough = ImageFeedthrough()
camWriter = ImageWriter()

# Open Server
npSocket = NumpySocket()
npSocket.startServer(9999)
print("Server Started")

# ENTER INFINITE MAIN LOOP
while True:
    # TOP TRANSFER PROTOCOL MANAGEMENT
    print('Awaiting cmd...')
    cmd = int(npSocket.receiveCmd())  # Await Transfer Protocol cmd
    if cmd == INIT_CMD: # INIT PARAMETERS
        # Get init parameters from client
        mode, matchType, shotType = tcp.getInitParameters(npSocket)

    elif cmd == PROCESS_CMD: # Process Shot
        # Initialize Variables
        resultsReady = False
        t = 1  # initialize to start of shot
        frame = 0  # current frame counter
        ballPositionXYZ = np.zeros((4, 0), dtype=int)  # Initialize a 2D array with 4 rows and dynamic columns

        # SPEED OPTIMIZATION
        dummyFrame = np.zeros((480, 752), dtype=np.uint8)  # Initialize an empty dummy image
        _, _, _ = ball.find_centroid(dummyFrame)

        # Process All Frames
        while True:  # While more frames to process
            # Get images at time t
            if (t > FRAME_REQUEST_TIMEOUT): # Check for invalid t request
                print("All Frames Received")
                break
            tcp.requestFrame(t, frame, npSocket) # Send request for frame at t
            frame_data, raw_data = tcp.receiveFrame(npSocket) # Receive frame for t
            # Access the individual images from frame
            ballLeftGray = frame_data['ballLeftGray']
            emptyLeftGray = frame_data['emptyLeftGray']
            ballRightGray = frame_data['ballRightGray']
            emptyRightGray = frame_data['emptyRightGray']

            # Start Processing Current Frame
            start_time = time.time()  # start a timer from 0 to track processing time
            # 0. Adapt stereo background to possible wind shifts in new stereo image
            if (WINDSHIFT_ENABLE): # Wind present, may shift camera around
                # IMPLEMENT 
                # Account for a winshift in teh new ball images
                pass
            else: # No processing needed. Images are perfectly alligned
                pass

            # 1. Process frames to isolate ball from background
            if (FPGA_ENABLE): # Processing needed by FPGA
                camWriter.setFrame(raw_data)
                processedLeft,processedRight = camProcessed.getStereoGray()
            else: # No processing needed. Server Initially receieved processed images
                processedLeft = ballLeftGray # => processedLeft = channel_0 image from client stream
                processedRight = emptyLeftGray # => processedRight = channel_0 image from client stream

            # 2. Centroid Detection
            ballFound, xLeft, yLeft = ball.find_centroid(processedLeft)
            ballFound, xRight, yRight = ball.find_centroid(processedRight)

            # 3. Stereo Calculate X,Y,Z at t
            if ((t > 5) and (ballFound)): # Only Calculate for frames after initialization and with a found ball
                X, Y, Z = ball.calcStereoXYZ(xLeft, yLeft, xRight, yRight)
                newPosition = np.array([[X], [Y], [Z], [t]])
                ballPositionXYZ = np.hstack((ballPositionXYZ, newPosition))  # Append new frame data as a new column
                frame += 1  # Increment frame counter

            # 4. Update t
            end_time = time.time()
            if ((not ballFound) and (ACCEL_PROCESSING)): # DEBUGGING update t faster when ball is out of frame
                t += T_SKIP
            else:
                t += int((end_time - start_time) * 1000)  # Convert processing time to ms

        # All Frames Processed
        print("Exiting process frames loop")
        resultsReady = True
        tcp.sendCMD(STOP_CMD, npSocket)  # Stop Command: Tell Client to stop sending frames and instead request the result back
        print('Sent Stop CMD')

    elif cmd == RESULTS_CMD: # Send Results
        print('Results Requested...')
        # Calculate Corresponding Result
        if (resultsReady):
            if (mode == MODE_COEFF):  # Coeff Mode
                print('Calculating Coefficient of Restitution...')
                result = ball.getCoefficientOfRestitution(ballPositionXYZ)
                tcp.sendResult(mode, result, )
            elif mode == MODE_IN_OUT:  # Shot Mode
                print('Calculating In/Out...')
                # IMPLEMENT
            else:  # DEBUGGING MODE
                print('DEBUGGING RESULTS...')
                # Send XYZ over t Information
                ballPositionXYZ = ball.filterStereoXYZ(ballPositionXYZ)
                tcp.sendBallXYZ(ballPositionXYZ, npSocket)
                print('Bounce t:')
                print(ball.findBounceT(ballPositionXYZ))
                result = ball.getCoefficientOfRestitution(ballPositionXYZ)
                print('Coeff:')
                print(result)

            # Send Calculated Result
            #tcp.sendResult(mode, result, ballPositionXYZ, npSocket) # Debugging results will not be sent
            print('Results Sent')
                        # Display Image Processing 
            fig, axs = plt.subplots(1, 2, figsize=(15, 5))  # 1 row, 3 columns
            # Plot the first image: ballLeftGray
            axs[0].imshow(processedLeft, cmap='gray')  # cmap='gray' ensures grayscale display
            axs[0].axis('off')  # Hide the axes
            axs[0].set_title('Left')
            # Plot the second image: emptyLeftGray
            axs[1].imshow(processedRight, cmap='gray')
            axs[1].axis('off')
            axs[1].set_title('Right')
            plt.show()

        # Client has requested results at an invalid time
        else :
            print('Results Not Valid')

    else: # Received Terminate Command
        print("Exit Command. Close Server")
        npSocket.close()  # Close Server
        break  # Break out of the loop for any other value
