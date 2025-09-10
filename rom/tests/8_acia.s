; Test RS232 -> MAX232 -> ACIA chip 
;

.setcpu "65C02"
.segment "ROM"

io_portb            = $8000     ; 8 bit bi directional port 
io_porta            = $8001     ; 8 bit bi directional port
io_ddrb             = $8002     ; portb direction register
io_ddra             = $8003     ; porta direction register
disp_en             = $40       ; display enable bit
disp_rw             = $20       ; read/write bit
disp_rs             = $10       ; register select bit

acia_data = $8080
acia_status = $8081 
acia_cmd = $8082 
acia_ctl = $8083 

rom:
    ldx #$ff 
    txs 

    
    lda #$ff
    sta io_ddrb 
    lda #$bf 
    sta io_ddra 

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
    sta acia_status 
    lda #$1f                    ; N-8-1 19200 
    sta acia_ctl 
    lda #$0b                    ; no parity, no echo, no interupts
    sta acia_cmd

rx_wait:
    lda acia_status
    and #$08 
    beq rx_wait 

    lda acia_data 
    jsr display_print 
    jmp rx_wait



display_wait: 
    pha 
    lda #$f0
    sta io_ddrb 

display_busy:
    lda #disp_rw 
    sta io_portb 
    ora #disp_en 
    sta io_portb 
    lda io_portb 
    pha 
    lda #disp_rw 
    sta io_portb 
    ora #disp_en 
    sta io_portb 
    lda io_portb 
    pla 
    and #$08 
    bne display_busy 
    lda #disp_rw 
    sta io_portb 
    lda #$ff 
    sta io_ddrb 
    pla 
    rts 

display_print: 
    jsr display_wait 
    pha 
    lsr
    lsr
    lsr
    lsr
    ora #disp_rs 
    sta io_portb 
    ora #disp_en 
    sta io_portb 
    eor #disp_en 
    sta io_portb 
    pla 
    and #$0f 
    ora #disp_rs 
    sta io_portb 
    ora #disp_en 
    sta io_portb 
    eor #disp_en 
    sta io_portb 
    rts

init_display: 
    lda #$02                    ; four bit mode 
    sta io_portb 

    ora #disp_en                ; send the command 
    sta io_portb 

    and $0f                     ; turn off the enable
    sta io_portb

    rts


display_command: 
    jsr display_wait 
    pha 
    lsr
    lsr
    lsr
    lsr
    sta io_portb 
    ora #disp_en 
    sta io_portb 
    eor #disp_en 
    sta io_portb 
    pla 
    and #$0f 
    sta io_portb 
    ora #disp_en 
    sta io_portb 
    eor #disp_en 
    sta io_portb
    rts 

.segment "VEC"
.word $0000 
.word rom 
.word $0000