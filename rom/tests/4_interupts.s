.setcpu "65C02"
.segment "ROM"

; IO Addresses 
port_b                  = $8000             ; 8 bit in/out port b 
port_a                  = $8001             ; 8 bit in/out port a
ddr_b                   = $8002             ; port b data direction register 
ddr_a                   = $8003             ; port a data direction register
pcr                     = $800c             ; peripheral control register
ifr                     = $800d             ; interupt flags register
ier                     = $800e             ; interupt enable register

; Display control flags 
disp_en                 = $80               ; display enable bit
disp_rw                 = $40               ; read/write bit 
disp_rs                 = $20               ; register select 

; Variables 
value                   = $0200             ; 2 bytes 
mod10                   = $0202             ; 2 bytes 
message                 = $0204             ; 6 bytes 
counter                 = $020A             ; 2 bytes

rom:
    ldx #$ff                                ; set the stack pointer
    txs 

    lda #$ff                                ; set output on port b
    sta ddr_b 

    lda #$e0                                ; set top 3 output on port a
    sta ddr_a

    lda #$38                                ; init display module 
    jsr display_command 

    lda #$0e                                ; Display on, cursor on, blink off 
    jsr display_command 

    lda #$06                                ; increment cursor, no shift 
    jsr display_command 

    lda #$01                                ; clear display
    jsr display_command

    lda #0
    sta counter 
    sta counter + 1

    lda #$82                                ; enable ca 1 interupt 
    sta ier 

    lda #0                                  ; clear peripheral control register 
    sta pcr

    cli                                     ; enable processor interupt

loop:
    lda #$02                                ; move cursor back to top of display 
    jsr display_command 

    lda #0                                  ; clear message variable
    sta message

    lda counter                             ; copy counter into value
    sta value 
    lda counter + 1
    sta value + 1

divide:
    lda #0
    sta mod10                               ; set mod10 to 0
    sta mod10 + 1
    clc                                     ; clear carry flag 
    ldx #16                                 ; set x with iteration count 

divloop:
    rol value                               ; rotate values 
    rol value + 1
    rol mod10 
    rol mod10 + 1

    sec                                     ; set carry flag 
    lda mod10 
    sbc #10                                 ; subtract 10 from the lower part of mod10
    tay 
    lda mod10 + 1
    sbc #0                                  ; substract the upper half 
    bcc ignore_result                       ; if carry flag not set then 10 donsn't divide mod10 
    sty mod10
    sta mod10 + 1 
ignore_result:
    dex                                     ; reduce loop counter 
    bne divloop 
    rol value                               ; rotate ready for next cycle
    rol value + 1
    lda mod10                               
    clc                     
    adc #'0'                                ; add 0 character to turn number into character code 
    jsr push_char 
    lda value 
    ora value + 1                           ; any bits set then loop
    bne divide 

    ldx #0 
print:
    lda message, x 
    beq loop                                ; end of message 
    jsr display_print 
    inx 
    jmp print 

push_char: 
    ; add character at the start of the string 
    pha 
    ldy #0 
char_loop:
    lda message, y                          ; get the first character in message 
    tax                                     ; transfer to x register 
    pla                                     ; get character back from stack
    sta message, y                          ; put character into the message 
    iny 
    txa 
    pha                                     ; push character onto stack 
    bne char_loop                           ; keeping going until we see the null terminator 
    pla                                     ; pull the null back from the stack
    sta message, y                          ; and add to the end of the string 
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

display_wait: 
    pha 
    lda #0                                  ; set port b pins as input 
    sta port_b 

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

nmi:
irq:
    inc counter 
    bne exit_interupt 
    inc counter + 1
exit_interupt:
    bit port_a                              ; acknowledge interupt 
    rti 

.segment "VEC"
.word nmi 
.word rom 
.word irq 





