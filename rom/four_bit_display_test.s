.setcpu "65C02"
.segment "ROM"

; Constants 

via_port_b          = $6000
via_port_a          = $6001
via_ddr_b           = $6002
via_ddr_a           = $6003

disp_enable         = $40
disp_rw             = $20
disp_rs             = $10

rom: 
    ldx #$ff                ; set stack top
    txs 

    lda #$ff                ; set all pins on via port B to output
    sta via_ddr_b 

    jsr display_init

    lda #$28                ; set 4-bit mode, 2 line display; 5x8 font 
    jsr display_command 

    lda #$0E                ; display on, cursor off, 5x8 font 
    jsr display_command 
    
    lda #$06                ; increment and shift cursor, dont shift display
    jsr display_command 

    lda #$01                ; clear display 
    jsr display_command 

    ldx #0 
print:
    lda message, x 
    beq loop 
    jsr display_print 
    inx 
    jmp print 

loop:
    jmp loop


message: .asciiz "Danny's Computer"

display_init:
    lda #$02                ; set 4 bit mode 
    sta via_port_b 

    ora #disp_enable        ; set the enable high
    sta via_port_b 

    and $0F                 ; clear control nibble
    sta via_port_b 
    rts 

display_command:
    jsr display_wait
    pha 
    lsr 
    lsr
    lsr
    lsr                     ; send 4 high bits 
    sta via_port_b 
    ora #disp_enable 
    sta via_port_b 
    eor #disp_enable
    sta via_port_b 
    pla 
    and #$0F                ; send low bits 
    sta via_port_b 
    ora #disp_enable
    sta via_port_b 
    eor #disp_enable
    sta via_port_b 
    rts 

display_print:
    jsr display_wait 
    pha 
    lsr
    lsr 
    lsr 
    lsr 
    ora #disp_rs 
    sta via_port_b 
    ora #disp_enable 
    sta via_port_b 
    eor #disp_enable 
    sta via_port_b 
    pla 
    and #$0F 
    ora #disp_rs 
    sta via_port_b 
    ora #disp_enable 
    sta via_port_b 
    eor #disp_enable 
    sta via_port_b 
    rts 

display_wait:
    pha 
    lda #$F0                ; set data nibble to input 
    sta via_ddr_b 

display_busy:
    lda #disp_rw 
    sta via_port_b 
    ora #disp_enable 
    sta via_port_b 
    lda via_port_b          
    pha 
    lda #disp_rw 
    sta via_port_b 
    ora #disp_enable
    sta via_port_b 
    lda via_port_b
    pla 
    and #$08 
    bne display_busy

    lda #disp_rw 
    sta via_port_b 
    lda #$ff 
    sta via_ddr_b 
    pla 
    rts 

.segment "VEC"
.word $0000
.word rom 
.word $0000
