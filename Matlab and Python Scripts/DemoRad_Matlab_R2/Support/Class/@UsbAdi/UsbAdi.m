%< @file        UsbAdi.m                                                                                                                 
%< @date        2017-07-18          
%< @brief       Matlab class for interface to DemoRadUsb Mex file
%< @version     1.1.0

classdef UsbAdi<handle

    properties (Access = public)
        
		UsbOpen     	=   0;
        UsbDrvVers  	=   [];
		stUsbAdiVers 	= 	'1.1.0';
    end

    methods (Access = public)

        function obj  =   UsbAdi() 
            obj.UsbOpen         =   0;
        end

        function    delete(obj)
			% TODO: close does not work properly
            if obj.UsbOpen > 0
                obj.UsbOpen     =   0;
                DemoRadUsb('Close');
            end
        end

        function    TxData  =   CmdBuild(obj, Ack, CmdCod, Data)
            LenData         =   numel(Data) + 1;
            TxData          =   zeros(LenData,1);
            TxData(1)       =   (2.^24)*Ack + (2.^16)*LenData + CmdCod;
            TxData(2:end)   =   Data(:);
            TxData          =   uint32(TxData);
        end 

        function    Ret     =   CmdSend(obj, Ack, Cod, Data)
            if obj.UsbOpen == 0
                obj.UsbOpen         =   DemoRadUsb('Open');
                if obj.UsbOpen == 0
                    disp('Usb open failed');
                end
            end
            Cmd             =   obj.CmdBuild(Ack, Cod, Data);
            Ret             =   DemoRadUsb('WriteCmd', Cmd);
            if Ret == 0
                disp('Cmd Write failed')
            end 
        end 

        function    Ret     =   CmdExec(obj, Ack, Cod, Data)
            if obj.UsbOpen == 0
                obj.UsbOpen         =   DemoRadUsb('Open');
                if obj.UsbOpen == 0
                    disp('Usb open failed');
                end
            end
            Cmd             =   obj.CmdBuild(Ack, Cod, Data);
            Ret             =   DemoRadUsb('ExecCmd', Cmd);
        end         
        
        function    Ret     =   CmdReadData(obj, Ack, Cod, Data)
            Cmd             =   obj.CmdBuild(Ack, Cod, Data);
            Ret             =   DemoRadUsb('GetData', Cmd);
            Len             =   numel(Ret);
            Ret             =   reshape(Ret,4,Len/4);
            Ret             =   Ret.';            
        end   
        
        function    Ret     =   DataSend(obj, Data)
            Ret             =   DemoRadUsb('WriteCmd', Data);
            if Ret == 0
                disp('Data Write failed')
            end 
        end 

        function    Ret     =   DataRead(obj, Len)
            Ret             =   DemoRadUsb('ReadI16', int32(Len));
            Len             =   numel(Ret);
            Ret             =   reshape(Ret,4,Len/4);
            Ret             =   Ret.';
        end 

        function    Ret     = CmdRecv(obj)
            pause(0.001);
            Ret     = DemoRadUsb('Read', int32(4));
            if numel(Ret) > 0
                Header      =   Ret(1);
                LenRxData   =   floor(Header/(2.^16));                
                Ret         =   DemoRadUsb('Read',int32((LenRxData - 1)*4));
            else
                disp('Board Not Responding')
                Ret         =   [];
            end
        end
    end 
end