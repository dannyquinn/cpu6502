; 6502 Stack test program 
; This is pretty much the same test as 1_basic.s 
; however it introduces a subroutine and therefore
; requires the ram chip to be installed correctly.
; (stack uses the ram chip)

.setcpu "65C02"
.segment "ROM"

rom:
    lda #$ff 
    sta $8002 

    lda #$01

loop:
    jsr send_to_port 
    ror 
    jmp loop 

send_to_port:
    sta $8000
    rts 

.segment "VEC"
.word $0000
.word rom 
.word $0000