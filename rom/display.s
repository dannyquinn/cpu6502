.include "constant.s" 

display_init:
    pha 
    lda #$ff 
    sta io_ddrb 

    lda #$02                    ; four bit mode 
    sta io_portb 

    ora #disp_en                ; send the command 
    sta io_portb 

    and #$0f                    ; turn off the enable
    sta io_portb

    lda #$28                    ; set 4 bit mode, 2 line display, 5x8 font 
    jsr display_command 

    lda #$0e                    ; display on, cursor off 
    jsr display_command 

    lda #$06                    ; increment and shift cursor 
    jsr display_command         

    lda #$01                    ; clear display 
    jsr display_command 

    pla
    rts 

display_command: 
    pha
    jsr display_wait 
    pha 
    lsr
    lsr
    lsr
    lsr
    sta io_portb 
    ora #disp_en 
    sta io_portb 
    eor #disp_en 
    sta io_portb 
    pla 
    and #$0f 
    sta io_portb 
    ora #disp_en 
    sta io_portb 
    eor #disp_en 
    sta io_portb
    pla
    rts 

display_print: 
    pha
    jsr display_wait 
    pha 
    lsr
    lsr
    lsr
    lsr
    ora #disp_rs 
    sta io_portb 
    ora #disp_en 
    sta io_portb 
    eor #disp_en 
    sta io_portb 
    pla 
    and #$0f 
    ora #disp_rs 
    sta io_portb 
    ora #disp_en 
    sta io_portb 
    eor #disp_en 
    sta io_portb 
    pla
    rts

display_wait: 
    pha 
    lda #$f0
    sta io_ddrb 

display_busy:
    lda #disp_rw 
    sta io_portb 
    ora #disp_en 
    sta io_portb 
    lda io_portb 
    pha 
    lda #disp_rw 
    sta io_portb 
    ora #disp_en 
    sta io_portb 
    lda io_portb 
    pla 
    and #$08 
    bne display_busy 
    lda #disp_rw 
    sta io_portb 
    lda #$ff 
    sta io_ddrb 
    pla 
    rts 
