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

    lda #$00 
    sta ACIA_STATUS
    lda #$1f                    ; N-8-1 19200 
    sta ACIA_CTL
    lda #$0b                    ; no parity, no echo, no interupts
    sta ACIA_CMD

rx_wait:
    lda ACIA_STATUS
    and #$08 
    beq rx_wait 

    lda ACIA_DATA
    jsr display_print 
    jmp rx_wait



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