.include "constant.s" 
.segment "bios"

chrin:
    lda ACIA_STATUS 
    and #08             ; char in buffer?
    beq @no_keypressed 
    lda ACIA_DATA 
    ;//jsr chrout          ; echo
    sec 
    rts 
@no_keypressed:
    clc 
    rts

chrout:
    pha                 ; Save A.

     sta ACIA_DATA       ; Output character.
     lda #$ff            ; Initialize delay loop.
 @txdelay:        
     dec                 ; Decrement A.
     bne @txdelay        ; Until A gets to 0.
     pla                 ; Restore A.
     cmp #$0d           ; Fix this it's horrible
     beq @send_lf
     rts                 ; Return.

@send_lf: 
    pha 
    lda #$0a 
    sta ACIA_DATA 
    lda #$ff 
txdelay2:
    dec 
    bne txdelay2 
    pla 
    rts

clear: 
    lda #$1b 
    jsr chrout
    lda #$5b 
    jsr chrout
    lda #$32 
    jsr chrout
    lda #$4a 
    jsr chrout
    lda #$1b 
    jsr chrout
    lda #$5b 
    jsr chrout
    lda #$48 
    jsr chrout
    rts 
;     cmp #$0d            ; custom code for cr+lf 
;     bne @normal_char 

;     pha                 ; save accumulator
;     lda #$0d 
;     jsr @send_byte      ; send cr 
;     lda #$0a 
;     jsr @send_byte      ; send lf 
;     pla 
;     rts 
    
; @normal_char:
;     pha                 ; save accumulator
; @send_byte:
;     sta ACIA_DATA 
;     lda #$ff 
; @txdelay:
;     dec 
;     bne @txdelay 
;     pla                 ; restore accumulator 
;     rts 