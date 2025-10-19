.include "constant.s" 
.segment "bios"

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
    cmp #$0d            ; CR 
    bne @notcr          ; if not CR then send and return
    jsr @sendchar 
    lda #$0a            ; send LF after CR 
@notcr: 
    jsr @sendchar 
    pla 
    rts 

@sendchar: 
    sta ACIA_DATA       ; send character to uart 
    lda #$ff 
@txdelay:               ; wait for completion
    dec                 
    bne @txdelay 
    rts 

clear: 
    phx 
    pha
    ldx #0 
@clearloop:
    lda clearscreen, x  ; load each byte of clearscreen in turn
    sta ACIA_DATA 
    lda #$ff 
@txdelay:
    dec 
    bne @txdelay
    inx 
    cpx #7 
    bne @clearloop 
    pla 
    plx 
    rts 

clearscreen: .byte $1b, $5b, $32, $4a, $1b, $5b, $48



