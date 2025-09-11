.setcpu "65C02"
.segment "ROM"
.include "constant.s"
.include "display.s"

rom:
    ldx #$ff
    txs

    jsr display_init 

    ldx #0 
print:
    lda message, x
    beq loop                ; end of message
    jsr display_print
    inx
    jmp print

    
loop:
    jmp loop

message: .asciiz "4 Bit Test"

nmi:
    rti 
irq:
    rti

.segment "VEC"
.word nmi 
.word rom 
.word irq
