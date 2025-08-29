; Test display module in 8-bit mode 
;
; Prints a simple message to the display.

.setcpu "65C02"
.segment "ROM"
; Constants 
port_b          = $8000
port_a          = $8001
ddr_b           = $8002
ddr_a           = $8003

disp_en         = $80
disp_rw         = $40
disp_rs         = $20

rom:
    ldx #$ff                ; set the stack pointer 
    txs 

    lda #$ff                ; set all data bits on port b to output
    sta ddr_b 

    lda #$e0                ; set top 3 bits on port a to output 
    sta ddr_a 

    lda #$38                ; Initialise display 
    jsr display_command 

    lda #$0e                ; Display on, cursor on, blink off 
    jsr display_command 

    lda #$06                ; increment cursor, no shift
    jsr display_command 

    lda #$01                ; ensure display is cleared
    jsr display_command 

    ldx #0
print:
    lda message, x
    beq loop                ; end of message
    jsr display_print
    inx
    jmp print

loop:
    jmp loop

display_command:
    pha 
    jsr display_wait
    sta port_b                              ; push command to port b 
    lda #0
    sta port_a 
    ora #disp_en                            ; send the command 
    sta port_a 
    eor #disp_en   
    sta port_a                              ; turn enable back off 
    pla 
    rts 

display_print:
    pha                                     ; push accumulator to stack
    jsr display_wait                        ; wait for display to be ready 
    sta port_b                              ; send char to port b
    
    lda #disp_rs                            ; set rs for char mode 
    sta port_a 

    ora #disp_en                            ; send the character 
    sta port_a

    lda #0                                  ; turn enable back off 
    sta port_a 

    pla 
    rts 

display_wait: 
    pha 
    lda #0                                  ; set port b pins as input 
    sta ddr_b 

display_busy:
    lda #disp_rw                            ; set display for read mode 
    sta port_a 

    ora #disp_en                            ; send the read command 
    sta port_a 

    lda port_b 
    and #$80                                ; check busy flag 
    bne display_busy 

    lda #0                                  ; set back to write mode 
    sta port_a 

    lda #$ff                                ; set port b pins back to output 
    sta ddr_b 

    pla 
    rts 

message: .asciiz "Danny's Computer"

.segment "VEC"
.word $0000
.word rom 
.word $0000


