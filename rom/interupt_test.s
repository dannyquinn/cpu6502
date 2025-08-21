.setcpu "65C02"
.segment "ROM"

; IO Addresses 
via_port_b          = $6000             ; 8 bit in/out port b
via_port_a          = $6001             ; 8 bit in/out port a
via_ddr_b           = $6002             ; port b data direction register 
via_ddr_a           = $6003             ; port a data direction register
via_pcr             = $600c             ; peripheral control register 
via_ifr             = $600d             ; interupt flags register
via_ier             = $600e             ; interupt enable register

; Display Control Flags 
disp_enable         = $80               ; display enable bit 
disp_rw             = $40               ; read/write bit
disp_rs             = $20               ; register select bit

; Variables 

value               = $0200             ; 2 bytes 
mod10               = $0202             ; 2 bytes 
message             = $0204             ; 6 bytes 
counter             = $020A             ; 8 bytes

rom: 
    ldx #$FF                            ; set the stack pointer start to 01FF 
    txs                                 ; transfer x to stack pointer

    ; setup ports for display module 
    lda #$FF                            ; set all port b pins to output 
    sta via_ddr_b                   
    lda #$E0                            ; set the top 3 bits on port a to output 
    sta via_ddr_a 

    ; initialise display module 
    lda #$38                            ; Initialise display 
    jsr display_command 

    lda #$0E                            ; Display on, cursor on, blink off 
    jsr display_command 

    lda #$06                            ; increment cursor, no shift 
    jsr display_command 

    lda #$01                            ; ensure display is cleared
    jsr display_command 

    ; initialise variables 
    lda #0 
    sta counter                         ; set counter (2 bytes) to zero
    sta counter + 1

    ; interupts 
    lda #$82                             ; enable CA1 interupt on via 
    sta via_ier 

    lda #0                              ; clear peripheral control register 
    sta via_pcr                         ; 2nd bit = 0 sets CA1 to neg-edge trigger 

    cli                                 ; enable processor interupt 

loop: 
    lda #$02                            ; move cursor back to top of display
    jsr display_command

    lda #0 
    sta message                         ; clear message variable 

    lda counter
    sta value                           ; get lower part of counter and store in lower part of value 
    lda counter + 1 
    sta value + 1                       ; get upper part of counter and store in upper part of value 

divide: 
    lda #0                              ; clear modulus variable 
    sta mod10 
    sta mod10 + 1 
    clc                                 ; clear carry flag 
    ldx #16                             ; set x with iteration count 

divloop: 
    rol value                           ; rotate values in value and mod10
    rol value + 1 
    rol mod10 
    rol mod10 + 1

    sec                                 ; set carry flag 
    lda mod10 
    sbc #10                             ; subtract 10 from the lower part of mode10
    tay                                 ; move accumulator into register y 
    lda mod10 + 1                       ; put the upper part of mod10 into the accumulator 
    sbc #0                              ; subtract 0 from the upper part of mod10
    bcc ignore_result 
    sty mod10                           ; if carry flag still set then mod10 divides by ten
    sta mod10 + 1                       ; store the result in Y & A 
ignore_result:
    dex                                 ; decrement loop counter 
    bne divloop                         
    rol value                           ; final rotate to compete this cycle
    rol value + 1

    lda mod10                           ; get the remainder 
    clc                                 ; clear the carry flag 

    adc #'0'                            ; add 0 to the accumulator to get character code 
    jsr push_char 

    lda value 
    ora value + 1                       ; if any bits are set then we are not finished 
    bne divide 

    ldx #0                              ; set offset value 
print: 
    lda message, x                      ; get the charactor at offset x 
    beq loop                            ; null terminator, jump back to start 
    jsr display_print 
    inx                                 ; increment offset
    jmp print 

push_char: 
    ; push char adds new character to the front of string 
    ; moving all other characters to the right.
    pha                                 ; accumulator contains character to insert 
    ldy #0
char_loop:
    ; this swaps the character on the stack with the one at message, y 
    lda message, y                      ; get the first character in message 
    tax                                 ; transfer to x register 
    pla                                 ; get character back from stack 
    sta message, y                      ; put character into the message 
    iny 
    txa 
    pha                                 ; push character onto stack 
    bne char_loop                       ; keeping going until we see the null terminator 
    pla                                 ; pull the null back from the stack
    sta message, y                      ; and add to the end of the string 
    rts 

display_print: 
    pha                                 ; push accumulator to stack 
    jsr display_wait                    ; wait for display to be ready 
    sta via_port_b                      ; send character to port b 

    lda #disp_rs                        ; set rs to inform the display we are sending a character
    sta via_port_a          

    lda #(disp_rs | disp_enable)        ; set enable to allow display to read char on port b 
    sta via_port_a 

    lda #0                              ; done, clear the flags on port a 
    sta via_port_a 

    pla                                 ; restore accumulator 
    rts 


display_command:
    ; takes value from the accumulator 
    ; and loads the value into the display 
    ; module as a configuration command 

    pha                                 ; push a to the stack so the fuction is non destructive
    jsr display_wait                    ; wait until the display is ready to accept a command 

    sta via_port_b                      ; move the command onto port b 

    lda #0                              ; clear the display command flags 
    sta via_port_a 

    lda #disp_enable                    ; set the enable flag, allowing display to read value in port b 
    sta via_port_a      

    lda #0                              ; remove the enable flag. 
    sta via_port_a 

    pla                                 ; pull accumulator back from the stack before returning
    rts 

display_wait: 
    pha                                 ; push accumulator on to the stack 
    lda #0                              ; set port b pins as input 
    sta via_port_b                      ; this enables reading the display status 

display_busy: 
    lda #disp_rw                        ; set the display for read mode 
    sta via_port_a 

    lda #(disp_rw | disp_enable)        ; add the enable flag to start the read 
    sta via_port_a          

    lda via_port_b                      ; transfer the display status into accumulator 
    and #80                             ; msb contains ready flag.
    bne display_busy 

    lda #0                              ; set the display back to write mode 
    sta via_port_a 

    lda #$FF                            ; set port b pins back to output
    sta via_ddr_b 

    pla                                 ; restore accumulator from the stack 
    rts 

nmi:
irq:
    inc counter                         ; increment counter by 1
    bne exit_interupt                   ; if counter > 0 then ignore next line 
    inc counter + 1                     ; counter rolled back to 0 so increment counter+1
exit_interupt:
    bit via_port_a                      ; acknowledge interupt 
    rti 

.segment "VEC"
.word nmi                               ; non maskable interupt
.word rom                               ; program start 
.word irq                               ; interupt
