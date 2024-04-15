# ZynqServer_3.py is a simulation of the final implementation EXCLUDING the FPGA Processing.
# 1. Open Server and await client connection and transfer protocol
# 2. Respond to transfer protocol rquests
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
print ("Server Started")

# ENTER INFINITE MAIN LOOP
while(1):
    # TOP TRANSFER PROTOCOL MANAGEMENT
    cmd = npSocket.receiveCmd()  # Await Transfer Protocol cmd
    match cmd:
        case '0':  # INIT PARAMETERS
            # RESET ALL FOR NEW SHOT

            # Get init parameters

            pass  # Placeholder for implementation when cmd is 0
        case '1':  # Process Shot
            t = 0; # initialize to start of shot
            frame = 0; # current frame counter
            # While more frames to process
            # 1. Send request for frame at t
            # 2. Receive stereoImage for t
            # 3. Pass through to FPGA
            # 4. Receive processedImage from FPGA
            # 5. Centroid Detection
            # 6. Stereo Calculate X,Y,Z at t
            # 7. Update t
            # 8. Check if finished
                # If Finished
                # All Frames Processed
                # Calculate Result
                # Send Stop Command

            pass  # Placeholder for implementation when cmd is 1
        case '2':  # Send Results
            # Check Mode
                # Shot Mode
                # Send Mode Format TP
                # Send In/Out
                # Send X,Y,Z array over t
            
                # Coeff Mode
                # Send Mode Format TP
                # Send Coeff
            
            pass  # Placeholder for implementation when cmd is 2
        case _:
            print("Exit Command. Close Server")
            npSocket.close()  # Close Server
            break  # Break out of the loop for any other value