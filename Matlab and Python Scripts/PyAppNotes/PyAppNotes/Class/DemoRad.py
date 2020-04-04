"""@package DemoRad
Implements the DemoRad class, which uses the UsbADI Module to communicate with the DemoRad board.
"""


import Class.UsbADI as usb
import ctypes
import numpy as np
import struct
import time

from numpy import *

class DemoRad():
    FrmwrFlshNrBlcks = 64
    FrmwrFlshNrSctrs = 16
    FrmwrFlshSzSctr = 1024
    FrmwrFlshSzSctrByts = 4 * 1024
    FrmwrRdSz = 128

    """Implementation of DemoRad class

    Uses the UsbADI Module to Read and Write data via USB.
    Implements functions to send specific commands to the Dsp and it's attached components
    """
    def __init__(self):
        self.DebugInf = 0

        self.stBlkSize              = 128*256*4*4/2
        self.stChnBlkSize           = self.stBlkSize/4
        self.ChirpSize              = 256*4*4/2

        self.usb                = usb.usbADI()

        self.CalPage            = 0

        # ------------------------------------------------------------------
        # Configure Sampling
        # ------------------------------------------------------------------
        self.Rad_N = 256

        self.Rad_NrChn              =   4

        self.ADR7251Cfg = [ 0x00000000,
                            0x0000004B,
                            0x00001203,
                            0x00013307,
                            0x01C20001,
                            0x00000002,
                            0x00010064,
                            0x0002004C,
                            0x00032833,
                            0x01400003,
                            0x00060000,
                            0x00400001,
                            0x004100FF,
                            0x004203CF,
                            0x00800000,
                            0x00810000,
                            0x00860000,
                            0x01000055,             # LNA Gain 4
                            0x01010055,             # PGA 2.8
                            0x01022222,
                            0x01030000,
                            0x01410019,
                            0x014210C0,
                            0x01430000,
                            0x01440002,
                            0x014500C8,
                            0x01C00040,
                            0x01C10000,
                            0x02100000,
                            0x02110000,
                            0x02500000,
                            0x02510000,
                            0x02600000,
                            0x02610000,
                            0x02700000,
                            0x02710000,
                            0x02800000,
                            0x02810000,
                            0x02820004,
                            0x02830000,
                            0x02840004,
                            0x02850004,
                            0x02860003,
                            0x02870003,
                            0x02880003,
                            0x02890003,
                            0x028A0003,
                            0x028B0003,
                            0x028C0003,
                            0x028D0003,
                            0x028E0003,
                            0x02910003,
                            0x02920000,
                            0x03000000,
                            0x03010306,
                            0x03020000,
                            0x03030000,
                            0x03050001,
                            0x03070000,
                            0x03080013,
                            0x030A0001,
                            0x030C0000,
                            0x030D0000,
                            0x030E0000,
                            0x030F0000,
                            0x03100000,
                            0x031100AA,
                            0x031200AA,
                            0x03130055,
                            0x03140055,
                            0x03150099,
                            0x03160099,
                            0x03170066,
                            0x03180066,
                            0x032000AA,
                            0x032100AA,
                            0x03220000,
                            0x03230000 ]

        self.ADIFMCWCfg = [ 0x00000000,
                            0x00000007,
                            0x00001100,
                            0x00000080,
                            0x00000100,
                            0x00000004,
                            0x00000008,
                            0x00000024,
                            0x00000001,
                            0x0000000A ]

        self.ADICal     = [  0x00000000,
                             0x00000027,
                             0x00001002,
                             0x00000002,
                             0x00000010,
                             0x00000020,
                             0x00000030,
                             0x00000040,
                             0x00000012,
                             0x00000022,
                             0x00000032,
                             0x00000042,
                             0x00000010,
                             0x00000020,
                             0x00000030,
                             0x00000040,
                             0x00000012,
                             0x00000022,
                             0x00000032,
                             0x00000042,
                             0x00000010,
                             0x00000020,
                             0x00000030,
                             0x00000040,
                             0x00000012,
                             0x00000022,
                             0x00000032,
                             0x00000042,
                             0x00000010,
                             0x00000020,
                             0x00000030,
                             0x00000040,
                             0x00000012,
                             0x00000022,
                             0x00000032,
                             0x00000042,
                             0x00000010,
                             0x00000020,
                             0x00000030,
                             0x00000040,
                             0x00000012,
                             0x00000022,
                             0x00000032
        ]
        self.ADICalGet  = [ 0x00000001,
                            0x00000005,
                            0x00001002,
                            0x00000004,
                            0x00000003 ]


    def CmdSend(self, Ack, Cod, Data):
        """Wraps the usb function"""
        self.usb.CmdSend(Ack, Cod, Data)

    def CmdRecv(self):
        """Wraps the usb function"""
        return self.usb.CmdRecv()

    def Dsp_SendSpiData(self, SpiCfg, Regs):
        """Sends Data to device (selected by mask) using spi"""
        Regs = Regs.flatten(1)
        if (len(Regs) > 28):
            Regs = Regs[0:28]

        DspCmd = zeros(3 + len(Regs), dtype='uint32')
        Cod = int('0x9017', 0)
        DspCmd[0] = SpiCfg["Mask"]
        DspCmd[1] = 1
        DspCmd[2] = SpiCfg["Chn"]
        DspCmd[3:] = Regs

        Ret = self.usb.CmdSend(0, Cod, DspCmd)
        Ret = self.usb.CmdRecv()
        return Ret

    def Dsp_GetChirp(self, startpos, stoppos):
        """"Returns Chirp(s) starting at startpos, ending at stoppos"""
        DspCmd      = zeros(3, dtype='uint32')
        Cod         = int('0x7003', 0)
        DspCmd[0]   = 1
        DspCmd[1]   = startpos
        DspCmd[2]   = stoppos
        self.CmdSend(0, Cod, DspCmd)

        chirps      = stoppos - startpos
        Data        = self.usb.UsbRead((self.ChirpSize * chirps))
        RetData     = fromstring(Data, dtype='int16')
        Ret         = reshape(RetData, (len(RetData) // 4, 4))
        self.CmdRecv()
        return Ret[:,::-1]

    def Dsp_GetSwVers(self):
        """Reads the Software Version from the DSP and prints it"""
        DspCmd = zeros(1, dtype='uint32')
        Cod = int('0x900E', 0)
        DspCmd[0] = 0
        Vers = self.CmdSend(0, Cod, DspCmd)
        Vers = self.CmdRecv()
        dRet = {
            "SwPatch": -1,
            "SwMin": -1,
            "SwMaj": -1,
            "SUid": -1,
            "HUid": -1
        }
        if Vers[0] is True:
            Data = Vers[1]
            if len(Data) > 2:
                Tmp = Data[0]
                SwPatch = int(Tmp % 2 ** 8)
                Tmp = floor(Tmp / 2 ** 8)
                SwMin = int(Tmp % 2 ** 8)
                SwMaj = int(floor(Tmp / 2 ** 8))
                dRet["SwPatch"]     = SwPatch
                dRet["SwMin"]       = SwMin
                dRet["SwMaj"]       = SwMaj
                dRet["SUid"]        = Data[1]
                dRet["HUid"]        = Data[2]
            else:
                print("No Version information available")
        return dRet

    def BrdGetSwVers(self):
        return self.Dsp_GetSwVers()

    def BrdDispSwVers(self):
        VersInfo = self.Dsp_GetSwVers()
        print("")
        print("===================================")

        if len(VersInfo) > 2:
            print("Board Version Information")
            print("Sw-Rev: " + str(VersInfo["SwMaj"]) + "." + str(VersInfo["SwMin"]) + "." + str(VersInfo["SwPatch"]))
            print("Sw-UID: " + str(VersInfo["SUid"]))
            print("Hw-UID: " + str(VersInfo["HUid"]))
        else:
            print("No version information available")
        print("===================================")

    def Dsp_GetBrdSts(self):
        """ Returns the Dsp Status. """
        Cmd             =   ones(1,dtype='uint32')
        Cod             =   int("0x6008", 0)
        Ret             =   self.CmdSend(0, Cod, Cmd)
        Ret             =   self.CmdRecv()
        return Ret

    def Dsp_SetTestDat(self, enable):
        """Enables sinwave instead of measured data, 0 = disable"""
        Cmd             =   ones(2,dtype='uint32')
        Cod             =   int("0x6005", 0)
        Cmd[1]          =   enable
        Ret             =   self.CmdSend(0, Cod, Cmd)
        Ret             =   self.CmdRecv()
        return Ret

    def Dsp_SetAdiDefaultConf(self):
        """ Returns the Dsp Status. """
        print("Set ADI Defaults")
        Cmd             =   ones(2,dtype='uint32')
        Cod             =   int("0x6006", 0)

        # This is necessary until a valid reconfiguration for the ADAR7251 is
        # available. If the ADAR7251 gets reconfigured the same way, when
        # sampling is running, only one frame is returned (blocks on spi_data_done on dsp)
        Cmd[1]          =   3
        Ret             =   self.CmdSend(0, Cod, Cmd)
        arr             = asarray(list(self.ADR7251Cfg))
        TxData          = zeros(len(arr), dtype=uint32)
        TxData[0:]      = uint32(arr)
        self.usb.usb.UsbWriteADICmd(ctypes.c_uint32(len(TxData)), TxData.ctypes)
        Ret             =   self.CmdRecv()

        Cmd[1]          = 4
        Ret             = self.CmdSend(0, Cod, Cmd)
        arr             = asarray(list(self.ADIFMCWCfg))
        TxData          = zeros(len(arr), dtype=uint32)
        TxData[0:]      = uint32(arr)
        self.usb.usb.UsbWriteADICmd(ctypes.c_uint32(len(TxData)), TxData.ctypes)
        Ret             = self.CmdRecv()
        return Ret

    def BrdSetCalElem(self, CalElemArr):
        """Sets Data at given Address.
        First Value should be address, following the data to set,
        after that the next address + value etc.. """
        Cmd = ones(2 + len(CalElemArr), dtype='uint32')
        Cod = int("0x6007", 0)

        Cmd[1] = 2
        Cmd[2:] = uint32(CalElemArr)

        Ret = self.CmdSend(0, Cod, Cmd)
        Ret = self.CmdRecv()
        return Ret

    def BrdGetCalElem(self, CalAddrArr):
        """Returns Calibration data, read from address given.
        Format should be an array with addresses.
        Returns an array with the values at the positions read"""
        Cmd = ones(2 + len(CalAddrArr), dtype='uint32')
        Cod = int("0x6007", 0)

        Cmd[1] = 3
        Cmd[2:] = uint32(CalAddrArr)

        Ret = self.CmdSend(0, Cod, Cmd)
        Ret = self.CmdRecv()
        return Ret

    def BrdEraseCalSector(self):
        """Erases a sector in the winbond flash. Currently hardcoded in dsp (Sector 63)"""
        Cmd = ones(2, dtype='uint32')
        Cod = int("0x6007", 0)

        Cmd[1] = 4

        Ret = self.CmdSend(0, Cod, Cmd)
        Ret = self.CmdRecv()
        return Ret

    def BrdGetUID(self):
        """Returns the UID of the Device"""
        Cmd = ones(2, dtype='uint32')
        Cod = int("0x9030", 0)
        Cmd[1] = 0

        Ret = self.CmdSend(0, Cod, Cmd)
        Ret = self.CmdRecv()
        return Ret

    def BrdWrEEPROM(self, Addr, Data):
        """Writes a 32 bit value (size in eeprom is 8 bit),
        starting at given address """
        Cmd = ones(4, dtype='uint32')
        Cod = int("0x9030", 0)
        Cmd[1] = 1
        Cmd[2] = Addr
        Cmd[3] = Data

        Ret = self.CmdSend(0, Cod, Cmd)
        Ret = self.CmdRecv()

        return Ret

    def BrdRdEEPROM(self, Addr):
        """Reads a 32bit value, starting at given address"""
        Cmd     = ones(3, dtype='uint32')
        Cod     = int("0x9030", 0)
        Cmd[1]  = 2
        Cmd[2]  = Addr

        Ret     = self.CmdSend(0, Cod, Cmd)
        Ret     = self.CmdRecv()
        return Ret

    def BrdGetCalDat(self):
        """Returns Cal Data from EEPROM"""
        print("Get Cal Data")
        CalDat      = zeros(32*4, dtype='uint8')
        for Loop in range(32*4):
            rdelem = self.BrdRdEEPROM(Loop)
            CalDat[Loop] = np.uint8(rdelem[1][0])
        CalRet = zeros(32, dtype='uint32')
        CalRdCnt = 0
        for Loop in range(len(CalRet)):
            CalRet[Loop] = CalDat[CalRdCnt] \
                           | (CalDat[CalRdCnt+1] << 8) \
                           | (CalDat[CalRdCnt+2] << 16) \
                           | (CalDat[CalRdCnt+3] << 24)
            CalRdCnt = CalRdCnt + 4
        dCal            =   dict()

        # Convert: data to double and account for signed values in case of cal data
        ConvDat         =   zeros(16)
        for Idx in range(0,16):
            if CalRet[Idx] > 2**31:
                ConvDat[Idx]    =   CalRet[Idx] - 2**32
            else:
                ConvDat[Idx]    =   CalRet[Idx]

        CalDat          =   zeros(8, dtype='complex')
        CalDat[:]       =   double(ConvDat[0:16:2])/2**24 + 1j*double(ConvDat[1:16:2])/2**24

        print("CalDat: ", CalDat)
        dCal["Dat"]     =   CalDat
        dCal["Type"]    =   CalRet[16]
        dCal["Date"]    =   CalRet[17]
        dCal["R"]       =   CalRet[18]/2**16
        dCal["RCS"]     =   CalRet[19]/2**16
        dCal["TxGain"]  =   CalRet[20]/2**16
        dCal["IfGain"]  =   CalRet[21]/2**16
        return dCal

    def BrdSetCalDat(self, dCalData):
        """Sets Cal Data"""
        print("Set Cal Data")
        CalReal         =   real(dCalData["Dat"])*2**24
        CalImag         =   imag(dCalData["Dat"])*2**24

        CalData         =   zeros(22,dtype='uint32')
        CalData[0:16:2] =   CalReal
        CalData[1:16:2] =   CalImag
        CalData[16]     =   dCalData["Type"]
        CalData[17]     =   dCalData["Date"]
        CalData[18]     =   dCalData["R"]*2**16
        CalData[19]     =   dCalData["RCS"]*2**16
        CalData[20]     =   dCalData["TxGain"]*2**16
        CalData[21]     =   dCalData["IfGain"]*2**16


        if len(CalData) < 32:
            DatSend = zeros(len(CalData), dtype='uint32')
            DatSend[0:] = CalData
            WrDat = zeros(len(CalData)*4, dtype='uint8')
            SendCnt = 0
            for Loop in range(len(DatSend)):
                uint32 = struct.pack("I", DatSend[Loop])
                arr = struct.unpack("B" * 4, uint32)
                WrDat[SendCnt]    = arr[0]
                WrDat[SendCnt+1]  = arr[1]
                WrDat[SendCnt+2]  = arr[2]
                WrDat[SendCnt+3]  = arr[3]
                SendCnt = SendCnt + 4
            for i in range(len(WrDat)):
                self.BrdWrEEPROM(i, WrDat[i])
            return True
        else:
            print("CalData array to long to fit in EEPROM")
            return False

    def BrdRst(self):
        """Resets the board, currently has no effect as there is no reliable way to
        do this without reinitializing the usb connection"""
        print("DemoRad.BrdRst")
        Cmd             =   ones(2,dtype='uint32')
        Cod             =   int("0x6006", 0)

        Cmd[1]          =   5
        Ret             =   self.CmdSend(0, Cod, Cmd)
        Ret             =   self.CmdRecv()
        Ret             =   self.Dsp_MimoSeqRst()
        return Ret

    def BrdSampStp(self):
        print("Stop sampling")
        Cmd             =   ones(2,dtype='uint32')
        Cod             =   int("0x6006", 0)

        Cmd[1]          =   6
        Ret             =   self.CmdSend(0, Cod, Cmd)
        Ret             =   self.CmdRecv()

    def BrdPwrEna(self):
        #   @function       BrdPwrEna
        #   @author         Philipp Wagner
        #   @date           07.12.2016
        #   @brief          Enable all power supplies for RF frontend
        dPwrCfg = {}
        Ret = self.Dsp_SetRfPwr(dPwrCfg)
        return Ret

    def Dsp_Strt(self):
        #   @function       Dsp_Strt
        #   @author         Philipp Wagner
        #   @date           07.12.2016
        #   @brief          Start application
        ArmCmd          =   ones(1,dtype='uint32')
        Cod             =   int("0x6004", 0)
        Ret             =   self.CmdSend(0, Cod, ArmCmd)
        Ret             =   self.CmdRecv()
        return Ret

    def     Dsp_SetMimo(self, Val):
        Cmd             =   ones(2,dtype='uint32')
        Cod             =   int("0x7004", 0)
        Cmd[1]          =   uint32(Val)
        Ret             =   self.CmdSend(0, Cod, Cmd)
        Ret             =   self.CmdRecv()
        return Ret

    def Dsp_SeqTrigRst(self, Mask):

        print("DemoRad.Dsp_SeqTrigRst not implemented")
        return

    def Dsp_MimoSeqRst(self):
        # TODO: not implemented, not needed?
        print("DemoRad.Dsp_MimoSeqRst not implemented")
        return

    def Dsp_SetRfPwr(self, dCfg):
        # TODO: not implemented, not needed. No option to enable/disable power for RF
        print("DemoRad.Dsp_SetRfPwr not implemented")
        return

    def Set(self, stVal, *varargin):
        # TODO: decide what to do here.
        if stVal == 'DebugInf':
            if len(varargin) > 0:
                self.DebugInf    =   varargin[0]
        elif stVal == 'Name':
            if len(varargin) > 0:
                if isinstance(varargin[0], str):
                    self.Name       =   varargin[0]
        elif stVal == 'N':

            if len(varargin) > 0:
                Val         =   varargin[0]
                Val         =   floor(Val)
                Val         =   ceil(Val/8)*8
                self.Rad_N  =   Val
        elif stVal == 'Samples':
            if len(varargin) > 0:
                Val         =   varargin[0]
                Val         =   floor(Val)
                Val         =   ceil(Val/8)*8
        elif stVal ==  'NrFrms':
            if len(varargin) > 0:
                NrFrms      =   floor(varargin[0])
                if NrFrms < 1:
                    NrFrms  =   1
                if NrFrms > 2**31:
                    NrFrms  =   2**31
                    print('Limit Number of Frames')
                self.Rad_NrFrms  =   NrFrms
        elif stVal ==  'NrChn':
            if len(varargin) > 0:
                NrChn       =   floor(varargin[0])
                if NrChn < 1:
                    NrChn   =   1
                if NrChn > 12:
                    NrChn   =   12
                print('Set NrChn to: ', NrChn)
                Mask12                      =   2**12 - 1
                Mask                        =   2**NrChn - 1
                self.Rad_MaskChn            =   Mask
                self.Rad_MaskChnEna         =   Mask
                self.Rad_MaskChnRst         =   Mask12 - Mask
                self.Rad_FrmCtrlCfg_ChnSel  =   Mask
                self.Rad_CicCfg_FiltSel     =   Mask
                self.Rad_FUsbCfg_ChnEna     =   Mask
                self.Rad_NrChn              =   NrChn
                self.Rad_SRamFifoCfg_ChnMask=   Mask
        else:
            pass

    def Get(self, stVal, *varargin):
        Ret = -1
        if isinstance(stVal, str):
            if stVal == 'DebugInf':
                Ret     =   self.DebugInf
            elif stVal == 'Name':
                Ret     =   self.Name
            elif stVal == 'N':
                Ret     =   self.Rad_N
            elif stVal == 'Samples':
                Ret     =   self.Rad_N
            elif stVal == 'NrFrms':
                Ret     =   self.Rad_NrFrms
            elif stVal == 'NrChn':
                Ret         =   self.Rad_NrChn
            elif stVal == 'FuSca':
                self.FuSca = 0.498 / 65536
                Ret = self.FuSca
            else:
                pass
        return Ret

    def BrdSampStrt(self):
        # TODO: needs to be adjusted to work woth dsp
        return

    def Dsp_FmwrUpdtRmFlsh(self):
        # Complete Chip Erase
        Cmd = zeros(6, dtype='uint32')
        Cod = int("0x6009", 0)

        Cmd[1] = 0
        Cmd[2] = 0
        Cmd[3] = 0
        Cmd[4] = 0
        Cmd[5] = 0
        Ret = self.CmdSend(0, Cod, Cmd)
        # Wait 15 Seconds, according to datasheet this typically takes 10 seconds, but up to 50.
        time.sleep(15)
        Ret = self.CmdRecv()
        return Ret

    def Dsp_FmwrUpdtRdPt(self, Block, Sector, Addr):
        """Reads a 32bit value, starting at given address"""
        Cmd = ones(6, dtype='uint32')
        Cod = int("0x6009", 0)
        Cmd[1] = 1
        Cmd[2] = Block
        Cmd[3] = Sector
        Cmd[4] = Addr
        Cmd[5] = self.FrmwrRdSz
        Ret = self.CmdSend(0, Cod, Cmd)
        Ret = self.CmdRecv()
        return Ret

    def Dsp_FmwrUpdtWrPt(self, Block, Sector, Addr, Data):
        """Reads a 32bit value, starting at given address"""
        Cmd = ones(6 + self.FrmwrRdSz, dtype='uint32')
        Cod = int("0x6009", 0)
        Cmd[1] = 2
        Cmd[2] = Block
        Cmd[3] = Sector
        Cmd[4] = Addr
        Cmd[5] = self.FrmwrRdSz
        Cmd[6:] = uint32(Data[0:])

        Ret = self.CmdSend(0, Cod, Cmd)
        Ret = self.CmdRecv()
        return Ret

    def __del__(self):
        del self.usb
