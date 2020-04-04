# Getting Started

# (1) Connect to DemoRad
# (2) Display DSP Software version
# (3) Display UID

# import Class.Adf24Tx2Rx4 as Adf24Tx2Rx4

from Class import Adf24Tx2Rx4


#----------------------------------------
# Setup Connection
#----------------------------------------

Brd = Adf24Tx2Rx4.Adf24Tx2Rx4()

#----------------------------------------
# Software Version
#----------------------------------------

Brd.BrdDispSwVers()

#----------------------------------------
# Board UID
#----------------------------------------

Uid = Brd.BrdGetUID()
print(Uid[1])
