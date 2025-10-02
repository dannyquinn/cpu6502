.setcpu "65C02"
.segment "ROM"

; IO Addresses 

IO_PORTB            = $8000     ; 8 bit bi directional port 
IO_PORTA            = $8001     ; 8 bit bi directional port
IO_DDRB             = $8002     ; portb direction register
IO_DDRA             = $8003     ; porta direction register
IO_T1_LOW           = $8004     ; timer 1 low 
IO_T1_HIGH          = $8005     ; timer 1 high
IO_ACR              = $800b     ; aux register control
IO_PCR              = $800c     ; peripheral control register
IO_IFR              = $800d     ; interupt flags register
IO_IER              = $800e     ; interupt enable register


; Display control flags 
DIST_EN             = $80       ; display enable bit
DISP_RW             = $40       ; read/write bit
DIST_RS             = $20       ; register select bit

; Variables 
ticks               = $0200     ; 4 bytes 
ticks_threshold     = $0204     ; 1 byte

rom:
    ldx #$ff                    ; set stack top
    txs

    lda #01                     ; set lsb of port a to output
    sta IO_DDRA 

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
    eor IO_PORTA                ; flip lsb of porta
    sta IO_PORTA 
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
    sta IO_ACR

    lda #$c0                    ; enable timer 1 interupts 
    sta IO_IER

    lda #$0e                    ; set timer to 10ms 
    sta IO_T1_LOW 
    lda #$27                    
    sta IO_T1_HIGH              ; timer starts once this instruction completes 
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
    bit IO_T1_LOW              ; reset the interupt
    rti

.segment "VEC"
.word nmi 
.word rom 
.word irq
