.setcpu "65C02"
.segment "ROM"

IO_PORTB                = $8000
IO_DDRB                 = $8002

rom:
    lda #$ff 
    sta IO_DDRB

    lda #$01

loop:
    jsr send_to_port 
    ror 
    jmp loop 

send_to_port:
    sta IO_PORTB
    rts 

.segment "VEC"
.word $0000
.word rom 
.word $0000