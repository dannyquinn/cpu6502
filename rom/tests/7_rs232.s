.setcpu "65C02"
.segment "ROM"

IO_PORTB            = $8000     ; 8 bit bi directional port 
IO_PORTA            = $8001     ; 8 bit bi directional port
IO_DDRB             = $8002     ; portb direction register
IO_DDRA             = $8003     ; porta direction register
DISP_EN             = $40       ; display enable bit
DISP_RW             = $20       ; read/write bit
DISP_RS             = $10       ; register select bit

ACIA_DATA           = $8010
ACIA_STATUS         = $8011 
ACIA_CMD            = $8012 
ACIA_CTL            = $8013 

rom:
    ldx #$ff 
    txs 

    
    lda #$ff
    sta IO_DDRB
    lda #$bf 
    sta IO_DDRA

    jsr init_display            ; initialise the display 

    lda #$28                    ; set 4 bit mode, 2 line display, 5x8 font 
    jsr display_command 

    lda #$0e                    ; display on, cursor off 
    jsr display_command 

    lda #$06                    ; increment and shift cursor 
    jsr display_command         

    lda #$01                    ; clear display 
    jsr display_command 

    lda #1 
    sta IO_PORTA
    lda #'*'
    sta $0200 

    lda #$01 
    trb IO_PORTA

    ldx #8 
write_bit:
    jsr bit_delay 
    ror $0200 
    bcs send_1 
    trb IO_PORTA
    jmp tx_done 
send_1:
    tsb IO_PORTA
tx_done:
    dex 
    bne write_bit 
    jsr bit_delay
    tsb IO_PORTA
    jsr bit_delay

rx_wait:
    bit IO_PORTA
    bvs rx_wait 

    jsr half_bit_delay 

    ldx #8 
read_bit:
    jsr bit_delay 
    bit IO_PORTA
    bvs recv_1 
    clc 
    jmp rx_done 
recv_1: 
    sec 
rx_done: 
    ror 
    dex 
    bne read_bit 
    jsr display_print 
    jmp rx_wait 

bit_delay: 
    phx 
    ldx #13 
bit_delay_1:
    dex 
    bne bit_delay_1

    plx 
    rts 

half_bit_delay: 
    phx 
    ldx #6
half_bit_delay_1:
    dex 
    bne half_bit_delay_1

    plx 
    rts 

display_wait: 
    pha 
    lda #$f0
    sta IO_DDRB

display_busy:
    lda #DISP_RW
    sta IO_PORTB
    ora #DISP_EN
    sta IO_PORTB
    lda IO_PORTB
    pha 
    lda #DISP_RW
    sta IO_PORTB
    ora #DISP_EN
    sta IO_PORTB
    lda IO_PORTB
    pla 
    and #$08 
    bne display_busy 
    lda #DISP_RW 
    sta IO_PORTB 
    lda #$ff 
    sta IO_DDRB 
    pla 
    rts 

display_print: 
    jsr display_wait 
    pha 
    lsr
    lsr
    lsr
    lsr
    ora #DISP_RS
    sta IO_PORTB
    ora #DISP_EN
    sta IO_PORTB
    eor #DISP_EN
    sta IO_PORTB
    pla 
    and #$0f 
    ora #DISP_RS
    sta IO_PORTB
    ora #DISP_EN
    sta IO_PORTB
    eor #DISP_EN
    sta IO_PORTB 
    rts

init_display: 
    lda #$02                    ; four bit mode 
    sta IO_PORTB

    ora #DISP_EN                ; send the command 
    sta IO_PORTB 

    and $0f                     ; turn off the enable
    sta IO_PORTB

    rts


display_command: 
    jsr display_wait 
    pha 
    lsr
    lsr
    lsr
    lsr
    sta IO_PORTB
    ora #DISP_EN
    sta IO_PORTB
    eor #DISP_EN
    sta IO_PORTB
    pla 
    and #$0f 
    sta IO_PORTB
    ora #DISP_EN 
    sta IO_PORTB 
    eor #DISP_EN 
    sta IO_PORTB
    rts 

.segment "VEC"
.word $0000 
.word rom 
.word $0000