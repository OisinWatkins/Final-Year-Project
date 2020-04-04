# AN24_02 -- FMCW Basics

import      Class.Adf24Tx2Rx4 as Adf24Tx2Rx4
from        numpy import *

# (1) Connect to Radarbook
# (2) Enable Supply
# (3) Configure RX
# (4) Configure TX
# (5) Start Measurements
# (6) Configure calculation of range profile

#--------------------------------------------------------------------------
# Setup Connection
#--------------------------------------------------------------------------
Brd       =   Adf24Tx2Rx4.Adf24Tx2Rx4()

Brd.BrdRst()

#--------------------------------------------------------------------------
# Software Version
#--------------------------------------------------------------------------
Brd.BrdDispSwVers()

#--------------------------------------------------------------------------
# Configure Receiver
#--------------------------------------------------------------------------
Brd.RfRxEna()
TxPwr       =   100
NrFrms      =   4
#--------------------------------------------------------------------------
# Configure Transmitter (Antenna 0 - 3, Pwr 0 - 31)
#--------------------------------------------------------------------------
Brd.RfTxEna(1, TxPwr)

#--------------------------------------------------------------------------
# Configure Up-Chirp
#--------------------------------------------------------------------------
dCfg        =   {
                    "fs"        :   1.0e6,
                    "fStrt"     :   24.0e9,
                    "fStop"     :   24.25e9,
                    "TRampUp"   :   260/1.0e6,
                    "Tp"        :   300/1.0e6,
                    "N"         :   256,
                    "StrtIdx"   :   0,
                    "StopIdx"   :   2,
                    "MimoEna"   :   0
                }

Brd.RfMeas('Adi', dCfg);

fStrt           =   Brd.Adf_Pll.fStrt
fStop           =   Brd.Adf_Pll.fStop
TRampUp         =   Brd.Adf_Pll.TRampUp

DataTx1         =   zeros((256*dCfg["StopIdx"]*4, int(NrFrms)))
for Cycles in range(0, int(NrFrms)):
    Data        =   Brd.BrdGetData()
    print("FrmCntr: ", Data[0,:])

del Brd
