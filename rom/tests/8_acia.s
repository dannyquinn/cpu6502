.setcpu "65C02"

.segment "rom"

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

ptr                 = $00       ; 2 bytes 


rom:
    ldx #$ff                    
    txs                         ; set stack pointer

    
    lda #$ff
    sta IO_DDRB                 ; set portb pins as output

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
    sta ACIA_STATUS             ; Initialise the uart
    lda #$1f                    
    sta ACIA_CTL                ; N-8-1 19200 
    lda #$0b                    
    sta ACIA_CMD                ; no parity, no echo, no interupts


    lda #<clearscreen 
    sta ptr 

    lda #>clearscreen 
    sta ptr+1

    lda #clearscreenend - clearscreen
    tax 
    lda #0 
    tay 

reset_terminal:                 
    lda (ptr), y                
    jsr send_char 
    iny 
    dex 
    bne reset_terminal

rx_wait:
    lda ACIA_STATUS
    and #$08 
    beq rx_wait 

    lda ACIA_DATA
    cmp #$0D 
    beq cr                      ; user presses cr
    jsr send_char
    jsr display_print 
    
    jmp rx_wait

cr: 
    lda #$01                    ; clear lcd display 
    jsr display_command 

    lda #$0D                    ; send cr and lf back
    jsr send_char

    lda #$0A 
    jsr send_char 
    jmp rx_wait

send_char: 
    pha 
    sta ACIA_DATA 
    jsr tx_delay 
    pla
    rts 

tx_delay:
    phx 
    ldx #100
tx_delay_1: 
    dex 
    bne tx_delay_1 
    plx 
    rts 

clearscreen:
    ; clears connected terminal, moves cursor back to the top and 
    ; prints ready
    .byte $1B, $5B, $32, $4A, $1B, $5B, $48, $52, $45, $41, $44, $59, $0D, $0A
clearscreenend:

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

.segment "vec"
.word $0000 
.word rom 
.word $0000