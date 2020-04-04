# AN24_02 -- FMCW Basics 

import      src.cmd_modules.Adf24Tx2Rx4 as Adf24Tx2Rx4
import      src.cmd_modules.DemoRad as DemoRad
import      time as time
import      numpy as np

# (1) Connect to Radarbook
# (2) Enable Supply
# (3) Configure RX
# (4) Configure TX
# (5) Start Measurements
# (6) Configure calculation of range profile

#--------------------------------------------------------------------------
# Setup Connection
#--------------------------------------------------------------------------
Brd         =   DemoRad.DemoRad();
RfBrd       =   Adf24Tx2Rx4.Adf24Tx2Rx4(Brd);

Brd.BrdRst()

#--------------------------------------------------------------------------
# Software Version
#--------------------------------------------------------------------------
Brd.BrdDispSwVers()

#--------------------------------------------------------------------------
# Configure Receiver
#--------------------------------------------------------------------------
RfBrd.RfRxEna();
TxPwr       =   100
NrFrms      =   4
#--------------------------------------------------------------------------
# Configure Transmitter (Antenna 0 - 4, Pwr 0 - 31)
#--------------------------------------------------------------------------
RfBrd.RfTxEna(1, TxPwr)

#--------------------------------------------------------------------------
# Configure Up-Chirp
#--------------------------------------------------------------------------
dCfg        =   {
                    "fStrt"     :   24.0e9,
                    "fStop"     :   24.25e9,
                    "TRampUp"   :   128e-6,
                    "N"         :   256,
                    "StrtIdx"   :   0,
                    "StopIdx"   :   2,
                }


RfBrd.RfMeas('Adi', dCfg);

fStrt           =   RfBrd.Adf_Pll.fStrt
fStop           =   RfBrd.Adf_Pll.fStop
TRampUp         =   RfBrd.Adf_Pll.TRampUp

DataTx1         =   np.zeros((256*dCfg["StopIdx"]*4, int(NrFrms)))
for Cycles in range(0, int(NrFrms)):
    Data        =   RfBrd.BrdGetData()
    print("FrmCntr: ", Data[0,:])
    print(" Shape: ", Data.shape)

    DataTx1[:,Cycles]   =   np.ndarray.flatten(Data.transpose())


del Brd
del RfBrd