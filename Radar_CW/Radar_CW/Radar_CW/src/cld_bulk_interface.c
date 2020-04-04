#include "cld_bulk_interface.h"
#include "cld_bf70x_bulk_lib.h"

#include <ADSP-BF707_device.h>



// RX = empty -> init(read) -> waiting(RX interupt) -> full(RX complete interrupt) -> empty(readComplete)
// TX = empty -> waiting(write) -> txdone(TX complete interrupt) -> empty(writeComplete)
typedef enum
{
    BUFFER_STATUS_EMPTY = 0,
    BUFFER_STATUS_INIT,
    BUFFER_STATUS_WAITING,
    BUFFER_STATUS_FULL,
    BUFFER_STATUS_TX_DONE,
} EMG_BUFFER_STATUS;

typedef struct EMG_BUFFER {
							unsigned char 				*buffer;
							unsigned long 				BufferSize;
							CLD_Time					StartTimeStamp;
							EMG_BUFFER_STATUS 			Status;
					      } EMG_BUFFER;

//*******************************************************************************
//*******************************************************************************
//
//   CLD usb stack function prototypes
//
//*******************************************************************************
//*******************************************************************************


/* Function prototypes */

// Event callback - called under USB interrupt (ISR) context
static void user_bulk_usb_event (CLD_USB_Event event);

// CLD console callbacks - Not used
static void user_bulk_console_rx_byte (unsigned char byte);

// RX callbacks
static CLD_USB_Transfer_Request_Return_Type user_bulk_rx_data_received_ISR_callback(CLD_USB_Transfer_Params * p_transfer_data);
static CLD_USB_Data_Received_Return_Type user_bulk_rx_transfer_complete_ISR_callback (void);

// TX callbacks
static void user_bulk_tx_transfer_complete_ISR_callback (void);

// Transfer RX/TX error callbacks
static void user_bulk_device_tx_transfer_error_ISR_callback (void);
static void user_bulk_device_rx_transfer_error_ISR_callback (void);

//*******************************************************************************
//*******************************************************************************
//
//   CLD usb stack configuration structures
//
//*******************************************************************************
//*******************************************************************************

/* Bulk IN endpoint parameters */
static CLD_Bulk_Endpoint_Params user_bulk_in_endpoint_params =
{
    .endpoint_number            = 1,
    .max_packet_size_full_speed = 64,
    .max_packet_size_high_speed = 512,
};

/* Bulk OUT endpoint parameters */
static CLD_Bulk_Endpoint_Params user_bulk_out_endpoint_params =
{
    .endpoint_number            = 1,
    .max_packet_size_full_speed = 64,
    .max_packet_size_high_speed = 512,
};

/* cld_bulk library initialization data. */
static CLD_BF70x_Bulk_Lib_Init_Params user_bulk_init_params =
{
    .timer_num  = CLD_TIMER_0,                          /* Timer used by the CLD Library */
    .uart_num   = CLD_UART_DISABLE,                           /* UART used by the CLD Library.
                                                            If the uart_num is set to
                                                            CLD_UART_MAX the CLD library
                                                            will not use a UART */
    .uart_baud  = 115200,                               /* CLD Library CONSOLE print UART
                                                           baudrate. */
    .sclk0       = 100000000u,                          /* Blackfin SCLK0 frequency */
    .fp_console_rx_byte = user_bulk_console_rx_byte,       /* Function called when a byte
                                                           is received by the CONSOLE
                                                           UART. */
    .vendor_id = 0x064b,                                /* Analog Devices Vendor ID */
    .product_id = 0x7823,                               /* Analog Devices Product ID
                              //                             used by the hostapp program. */

    /* Bulk IN endpoint parameters */
    .p_bulk_in_endpoint_params = &user_bulk_in_endpoint_params,

    /* Bulk OUT endpoint parameters */
    .p_bulk_out_endpoint_params = &user_bulk_out_endpoint_params,

    /* Function called when bulk OUT data has been received. */
    .fp_bulk_out_data_received = user_bulk_rx_data_received_ISR_callback,

    .usb_bus_max_power = 0,                             /* The ADSP-BF707 EZ-Board is
                                                           self-powered (not USB bus-powered) */

    .device_descriptor_bcdDevice = 0x0100,              /* Set USB Device Descriptor
                                                           firmware version to 1.00 */
    /* USB string descriptors - Set to CLD_NULL if not required */
    .p_usb_string_manufacturer  = "Analog Devices Inc",
    .p_usb_string_product       = "BF707 Bulk Device",
    .p_usb_string_serial_number = CLD_NULL,
    .p_usb_string_configuration = CLD_NULL,
    .p_usb_string_interface     = "BF707 Bulk Device",

    .usb_string_language_id     = 0x0409,               /* English (US) language ID */

    /* Function called when one of the following USB events occurs
        CLD_USB_CABLE_CONNECTED      - USB cable connected
        CLD_USB_CABLE_DISCONNECTED   - USB cable disconnected
        CLD_USB_ENUMERATED_CONFIGURED- USB Enumerated (USB Configuration set to non-zero value)
        CLD_USB_UN_CONFIGURED        - USB Configuration set to 0.
        CLD_USB_BUS_RESET            - USB Bus Reset received. */
    .fp_cld_usb_event_callback = user_bulk_usb_event,
};

//*******************************************************************************
//*******************************************************************************
//
//   USB to CLD structures
//
//*******************************************************************************
//*******************************************************************************
static unsigned char CommandBuffer[12];

static EMG_BUFFER EMGBufferRX = {
									.buffer = CommandBuffer,
									.BufferSize = 12,
									.Status = BUFFER_STATUS_EMPTY,
						       };

static EMG_BUFFER EMGBufferTX = {
									.buffer = 0,
									.BufferSize = 0,
									.Status = BUFFER_STATUS_EMPTY,
						       };

static CLD_USB_Transfer_Params tx_transfer_params =
{
	    .callback.fp_usb_in_transfer_complete = user_bulk_tx_transfer_complete_ISR_callback,
	    .fp_transfer_aborted_callback = user_bulk_device_tx_transfer_error_ISR_callback
};


//*******************************************************************************
//*******************************************************************************
//
//   				Private Functions
//
//*******************************************************************************
//*******************************************************************************

static CLD_BULK_INTERFACE_RETURN_CODE usb_writeCompleted( void )
{
	cld_bf70x_bulk_lib_main();

	if( (EMGBufferTX.Status == BUFFER_STATUS_TX_DONE) || (EMGBufferTX.Status == BUFFER_STATUS_EMPTY) )
	{
		EMGBufferTX.Status = BUFFER_STATUS_EMPTY;
		return CLD_BULK_INTERFACE_RETURN_CODE_WRITE_COMPLETE;
	}

	return CLD_BULK_INTERFACE_RETURN_CODE_WRITE_INPROGRESS;
}

/*=============================================================================
Function:       user_bulk_init

Parameters:     None.

Description:    Initializes the CLD Bulk library.

Returns:        USER_BULK_INIT_SUCCESS/USER_BULK_INIT_ONGOING/USER_BULK_INIT_FAILED.
==============================================================================*/
static CLD_BULK_INTERFACE_RETURN_CODE user_bulk_init (void)
{
    static unsigned char user_init_state = 0;
    CLD_RV cld_rv = CLD_ONGOING;

    /* Initalize the CLD Bulk Library */
    cld_rv = cld_bf70x_bulk_lib_init(&user_bulk_init_params);

    if (cld_rv == CLD_SUCCESS)
    {
        /* Connect to the USB Host */
        cld_lib_usb_connect();

        return CLD_BULK_INTERFACE_RETURN_CODE_CONNECTED;
    }
    else if (cld_rv == CLD_FAIL)
    {
        return CLD_BULK_INTERFACE_RETURN_CODE_INIT_FAILED;
    }
    else
    {
        return CLD_BULK_INTERFACE_RETURN_CODE_INIT_ONGOING;
    }
}

//*******************************************************************************
//*******************************************************************************
//
//   						Event callbacks
//
//*******************************************************************************
//*******************************************************************************

/*=============================================================================
Function:       user_bulk_usb_event

Parameters:     event - identifies which USB event has occurred.

Description:    Function Called when a USB event occurs.

Returns:        None.
==============================================================================*/
static void user_bulk_usb_event (CLD_USB_Event event)
{
    switch (event)
    {
        case CLD_USB_CABLE_CONNECTED:
        break;
        case CLD_USB_CABLE_DISCONNECTED:
        break;
        case CLD_USB_ENUMERATED_CONFIGURED:
        break;
        case CLD_USB_UN_CONFIGURED:
        break;
        case CLD_USB_BUS_RESET:
        break;
    }
}


//*******************************************************************************
//*******************************************************************************
//
//   						RX callbacks
//
//*******************************************************************************
//*******************************************************************************


/*=============================================================================
Function:       user_bulk_bulk_out_data_received

Parameters:     p_transfer_data - Pointer to the bulk OUT transfer data.
                    p_transfer_data->num_bytes     - Number of received bulk OUT bytes.
                                                     This value can be set to the total
                                                     transfer size if more then one
                                                     packet is expected.
                    p_transfer_data->p_data_buffer - Set to the address where the
                                                     bulk data should be written.
                    p_transfer_data->callback.usb_out_transfer_complete -
                                                     Function called when the
                                                     requested received bytes have
                                                     been written to p_data_buffer.
                    p_transfer_data->transfer_aborted_callback -
                                                     Optional function that is
                                                     called if the transfer is
                                                     aborted.

Description:    This function is called by the cld_bulk library when data is
                received on the Bulk OUT endpoint. This function sets the
                p_transfer_data parameters to select where the received data
                should be stored, and what function should be called when the
                transfer is complete.

Returns:        CLD_USB_TRANSFER_ACCEPT - Store the bulk data using the p_transfer_data
                                          parameters.
                CLD_USB_TRANSFER_PAUSE - The device isn't ready to process this
                                         bulk out packet so pause the transfer
                                         until the cld_bulk_resume_paused_bulk_out_transfer
                                         function is called.
                CLD_USB_TRANSFER_DISCARD - Discard this bulk packet.
                CLD_USB_TRANSFER_STALL - Stall the bulk OUT endpoint.
==============================================================================*/
static CLD_USB_Transfer_Request_Return_Type user_bulk_rx_data_received_ISR_callback(CLD_USB_Transfer_Params * p_transfer_data)
{
//    if( EMGBufferRX.Status != BUFFER_STATUS_INIT )
//    {
//    	return CLD_USB_TRANSFER_PAUSE;
//    }

    /* Save the received data to the user_bulk_adi_loopback_data.cmd structure,
       and call user_bulk_adi_loopback_cmd_received once the data has been received. */
    p_transfer_data->num_bytes = EMGBufferRX.BufferSize;

    p_transfer_data->p_data_buffer = (unsigned char *)EMGBufferRX.buffer;
    p_transfer_data->callback.fp_usb_out_transfer_complete = user_bulk_rx_transfer_complete_ISR_callback;
    p_transfer_data->fp_transfer_aborted_callback = user_bulk_device_rx_transfer_error_ISR_callback;
    EMGBufferRX.Status = BUFFER_STATUS_WAITING;

    return CLD_USB_TRANSFER_ACCEPT;
}


/*=============================================================================
Function:       user_bulk_rx_transfer_complete_ISR_callback

Parameters:     None.

Description:    Called after USB ISR copies data from FIFO to buffer

Returns:        CLD_USB_Data_Received_Return_Type
==============================================================================*/
static CLD_USB_Data_Received_Return_Type user_bulk_rx_transfer_complete_ISR_callback (void)
{
	EMGBufferRX.Status = BUFFER_STATUS_FULL;
	return CLD_USB_DATA_GOOD;
}

//*******************************************************************************
//*******************************************************************************
//
//   						TX callbacks
//
//*******************************************************************************
//*******************************************************************************

static void user_bulk_tx_transfer_complete_ISR_callback( void )
{
	EMGBufferTX.Status = BUFFER_STATUS_TX_DONE;
}

//*******************************************************************************
//*******************************************************************************
//
// 					Error callback
//
//*******************************************************************************
//*******************************************************************************

/*=============================================================================
Function:       user_bulk_adi_loopback_device_transfer_error

Parameters:     None.

Description:    This function is called if a requested transfer is aborted.

Returns:        None.
==============================================================================*/
static void user_bulk_device_rx_transfer_error_ISR_callback (void)
{
	EMGBufferRX.Status = BUFFER_STATUS_FULL;
}

static void user_bulk_device_tx_transfer_error_ISR_callback (void)
{
	EMGBufferTX.Status = BUFFER_STATUS_TX_DONE;
}


//*******************************************************************************
//*******************************************************************************
// NOT USED		NOT USED	NOT USED	NOT USED	NOT USED	NOT USED
//*******************************************************************************
//*******************************************************************************


/*=============================================================================
Function:       user_bulk_console_rx_byte

Parameters:

Description:

Returns:
==============================================================================*/
static void user_bulk_console_rx_byte (unsigned char byte)
{

}


//*******************************************************************************
//*******************************************************************************
//
// 					User API
//
//*******************************************************************************
//*******************************************************************************

/*=============================================================================
Function:       bulk_usb_wait_for_command( void )

Parameters:		none

Description:	Blocking call. Waits for a command from the PC host before sending data

Returns:		void
==============================================================================*/
void bulk_usb_wait_for_command( void )
{
	while( EMGBufferRX.Status != BUFFER_STATUS_FULL )
		cld_bf70x_bulk_lib_main();

	EMGBufferRX.Status != BUFFER_STATUS_INIT;
}


/*=============================================================================
Function:       bulk_usb_init( void )

Parameters:		none

Description:	Blocking call. Blocks until plugged into USB host.

Returns:		CLD_BULK_INTERFACE_RETURN_CODE
==============================================================================*/
CLD_BULK_INTERFACE_RETURN_CODE bulk_usb_init( unsigned long MyObjectSizeInBytes )
{
	unsigned long DelayTheory;

	/* Enable and Configure the SEC. */
	/* sec_gctl - unlock the global lock  */
	pADI_SEC0->GCTL &= ~BITM_SEC_GCTL_LOCK;
	/* sec_gctl - enable the SEC in */
	pADI_SEC0->GCTL |= BITM_SEC_GCTL_EN;
	/* sec_cctl[n] - unlock */
	pADI_SEC0->CB.CCTL &= ~BITM_SEC_CCTL_LOCK;
	/* sec_cctl[n] - reset sci to default */
	pADI_SEC0->CB.CCTL |= BITM_SEC_CCTL_RESET;
	/* sec_cctl[n] - enable interrupt to be sent to core */
	pADI_SEC0->CB.CCTL = BITM_SEC_CCTL_EN;

	while( user_bulk_init() != CLD_BULK_INTERFACE_RETURN_CODE_CONNECTED );

    for( DelayTheory = 1000; DelayTheory>0; --DelayTheory)
    	cld_bf70x_bulk_lib_main();

    bulk_usb_wait_for_command();

	return CLD_BULK_INTERFACE_RETURN_CODE_CONNECTED;
}


/*=============================================================================
Function:       bulk_usb_write( void *MyObject, unsigned long MyObjectSizeInBytes )

Parameters:		MyObject - Pointer to buffer to be transmitted
				MyObjectSizeInBytes - Size of buffer in bytes

Description:	Non-Blocking call.

Returns:		CLD_BULK_INTERFACE_RETURN_CODE
==============================================================================*/
CLD_BULK_INTERFACE_RETURN_CODE bulk_usb_write_nonblock( void *MyObject, unsigned long MyObjectSizeInBytes )
{
	CLD_USB_Data_Transmit_Return_Type RValue;
	volatile unsigned long DelayTheory;

	// Block until data is received
	while( usb_writeCompleted( ) == CLD_BULK_INTERFACE_RETURN_CODE_WRITE_INPROGRESS ){}

#if 1					// Delay required to eliminate babble
    // Test delay theory
    for( DelayTheory = 100; DelayTheory>0; --DelayTheory)
    	cld_bf70x_bulk_lib_main();
#endif

    tx_transfer_params.num_bytes = MyObjectSizeInBytes;
    tx_transfer_params.p_data_buffer = (unsigned char*)MyObject;

    EMGBufferTX.Status = BUFFER_STATUS_WAITING;

    RValue = cld_bf70x_bulk_lib_transmit_bulk_in_data(&tx_transfer_params);
    if( RValue == CLD_USB_TRANSMIT_FAILED )
    	return CLD_BULK_INTERFACE_RETURN_CODE_WRITE_ERROR;

    return CLD_BULK_INTERFACE_RETURN_CODE_SUCCESS;
}


/*=============================================================================
Function:       bulk_usb_write( void *MyObject, unsigned long MyObjectSizeInBytes )

Parameters:		MyObject - Pointer to buffer to be transmitted
				MyObjectSizeInBytes - Size of buffer in bytes

Description:	Blocking call. Blocks until plugged into USB host.

Returns:		CLD_BULK_INTERFACE_RETURN_CODE
==============================================================================*/
CLD_BULK_INTERFACE_RETURN_CODE bulk_usb_write_block( void *MyObject, unsigned long MyObjectSizeInBytes )
{
	CLD_USB_Data_Transmit_Return_Type RValue;
	volatile unsigned long DelayTheory;

//	// Block until previous data is completed
	while( usb_writeCompleted( ) == CLD_BULK_INTERFACE_RETURN_CODE_WRITE_INPROGRESS ){}

#if 1					// Delay required to eliminate babble
    // Test delay theory
    for( DelayTheory = 100; DelayTheory>0; --DelayTheory)
    	cld_bf70x_bulk_lib_main();
#endif

    tx_transfer_params.num_bytes = MyObjectSizeInBytes;
    tx_transfer_params.p_data_buffer = (unsigned char*)MyObject;

    EMGBufferTX.Status = BUFFER_STATUS_WAITING;

    RValue = cld_bf70x_bulk_lib_transmit_bulk_in_data(&tx_transfer_params);
    if( RValue == CLD_USB_TRANSMIT_FAILED )
    	return CLD_BULK_INTERFACE_RETURN_CODE_WRITE_ERROR;

//	// Block until data is received
	while( usb_writeCompleted( ) == CLD_BULK_INTERFACE_RETURN_CODE_WRITE_INPROGRESS ){}

    return CLD_BULK_INTERFACE_RETURN_CODE_SUCCESS;
}







