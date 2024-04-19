from numpysocket import NumpySocket
import matplotlib as plt
import numpy as np

def getInitParameters(npSocket):
    """
    Receives initial parameters from a remote client via a TCP socket.

    This function resets the initial settings of mode, matchType, and shotType to zero,
    then updates them with values received from the connected socket. It prints a confirmation
    message after receiving the parameters.

    Parameters
    ----------
    npSocket : socket object
        The socket connection over which parameters are received. This should be a socket
        object with a defined `receiveParam()` method.

    Returns
    -------
        tuple
        A tuple containing the mode, matchType, and shotType as integers.
    """
    mode, matchType, shotType = 0, 0, 0    # Reset parameter values
    mode = int(npSocket.receiveCmd())      # 1 = Coefficient of restitution, 2 = In/Out Mode
    matchType = int(npSocket.receiveCmd()) # 1 = Singles, 2 = Doubles
    shotType = int(npSocket.receiveCmd())  # 1 = Serve, 2 = Volley
    print('Received Parameters')
    print("Mode: %d, Match Type: %d, Shot Type: %d" % (mode, matchType, shotType))
    return mode, matchType, shotType

def requestFrame(t, frame, npSocket):
    """
    Sends a request to a MATLAB client to retrieve a stereo frame at a specified time, t.

    Parameters
    ----------
    t : int
        The time of the requested frame, ms.
    frame : int
        The identifier of the frame to be requested.
    npSocket : socket object
        The socket connection over which the frame request is sent.

    Returns
    -------
    None
    """
    request_t = np.array(t, dtype=np.uint32)  # Formatting
    print("Requesting frame %d at t = %d" % (frame, t))
    npSocket.send(request_t)

def receiveFrame(npSocket):
    """
    Receives a stereo frame from a MATLAB client and parces it into four distinct grayscale images.

    Parameters
    ----------
    npSocket : socket object
        The socket connection from which the frame data is received.

    Returns
    -------
    dict
        A dictionary containing numpy arrays for each of the processed grayscale images.
    """
    data = npSocket.receive()
    stereoImage = np.reshape(data, (480, 752, 8))
    print('Received Frame')
    return {
        'ballLeftGray': np.ascontiguousarray(stereoImage[:, :, 0], dtype=np.uint8),
        'emptyLeftGray': np.ascontiguousarray(stereoImage[:, :, 1], dtype=np.uint8),
        'ballRightGray': np.ascontiguousarray(stereoImage[:, :, 4], dtype=np.uint8),
        'emptyRightGray': np.ascontiguousarray(stereoImage[:, :, 5], dtype=np.uint8)
    }

def sendCMD(cmd, npSocket):
    """
    Sends a command to a MATLAB client via a TCP socket.

    This function takes a command, formats it as an unsigned 32-bit integer, and sends
    it to the connected socket.
    Parameters
    ----------
    cmd : int
        The command to be sent. Must be an integer representable as a uint32.
    npSocket : socket object
        The socket connection over which the command is sent.

    Returns
    -------
    None
    """
    cmd_msg = np.array(cmd, dtype=np.uint32)  # Formatting
    npSocket.send(cmd_msg)
