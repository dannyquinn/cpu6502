; Tests creating a continuous timer of 10ms 
; and then using that timer to blink an led 
; connects to pin 1 or port b, every second

.setcpu "65C02"
.segment "ROM"

; IO Addresses 

io_portb            = $8000     ; 8 bit bi directional port 
io_porta            = $8001     ; 8 bit bi directional port
io_ddrb             = $8002     ; portb direction register
io_ddra             = $8003     ; porta direction register
io_t1_low           = $8004     ; timer 1 low 
io_t1_high          = $8005     ; timer 1 high
io_acr              = $800b     ; aux register control
io_pcr              = $800c     ; peripheral control register
io_ifr              = $800d     ; interupt flags register
io_ier              = $800e     ; interupt enable register


; Display control flags 
disp_en             = $80       ; display enable bit
disp_rw             = $40       ; read/write bit
disp_rs             = $20       ; register select bit

; Variables 
ticks               = $0200       ; 4 bytes 
ticks_threshold     = $0204       ; 1 byte

rom:
    ldx #$ff                    ; set stack top
    txs

    lda #01                     ; set lsb of port a to output
    sta io_ddra 

    lda #0                      ; reset toggle_threshold
    sta ticks_threshold 

    jsr init_timer              ; initialise the timer

loop:
    jsr update                  
    jmp loop


update:
    sec
    lda ticks                   ; get the low bytes of ticks 
    sbc ticks_threshold         ; subtract the ticks threshold
    cmp #25                     ; elaped >=250ms 
    bcc exit_update             ; nothing to do 
    lda #$01
    eor io_porta                ; flip lsb of porta
    sta io_porta 
    lda ticks 
    sta ticks_threshold 
exit_update:
    rts 
    
init_timer:
    cli                         ; clear interupt inhibit 

    lda #0                      ; init ticks variable 
    sta ticks 
    sta ticks + 1
    sta ticks + 2
    sta ticks + 3 

    lda #$40                    ; set timer to continuous interupt 
    sta io_acr 

    lda #$c0                    ; enable timer 1 interupts 
    sta io_ier

    lda #$0e                    ; set timer to 10ms 
    sta io_t1_low 
    lda #$27                    
    sta io_t1_high              ; timer starts once this instruction completes 
    rts

nmi:
    rti 
irq:
    inc ticks                   ; increment counter
    bne end_irq 
    inc ticks + 1
    bne end_irq 
    inc ticks + 2
    bne end_irq 
    inc ticks + 3 
end_irq:
    bit io_t1_low               ; reset the interupt
    rti

.segment "VEC"
.word nmi 
.word rom 
.word irq
