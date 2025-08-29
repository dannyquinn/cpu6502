; Basic 6502 test program 
; Using the monitor program watch the instructions execute 
; on each clock cycle.  This script confirms that the cpu 
; is able to receive instructions from the ROM and pass 
; instructions to the VIA.

.setcpu "65C02"
.segment "ROM"

rom: 
    lda #$ff 
    sta $8002

    lda #$01 

loop:
    sta $8000
    ror 
    jmp loop

.segment "VEC"
.word $0000 
.word rom 
.word $0000