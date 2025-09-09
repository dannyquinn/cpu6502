; Test running the display module in 4 bit mode 
;
; I was not expecting this to work, in early tests
; the display would get itself in a bad state and 
; not initialise properly. 
; 
; I have not been able to reproduce this, the screen 
; works perfectly, regardless of how many times I 
; reset the cpu. 
;
; Might revisit, if the problem comes back later.

.setcpu "65C02"
.segment "ROM"


; IO Addresses 

io_portb            = $8000     ; 8 bit bi directional port 
io_ddrb             = $8002     ; portb direction register
; Display control flags 
disp_en             = $40       ; display enable bit
disp_rw             = $20       ; read/write bit
disp_rs             = $10       ; register select bit

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
    sta io_ddrb 

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

.segment "VEC"
.word $0000 
.word rom 
.word $0000
