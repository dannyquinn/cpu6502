; Basic 6502 test program 
; Using the monitor program watch the instructions execute 
; on each clock cycle.  This script confirms that the cpu 
; is able to receive instructions from the ROM and pass 
; instructions to the VIA.

.setcpu "65C02"
.segment "ROM"

ROM_START:
    LDA #$FF        ; Load accumulator with $FF
    STA $6002       ; Set all data bits on port B to output 

    LDA #$01        ; Load 1 into the accumulator 

LOOP: 
    STA $6000       ; Send value to port B 
    ROR             ; Rotate right through carry
    JMP LOOP        ; Jump back to LOOP

.segment "VEC"
.word $0000         ; Interupt vector 
.word ROM_START     ; Reset vector
.word $0000         ; Interupt vector 
