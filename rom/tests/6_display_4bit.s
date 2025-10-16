.setcpu "65C02"
.segment "rom"

IO_PORTB            = $8000     ; 8 bit bi directional port 
IO_DDRB             = $8002     ; portb direction register
; Display control flags 
DISP_EN             = $40       ; display enable bit
DISP_RW             = $20       ; read/write bit
DISP_RS             = $10       ; register select bit

rom:
    ldx #$ff                    ; set stack top
    txs

    ; for this to work the following 
    ; pin mapping needs to be used 
    ;
    ; display               interface adapter 
    ; ---------------------------------------
    ; d4                    pb0
    ; d5                    pb1
    ; d6                    pb2 
    ; d7                    pb3
    ; rs                    pb4
    ; rw                    pb5
    ; e                     pb6

    lda #$ff                    ; Port B output 
    sta IO_DDRB 

    jsr init_display            ; initialise the display 

    lda #$28                    ; set 4 bit mode, 2 line display, 5x8 font 
    jsr display_command 

    lda #$0e                    ; display on, cursor off 
    jsr display_command 

    lda #$06                    ; increment and shift cursor 
    jsr display_command         

    lda #$01                    ; clear display 
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

message: .asciiz "4 Bit Test"

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

.segment "vec"
.word $0000 
.word rom 
.word $0000
