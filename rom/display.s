.include "constant.s" 
.macro sdd 
    ora #DISP_EN 
    sta IO_PORTB 
    eor #DISP_EN 
    sta IO_PORTB 
.endmacro

display_init:
    pha 
    lda #$ff 
    sta IO_DDRB

    lda #$02                    ; four bit mode 
    sta IO_PORTB 

    ora #DISP_EN                ; send the command 
    sta IO_PORTB 

    and #$0f                    ; turn off the enable
    sta IO_PORTB

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
    sta IO_PORTB 
    sdd  
    pla 
    and #$0f 
    sta IO_PORTB
    sdd
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
    ora #DISP_RS 
    sta IO_PORTB
    sdd 
    pla 
    and #$0f 
    ora #DISP_RS 
    sta IO_PORTB 
    sdd
    pla
    rts

display_wait: 
    pha 
    lda #$f0
    sta IO_DDRB 

display_busy:
    lda #DISP_RW
    sta IO_PORTB 
    ora #DISP_EN
    sta IO_PORTB
    lda IO_PORTB 
    pha 
    lda #DISP_RW 
    sta IO_PORTB 
    ora #DISP_EN 
    sta IO_PORTB 
    lda IO_PORTB 
    pla 
    and #$08 
    bne display_busy 
    lda #DISP_RW 
    sta IO_PORTB 
    lda #$ff 
    sta IO_DDRB 
    pla 
    rts 
