.setcpu "65C02"
.segment "ROM"

via_port_b          = $6000 
via_port_a          = $6001
via_ddr_b           = $6002
via_ddr_a           = $6003
via_tmr_1_low       = $6004 
via_tmr_2_high      = $6005
via_acr             = $600b 
via_pcr             = $600c 
via_ifr             = $600d 
via_ier             = $600e 

ticks = $00
toggle_time = $04
rom:

    lda #$FF 
    sta via_ddr_a 

    lda #0 
    sta via_port_a 
    sta via_acr
    sta toggle_time 
    jsr init_timer 

loop:
    sec 
    lda ticks 
    sbc toggle_time 
    cmp #25 
    bcc loop 
    lda #$01 
    eor via_port_a
    sta via_port_a
    lda ticks 
    sta toggle_time
    jmp loop 

init_timer:
    lda #0 
    sta ticks 
    sta ticks + 1
    sta ticks + 2 
    sta ticks + 3
    lda #$40 
    sta via_acr 
    lda #$0e 
    sta via_tmr_1_low 
    lda #$27 
    sta via_tmr_2_high
    lda #$c0 
    sta via_ier
    cli
    rts 


nmi:
    rti

irq:
    bit via_tmr_1_low 
    inc ticks 
    bne end_irq 
    inc ticks + 1 
    bne end_irq 
    inc ticks + 2 
    bne end_irq 
    inc ticks + 3 
end_irq:
    rti 


.segment "VEC"
.word nmi 
.word rom 
.word irq