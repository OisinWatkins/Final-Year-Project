import  re


def ToInt(stVal):

    if isinstance(stVal, str):
        RegHex      =   re.compile(r"(?P<HexVal>[0-9a-fA-F]+)[h]{1}")
        RegDec      =   re.compile(r"(?P<DecVal>[0-9]+)[d]{1}")
        RegVal      =   re.compile(r"(?P<DecVal>[0-9]+)")
        MatchHex    =   RegHex.search(stVal) 
        MatchDec    =   RegDec.search(stVal)
        MatchVal    =   RegVal.search(stVal)
        if MatchHex:
            Val     =   MatchHex.groups("HexVal")
            Val     =   (int(Val[0],16))
        elif MatchDec:
            Val     =   MatchDec.groups("HexVal")
            Val     =   int(Val[0])
        elif MatchVal:
            Val     =   MatchVal.groups("HexVal")
            Val     =   int(Val[0])
        else:
            Val     =   0            
    elif isinstance(stVal, float):
        Val         =   int(stVal)
    elif isinstance(stVal, int):
        Val         =   stVal
    else:
        Val         =   0

    return Val

def ToFloat(stVal):

    if isinstance(stVal,str):
        RegHex      =   re.compile(r"(?P<HexVal>[0-9a-fA-F]+)[h]{1}")
        RegDec      =   re.compile(r"(?P<DecVal>[0-9]+)[d]{1}")
        RegVal      =   re.compile(r"(?P<DecVal>([-]{0,1}[0-9]+[.]{0,1}[0-9]*))")
        MatchHex    =   RegHex.search(stVal) 
        MatchDec    =   RegDec.search(stVal)
        MatchVal    =   RegVal.search(stVal)
        if MatchHex:
            Val     =   MatchHex.groups("HexVal")
            Val     =   float(int(Val[0],16))
        elif MatchDec:
            Val     =   MatchDec.groups("HexVal")
            Val     =   float(Val[0])
        elif MatchVal:
            Val     =   MatchVal.groups("HexVal")
            Val     =   float(Val[0])
        else:
            Val     =   0            
    elif isinstance(stVal, int):
        Val         =   float(stVal)
    elif isinstance(stVal, float):
        Val         =   stVal
    else:
        Val         =   0 

    return Val


def ConvStrToCmd(stLine, lCmd):

    for Elem in lCmd:
        if Elem[2] == "Var":
            RegParam    =   re.compile(Elem[0])
            Match       =   RegParam.search(stLine)
            if Match:
                Val     =   Match.groups("Val")
                return (True, Elem[1] + "=" + str(Val[0]), Val[0])
        if Elem[2] == "VarSt":
            RegParam    =   re.compile(Elem[0])
            Match       =   RegParam.search(stLine)
            if Match:
                Val     =   Match.groups("Val")
                return (True, Elem[1] + "=" + Val[0], Val[0])
        if Elem[2] == "VarString":
            RegParam    =   re.compile(Elem[0])
            Match       =   RegParam.search(stLine)
            if Match:
                Val     =   Match.groups("Val")
                return (True, Elem[1] + "=" + "'" + Val + "'", Val[0])                                                   
        if Elem[2] == "Func":
            RegParam    =   re.compile(Elem[0])
            Match       =   RegParam.search(stLine)
            if Match:
                Val     =   Match.groups("Arg")
                return(True, Elem[1] + "(Ret[2])", Val[0])
        if Elem[2] == "FuncSt":
            RegParam    =   re.compile(Elem[0])
            Match       =   RegParam.search(stLine)
            if Match:
                Val     =   Match.groups("Arg")
                return (True, Elem[1] + "(" + Val[0] +")", Val[0] )   
        if Elem[2] == "FuncString":
            RegParam    =   re.compile(Elem[0])
            Match       =   RegParam.search(stLine)
            if Match:
                Val     =   Match.groups("Arg")
                return (True, Elem[1] + "('" + Val[0] +"')", Val[0] ) 
    return (False,)



