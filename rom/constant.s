;

.ifndef IO_PORTA
; Interface Adapter Addresses  
IO_PORTB                = $8000
IO_PORTA                = $8001
IO_DDRB                 = $8002
IO_DDRA                 = $8003
IO_T1C_L                = $8004
IO_T1C-H                = $8005
IO_T1L-L                = $8006
IO_T1L-H                = $8007
IO-T2C-L                = $8008
IO-T2C-H                = $8009 
IO_SR                   = $800a
IO_ACR                  = $800b
IO_PCR                  = $800c 
IO_IFR                  = $800d
IO_IER                  = $800e
IO_ORA                  = $800f

; Display flags 
DISP_EN                 = $40
DISP_RW                 = $20 
DISP_RS                 = $10

; ACIA Addresses 
ACIA_DATA               = $8010
ACIA_STATUS             = $8011
ACIA_COMMAND            = $8012
ACIA_CONTROL            = $8013

.endif
