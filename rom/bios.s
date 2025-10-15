.include "constant.s" 

chrin:
    lda ACIA_STATUS 
    and #08             ; char in buffer?
    beq @no_keypressed 
    lda ACIA_DATA 
    jsr chrout          ; echo
    sec 
    rts 
@no_keypressed:
    clc 
    rts

chrout:
    pha 
    sta ACIA_DATA
    lda #$ff 
@txdelay:
    dec
    bne @txdelay
    pla
    rts

