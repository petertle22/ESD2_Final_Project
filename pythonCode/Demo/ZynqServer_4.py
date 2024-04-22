# ZynqServer_4.py performs the following functions
# 1. 
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

# CONSTANTS
STOP_CMD = 99999
#----------------------------------------------------------------------------------------------------------