; Same as the basic_test.s script, but this introduces 
; a subroutine to test that the ram chip is working correctly.
; 
; Calling a subroutine will push the return address onto the stack
; and this is popped off when the subroutine returns. 

.setcpu "65C02"
.segment "ROM"

ROM_START:
    LDX #$FF        ; Set the stackpointer first load X with $FF 
    TXS             ; Transfer X to the stack pointer

    LDA #$FF        ; Load accumulator with $FF
    STA $6002       ; Set all data bits on port B to output

    LDA #$01        ; Load 1 into the accumulator

LOOP:
    JSR STACK_TEST  ; Call the stack test subroutine
    JMP LOOP        ; Jump back to LOOP

STACK_TEST: 
    STA $6000       ; Send value to port B
    ROR             ; Rotate right through carry
    RTS             ; Return from subroutine

.segment "VEC"
.word $0000         ; Interrupt vector
.word ROM_START     ; Reset vector
.word $0000         ; Interrupt vector