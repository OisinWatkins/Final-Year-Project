"""@package UsbADI
Implements a simple usb class, which loads a DLL
The DLL uses the WinUSB API to Read and Write blocks via USB
"""

import ctypes

from numpy import *


class usbADI():
    """Implements an interface to the WinUSB driver

    Loads the dll via ctypes. Arguments which are passed to functions
    (which mainly act as wrapper) are casted to the correct type
    """

    def __init__(self):
        """Load DLL and initialize variables"""
        self.usb            = ctypes.cdll.LoadLibrary("Dll/usb.dll")
        self.UsbOpen        = False

        self.VersionMajor   = self.usb.GetVersMajor()
        self.VersionMinor   = self.usb.GetVersMinor()
        self.VersionFix     = self.usb.GetVersFix()

        # Open Usb Device
        self.UsbOpen        = self.ConnectToDevice()

    def CmdBuild(self, Ack, CmdCod, Data):
        LenData     = len(Data) + 1
        TxData      = zeros(LenData, dtype=uint32)
        TxData[0]   = (2**24)*Ack + (2**16)*LenData + CmdCod
        TxData[1:]  = uint32(Data)
        return TxData

    def CmdSend(self, Ack, Cod, Data):
        Cmd         = self.CmdBuild(Ack, Cod, Data)
        if not self.usb.UsbWriteCmd(ctypes.c_int(len(Cmd)), Cmd.ctypes):
            print("Cmd Write failed")

    def CmdRecv(self):
        Result      = (False, )
        arr = (ctypes.c_char * (4))()
        NrBytes = self.usb.UsbRead(4, arr)
        if NrBytes != 0:
            Header      = fromstring(arr, dtype='uint32')
            LenRxData   = Header[0]//(2**16)
            RxBytes = (ctypes.c_char * (LenRxData-1)*4) ()

            RxBytesLen     = self.usb.UsbRead(int((LenRxData - 1)*4), RxBytes)
            if RxBytesLen == ((LenRxData - 1)*4):
                Data    = zeros(LenRxData - 1, dtype='uint32')
                Data    = fromstring(RxBytes, dtype='uint32')
                Result  = (True, Data)
            else:
                Result  = (False, )
                print("len(RxBytes) wrong: %d != %d" % (len(RxBytes)), (LenRxData - 1)*4)
        else:
            print("Board Not Responding")
        return Result

    def GetDllVersion(self):
        """Prints the DLL version number"""
        return str(self.VersionMajor) + "." + str(self.VersionMinor) + "." + str(self.VersionFix)

    def UsbRead(self, len):
        """Reads "len" bytes"""
        Data        = (ctypes.c_char*(int(len))) ()
        RxDataLen   = self.usb.UsbRead(int(len), Data)
        return Data

    def ConnectToDevice(self):
        """Initializes and Opens DLL driver"""
        if self.UsbOpen:
            print("Device already open.")
            return False
        else:
            Ret = self.usb.ConnectToDevice(True)
            return Ret

    def __del__(self):
        """Closes Usb handles in DLL"""
        self.usb.CloseGlobalHandles()
