.setcpu "65C02"
.segment "ROM"
.include "constant.s"
.include "bios.s"
.include "display.s"


ptr = $00                   ; 2 bytes 

rom:
    ldx #$ff
    txs                     ; set stack pointer

    jsr display_init        ; initialise display

    lda #$00
    sta ACIA_STATUS         ; initialise acia 
    lda #$1f 
    sta ACIA_CONTROL        ; N81 19200
    lda #$0b 
    sta ACIA_COMMAND        ; no echo, no cache

    lda #<clearscreen       ; load pointer to clearscreen to ptr 
    sta ptr 
    lda #>clearscreen
    sta ptr+1 

    lda #clearscreenend - clearscreen 
    tax                     ; length of bytes 
    lda #0
    tay 
@reset_terminal:
    lda (ptr), y
    jsr chrout 
    iny
    dex 
    bne @reset_terminal 

rx_wait: 
    jsr chrin 
    bcc rx_wait 
    cmp #$0d                ; cr pressed?
    beq cr 
    jsr display_print       ; print char to lcd
    jmp rx_wait

cr: 
    lda #$01                ; clear lcd
    jsr display_command 

    lda #$0d 
    jsr chrout              ; send cr 
    lda #$0a 
    jsr chrout              ; send lf
    jmp rx_wait 

clearscreen:
    ; clears connected terminal, moves cursor back to the top and 
    ; prints ready
    .byte $1B, $5B, $32, $4A, $1B, $5B, $48, $52, $45, $41, $44, $59, $0D, $0A
clearscreenend:

nmi:                        ; non maskable interupt
    rti 
irq:
    rti                     ; interupt

.segment "VEC"
.word nmi 
.word rom 
.word irq
