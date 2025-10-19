.setcpu "65C02"
.segment "rom"
.include "constant.s"
; Test program only here to see if I can call the 
; code from wozmon
run_test:
    ldy #0 
@sendloop:
    lda message, y 
    iny
    jsr chrout 
    bne @sendloop 

halt:
    jmp halt

message: .asciiz "Test Message"

.include "bios.s"
.include "wozmon.s"

.segment "vec"
.word $0000 
.word wozman 
.word $0000
