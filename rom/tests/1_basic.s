.setcpu "65C02"
.segment "ROM"

IO_PORTB                = $8000 
IO_DDRB                 = $8002

rom: 
    lda #$ff 
    sta IO_DDRB

    lda #$01 

loop:
    sta IO_PORTB
    ror 
    jmp loop

.segment "VEC"
.word $0000 
.word rom 
.word $0000