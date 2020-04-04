# AN77_05 -- Mimo processing
import  Class.Adf24Tx2Rx4 as Adf24Tx2Rx4
import  Class.RadarProc as RadarProc
import  time as time
import  matplotlib.pyplot as plt
from    numpy import *

# (1) Connect to DemoRad
# (2) Enable Supply
# (3) Configure RX
# (4) Configure TX
# (5) Start Measurements
# (6) Configure signal processing
# (7) Calculate DBF algorithm

c0          =   3e8

#--------------------------------------------------------------------------
# Setup Connection
#--------------------------------------------------------------------------
Brd     =   Adf24Tx2Rx4.Adf24Tx2Rx4()

Brd.BrdRst()

Proc    =   RadarProc.RadarProc()
#--------------------------------------------------------------------------
# Load Calibration Data
#--------------------------------------------------------------------------
dCalData            =   Brd.BrdGetCalDat()
CalData             =   dCalData['Dat']

#--------------------------------------------------------------------------
# Configure RF Transceivers
#--------------------------------------------------------------------------
Brd.RfRxEna()
Brd.RfTxEna(1, 63)

plt.ion()
plt.show()

#--------------------------------------------------------------------------
# Configure Up-Chirp
#--------------------------------------------------------------------------
dCfg        =   {
                    "fs"        :   1.0e6,
                    "fStrt"     :   24.0e9,
                    "fStop"     :   24.25e9,
                    "TRampUp"   :   260/1.0e6,
                    "Tp"        :   280/1.0e6,
                    "N"         :   256,
                    "StrtIdx"   :   0,
                    "StopIdx"   :   128,
                    "MimoEna"   :   0,
                    "NrFrms"    :   1000
                }

Brd.RfMeas('Adi', dCfg)
#--------------------------------------------------------------------------
# Read actual configuration
#--------------------------------------------------------------------------
NrChn           =   Brd.Get('NrChn')
N               =   Brd.Get('N')
fs              =   Brd.RfGet('fs')

#--------------------------------------------------------------------------
# Configure Signal Processing
#--------------------------------------------------------------------------
dProcCfg        =   {
                        "fs"        :   Brd.RfGet('fs'),
                        "kf"        :   Brd.RfGet('kf'),
                        "NFFT"      :   2**12,
                        "Abs"       :   1,
                        "Ext"       :   1,
                        "RMin"      :   1,
                        "RMax"      :   10
                    }
Proc.CfgRangeProfile(dProcCfg)


dUlaCfg         =   {
                        "fs"        :   Brd.RfGet('fs'),
                        "kf"        :   Brd.RfGet('kf'),
                        "RangeFFT"  :   2**10,
                        "AngFFT"    :   2**7,
                        "Abs"       :   1,
                        "Ext"       :   1,
                        "RMin"      :   1,
                        "RMax"      :   10,
                        "CalData"   :   CalData
                    }

print("fs: ", Brd.RfGet("fs")/1e6, " MHz")
print("kf: ", Brd.RfGet("kf")/1e12," GHz/ms")

Proc.CfgBeamformingUla(dUlaCfg)
Range           =   Proc.GetRangeProfile('Range')

#--------------------------------------------------------------------------
# Measure and calculate DBF
#--------------------------------------------------------------------------
for MeasIdx in range(0,int(dCfg["NrFrms"])):
    Data        =   Brd.BrdGetData()

    RP          =   Proc.RangeProfile(Data)

    JOpt        =   Proc.BeamformingUla(Data)
    #print("Siz ", JOpt.shape)
    #print(JOpt)
    JMax        =   amax(JOpt)
    JNorm       =   JOpt - JMax
    JNorm[JNorm < -18]  =   -18

    plt.clf()
    plt.imshow(JNorm, origin='lower', extent=[-1,1,-1,1])
    plt.draw()

    plt.pause(0.001)


