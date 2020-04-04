# AN24_04 -- Accessing Calibration Data

import      Class.Adf24Tx2Rx4 as Adf24Tx2Rx4

# (1) Connect to DemoRad: Check if Brd exists: Problem with USB driver
# (2) Read Calibration Data
# (3) Read Calibration Information

#--------------------------------------------------------------------------
# Setup Connection
#--------------------------------------------------------------------------
Brd         =   Adf24Tx2Rx4.Adf24Tx2Rx4()

#--------------------------------------------------------------------------
# Software Version
#--------------------------------------------------------------------------
Brd.BrdDispSwVers()

#--------------------------------------------------------------------------
# Read the positions of the transmit and receive antennas
#--------------------------------------------------------------------------
TxPosn          =   Brd.RfGet('TxPosn')
RxPosn          =   Brd.RfGet('RxPosn')

#--------------------------------------------------------------------------
# Receive the calibration information
#--------------------------------------------------------------------------

CalDat          =   Brd.BrdGetCalDat()
