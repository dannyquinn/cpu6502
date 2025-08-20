.setcpu "65C02"
.segment "ROM"
; Constants
VIA_PORT_B = $6000                  ; Port B
VIA_PORT_A = $6001                  ; Port A
VIA_DDR_B  = $6002                  ; Data Direction Register for Port B
VIA_DDR_A  = $6003                  ; Data Direction Register for Port A

DISP_EN    = $80                    ; Display Enable bit
DISP_RW    = $40                    ; Read/Write bit
DISP_RS    = $20                    ; Register Select bit

value      = $0200 ; 2 bytes
mod10      = $0202 ; 2 bytes
message    = $0204 ; 6 bytes
counter    = $020A ; 2 bytes

ROM_START:
    LDX #$FF                        ; Set the stack pointer first load X with $FF
    TXS                             ; Transfer X to the stack pointer

    LDA #$FF
    STA VIA_DDR_B                   ; Set all data bits on port B to output
    LDA #$E0                        ; Load accumulator with $E0 (binary 11100000)
    STA VIA_DDR_A                   ; Set upper 3 bits of port A to output

    LDA #$38                        ; Load accumulator with $38 (binary 00111000)
    JSR DISPLAY_COMMAND		        ; Initial the display
    
    LDA #$0E                        ; Load accumulator with $0E (binary 00001110)
    JSR DISPLAY_COMMAND 	        ; Display ON, Cursor ON, Blink OFF

    LDA #06                         ; Load accumulator with $06 (binary 00000110)
    JSR DISPLAY_COMMAND  	        ; Increment cursor, no shift

    LDA #0 
    STA counter 
    STA counter + 1

    CLI

LOOP:
    LDA #02 
    JSR DISPLAY_COMMAND             ; Return to home
    LDA #0 
    STA message 

    LDA counter 
    STA value 
    LDA counter + 1
    STA value + 1

DIVIDE:
    lda #0
    STA mod10 
    STA mod10 + 1 
    CLC
    LDX #16 

DIVLOOP:
    ROL value 
    ROL value + 1 
    ROL mod10 
    ROL mod10 + 1

    SEC 
    LDA mod10 
    SBC #10 
    TAY 
    LDA mod10 + 1
    SBC #0 
    BCC IGNORE_RESULT 
    STY mod10 
    STA mod10 + 1
IGNORE_RESULT: 
    DEX 
    BNE DIVLOOP 
    ROL value
    ROL value + 1
    LDA mod10 
    CLC 

    ADC #'0' 
    JSR PUSH_CHAR

    LDA value 
    ORA value + 1
    BNE DIVIDE


    LDX #0 
PRINT:
    LDA message, x 
    BEQ LOOP 
    JSR DISPLAY_PRINT 
    INX 
    JMP PRINT 

number: .word 1729

PUSH_CHAR:
    PHA 
    LDY #0 

CHAR_LOOP:
    LDA message, y 
    TAX 
    PLA 
    STA message, y 
    INY 
    TXA 
    PHA 
    BNE CHAR_LOOP
    PLA 
    STA message, y

    RTS 
DISPLAY_COMMAND:
    PHA				                ; Push Accum onto the stack 
    JSR DISPLAY_WAIT                ; Wait for display to be ready
    STA VIA_PORT_B                  ; Load the command into port B 

    LDA #0   
    STA VIA_PORT_A                  ; Clear port A to prepare for next command

    LDA #DISP_EN                    ; Set Display Enable
    STA VIA_PORT_A                  ; Send command in port B to display

    LDA #0                          ; Clear accumulator
    STA VIA_PORT_A                  ; Clear port A again
    PLA				                ; Pop the stack back to the Accum
    RTS

DISPLAY_PRINT:
    PHA 			                ; Push Accum onto the stack
    JSR DISPLAY_WAIT                ; Wait for display to be ready
    STA VIA_PORT_B                  ; Load character into port B

    LDA #DISP_RS                    ; Set Register Select for data
    STA VIA_PORT_A      

    LDA #(DISP_RS | DISP_EN)        ; Set Display Enable
    STA VIA_PORT_A                  ; Send character in port B to display

    LDA #0
    STA VIA_PORT_A                  ; Clear port A again
    PLA 			                ; Pop the stack back to the Accum
    RTS

DISPLAY_WAIT: 
    PHA                             ; Push Accum onto the stack
    LDA #$0 
    STA VIA_DDR_B                   ; Set Port B as input to wait for display ready       

DISPLAY_BUSY:
    LDA #DISP_RW 
    STA VIA_PORT_A                  ; Set Read/Write to read mode
    LDA #(DISP_RW | DISP_EN)          
    STA VIA_PORT_A                  ; Enable display for reading
    LDA VIA_PORT_B                  ; Read from Port B (wait for display to be ready)
    AND #$80                        ; Check if the display is busy, MSB is busy flag, 
                                    ; all others are the display address counter
    BNE DISPLAY_BUSY                ; If busy, loop back to check again 

    LDA #0 
    STA VIA_PORT_A                  ; Clear port A after reading
    LDA #$FF 
    STA VIA_DDR_B                   ; Set Port B back to output 
    PLA                             ; Pop the stack back to the Accum
    RTS 

NMI: 
IRQ: 
    INC counter 
    BNE EXIT_IRQ 
    INC counter + 1
EXIT_IRQ:
    RTI


.segment "VEC"
.word NMI                           ; Interrupt vector
.word ROM_START                     ; Reset vector
.word IRQ                           ; Interrupt vector