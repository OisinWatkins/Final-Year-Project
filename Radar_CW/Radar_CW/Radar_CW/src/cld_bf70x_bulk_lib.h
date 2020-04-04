
/*==============================================================================
    FILE:           cld_bf70x_bulk_lib.h

    DESCRIPTION:    CLD BF70x Bulk peripheral Library.

    Copyright (c) 2015 Closed Loop Design, LLC

    This software is supplied "AS IS" without any warranties, express, implied
    or statutory, including but not limited to the implied warranties of fitness
    for purpose, satisfactory quality and non-infringement. Closed Loop Design LLC
    extends you a royalty-free right to reproduce and distribute executable files
    created using this software for use on Analog Devices Blackfin family
    processors only. Nothing else gives you the right to use this software.

==============================================================================*/

#ifndef __CLD_BF70X_BULK_LIB__
#define __CLD_BF70X_BULK_LIB__

#ifndef CLD_NULL
#define CLD_NULL    0
#endif

#ifdef _LANGUAGE_C

/* CLD Timer numbers used to select which of the BF707 timers is used by the
   CLD library. */
typedef enum
{
    CLD_TIMER_0 = 1,
    CLD_TIMER_1,
    CLD_TIMER_2,
    CLD_TIMER_3,
    CLD_TIMER_4,
    CLD_TIMER_5,
    CLD_TIMER_6,
    CLD_TIMER_7,
    CLD_TIMER_MAX
} CLD_Timer_Num;

typedef unsigned long CLD_Time;

/* CLD UART numbers used to select which of the BF707 UARTs is used by the
   CLD library. */
typedef enum
{
    CLD_UART_0 = 1,
    CLD_UART_1 = 2,
    CLD_UART_DISABLE,
} CLD_Uart_Num;

/* CLD Library return codes. */
typedef enum
{
    CLD_SUCCESS = 0,
    CLD_FAIL = 1,
    CLD_ONGOING = 2
} CLD_RV;

/* CLD Library USB Events */
typedef enum
{
    CLD_USB_CABLE_CONNECTED = 0,
    CLD_USB_CABLE_DISCONNECTED,
    CLD_USB_ENUMERATED_CONFIGURED,
    CLD_USB_UN_CONFIGURED,
    CLD_USB_BUS_RESET,
} CLD_USB_Event;

/* Value returned by the User code to select how the requested transfer should
   be handled. */
typedef enum
{
    CLD_USB_TRANSFER_ACCEPT = 0,                        /* Accept the requested transfer using
                                                           the supplied CLD_USB_Transfer_Params. */
    CLD_USB_TRANSFER_PAUSE,                             /* Pause the current transfer. The USB
                                                           endpoint will be Nak'ed until the
                                                           appropriate 'resume' function is
                                                           called. This is used to throttle
                                                           the USB host. */
    CLD_USB_TRANSFER_DISCARD,                           /* Discard the transfer. For OUT requests
                                                           the received data is discarded. For IN
                                                           requests the device will return a
                                                           zero length packet. */
    CLD_USB_TRANSFER_STALL,                             /* Stall the transfer request. */
} CLD_USB_Transfer_Request_Return_Type;

/* Value returned by the User code to notify the USB library if the received data
   was valid. */
typedef enum
{
    CLD_USB_DATA_GOOD = 0,                              /* Received data is good.
                                                           For Control OUT requests this
                                                           allows the Status Stage to
                                                           complete. */
    CLD_USB_DATA_BAD_STALL,                             /* Received data is bad so stall the endpoint
                                                           For Control OUT requests this
                                                           stalls the Status Stage, for
                                                           other endpoint types the
                                                           next OUT packet will be stalled. */
} CLD_USB_Data_Received_Return_Type;

/* Value returned by the USB library to notify the User code if the requested data
   can be transmitted. */
typedef enum
{
    CLD_USB_TRANSMIT_SUCCESSFUL = 0,
    CLD_USB_TRANSMIT_FAILED,
} CLD_USB_Data_Transmit_Return_Type;

/* USB transfer request parameters used to tell the USB library how to handle the
   current transfer. */
typedef struct
{
    unsigned long num_bytes;                            /* The number of bytes to
                                                           transmit or receive depending
                                                           on the transfer direction (IN/OUT) */
    unsigned char * p_data_buffer;                      /* Pointer to the data to transmit
                                                           (IN Transfer) or a pointer to
                                                           the buffer to store the received
                                                           data (OUT transfer). */

    /* The following function pointers are used by the USB Library to notify the
       User code when certain events occur.  These function pointers can be set
       to NULL if the User does not want to be notified. */
    union
    {                                                   /* Function called when the data
                                                           has been received. */
        CLD_USB_Data_Received_Return_Type (*fp_usb_out_transfer_complete)(void);
        void (*fp_usb_in_transfer_complete) (void);     /* Function called when the requested
                                                           data has been transmitted. */
    }callback;
    void (*fp_transfer_aborted_callback) (void);        /* Function called if the requested
                                                           transfer is aborted. */
    CLD_Time transfer_timeout_ms;                       /* Transfer Timeout in milliseconds
                                                           (0 - Disables the timeout) */
} CLD_USB_Transfer_Params;

/* Parameters used to configure the Bulk endpoints. */
typedef struct
{
    unsigned char endpoint_number;
    unsigned short max_packet_size_full_speed;          /* Full-Speed max packet size */
    unsigned short max_packet_size_high_speed;          /* High-Speed max packet size */
} CLD_Bulk_Endpoint_Params;

typedef struct
{
    CLD_Timer_Num timer_num;                            /* Timer used by the CLD Library */
    CLD_Uart_Num uart_num;                              /* UART used by the CLD Library.
                                                            If the uart_num is set to
                                                            CLD_UART_DISABLE the CLD library
                                                            will not use a UART */
    unsigned long uart_baud;                            /* CLD Library CONSOLE print UART
                                                           baudrate. */
    unsigned long sclk0;                                /* Blackfin SCLK0 frequency */
    void (*fp_console_rx_byte) (unsigned char byte);    /* Function called when a byte
                                                           is received by the CONSOLE
                                                           UART. */

    unsigned short vendor_id;                           /* USB Vendor ID */
    unsigned short product_id;                          /* USB Product ID */

    /* Pointer to the endpoint parameters for the Bulk IN endpoint. */
    CLD_Bulk_Endpoint_Params * p_bulk_in_endpoint_params;

    /* Pointer to the endpoint parameters for the Bulk OUT endpoint. */
    CLD_Bulk_Endpoint_Params * p_bulk_out_endpoint_params;
    /* This function is called when the data is received on the Bulk OUT
       endpoint.
        If this function returns an error it causes the next Bulk OUT packet to be stalled. */
    CLD_USB_Transfer_Request_Return_Type (*fp_bulk_out_data_received) (CLD_USB_Transfer_Params * p_transfer_data);

    unsigned char usb_bus_max_power;                    /* USB Configuration Descriptor
                                                           bMaxPower value (0 = self powered).
                                                           See USB 2.0 Section 9.6.3. */

    unsigned short device_descriptor_bcdDevice;         /* USB Device Descriptor bcdDevice
                                                           value. See USB 2.0 section 9.6.1. */
    /* USB string descriptors - Set to NULL if not required */
    const char * p_usb_string_manufacturer;
    const char * p_usb_string_product;
    const char * p_usb_string_serial_number;
    const char * p_usb_string_configuration;
    const char * p_usb_string_interface;

    unsigned short usb_string_language_id;              /* USB String Descriptor Language ID code
                                                           (0x0409 = English US). */

    /* Function called when one of the following USB events occurs
        CLD_USB_CABLE_CONNECTED      - USB cable connected
        CLD_USB_CABLE_DISCONNECTED   - USB cable disconnected
        CLD_USB_ENUMERATED_CONFIGURED- USB Enumerated (USB Configuration set to non-zero value)
        CLD_USB_UN_CONFIGURED        - USB Configuration set to 0.
        CLD_USB_BUS_RESET            - USB Bus Reset received. */
    void (*fp_cld_usb_event_callback) (CLD_USB_Event event);
} CLD_BF70x_Bulk_Lib_Init_Params;


/* Timer functions used to measure time in milliseconds. */
extern CLD_Time cld_time_get(void);
extern CLD_Time cld_time_passed_ms(CLD_Time time);


/* Initializes the CLD Bulk library. This function needs to be called until
   CLD_SUCCESS or CLD_FAIL is returned.  If CLD_FAIL is returned there was a
   problem initializing the library, and any relevant error messages will be
   output using the cld_console UART. */
extern CLD_RV cld_bf70x_bulk_lib_init (CLD_BF70x_Bulk_Lib_Init_Params * cld_bf70x_bulk_lib_params);
/* CLD Bulk library mainline function. The CLD library mainline function is
   required and should be called in each iteration of the main program loop. */
extern void cld_bf70x_bulk_lib_main (void);

/* Function used to transmit data using the Bulk IN endpoint. */
extern CLD_USB_Data_Transmit_Return_Type cld_bf70x_bulk_lib_transmit_bulk_in_data (CLD_USB_Transfer_Params * p_transfer_data);

/* Function used to resume a paused Bulk OUT transfer. When this function is called
   the fp_bulk_out_data_received function will be called with the CLD_USB_Transfer_Params
   of the paused transfer.  The fp_bulk_out_data_received can then
   accept, discard or stall the previously paused transfer. */
extern void cld_bf70x_bulk_lib_resume_paused_bulk_out_transfer (void);

/* Connects to the USB Host. */
extern void cld_lib_usb_connect (void);
/* Disconnects from the USB Host. */
extern void cld_lib_usb_disconnect (void);

typedef enum
{
    CLD_CONSOLE_BLACK  = 0,
    CLD_CONSOLE_RED       ,
    CLD_CONSOLE_GREEN     ,
    CLD_CONSOLE_YELLOW    ,
    CLD_CONSOLE_BLUE      ,
    CLD_CONSOLE_PURPLE    ,
    CLD_CONSOLE_CYAN      ,
    CLD_CONSOLE_WHITE     ,
    CLD_CONSOLE_NUM_COLORS,
} CLD_CONSOLE_COLOR;

/* cld_console is similar in format to printf, and also natively supports
    setting a foreground and background color.

   For example the following will output 'The quick brown fox' on a black background with green text:
       cld_console(CLD_CONSOLE_GREEN, CLD_CONSOLE_BLACK, "The quick brown %s\n\r", "fox");

    cld_console returns CLD_SUCCESS if the requested message has been accepted
    and will be transmit using the console UART. CLD_FAIL is returned if the
    requested message will not be transmitted.
*/
extern CLD_RV cld_console(CLD_CONSOLE_COLOR foreground_color, CLD_CONSOLE_COLOR background_color, const char *fmt, ...);

#endif /* _LANGUAGE_C */

#endif  /* __CLD_BF70X_BULK_LIB__ */
