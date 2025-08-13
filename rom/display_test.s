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

    LDA #'D'
    JSR DISPLAY_PRINT

    LDA #'A'
    JSR DISPLAY_PRINT

    LDA #'N'
    JSR DISPLAY_PRINT
    JSR DISPLAY_PRINT

    LDA #'Y'
    JSR DISPLAY_PRINT

LOOP:
    JMP LOOP                        ; Infinite loop to keep the program running

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
    AND #$80                        ; Check if the display is busy
    BNE DISPLAY_BUSY                ; If busy, loop back to check again 

    LDA #0 
    STA VIA_PORT_A                  ; Clear port A after reading
    LDA #$FF 
    STA VIA_DDR_B                   ; Set Port B back to output 
    PLA                             ; Pop the stack back to the Accum
    RTS 

.segment "VEC"
.word $0000                         ; Interrupt vector
.word ROM_START                     ; Reset vector
.word $0000                         ; Interrupt vector
