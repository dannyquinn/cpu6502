.setcpu "65C02"
.segment "rom"

IO_PORTB            = $8000
IO_PORTA            = $8001
IO_DDRB             = $8002
IO_DDRA             = $8003

DISP_EN             = $80
DISP_RW             = $40
DISP_RS             = $20

rom:
    ldx #$ff                ; set the stack pointer 
    txs 

    lda #$ff                ; set all data bits on port b to output
    sta IO_DDRB 

    lda #$e0                ; set top 3 bits on port a to output 
    sta IO_DDRA 

    lda #$38                ; Initialise display 
    jsr display_command 

    lda #$0e                ; Display on, cursor on, blink off 
    jsr display_command 

    lda #$06                ; increment cursor, no shift
    jsr display_command 

    lda #$01                ; ensure display is cleared
    jsr display_command 

    ldx #0
print:
    lda message, x
    beq loop                ; end of message
    jsr display_print
    inx
    jmp print

loop:
    jmp loop

display_command:
    pha 
    jsr display_wait
    sta IO_PORTB            ; push command to port b 
    lda #0
    sta IO_PORTA
    ora #DISP_EN            ; send the command 
    sta IO_PORTA 
    eor #DISP_EN   
    sta IO_PORTA            ; turn enable back off 
    pla 
    rts 

display_print:
    pha                     ; push accumulator to stack
    jsr display_wait        ; wait for display to be ready 
    sta IO_PORTB            ; send char to port b
    
    lda #DISP_RS            ; set rs for char mode 
    sta IO_PORTA

    ora #DISP_EN            ; send the character 
    sta IO_PORTA

    lda #0                  ; turn enable back off 
    sta IO_PORTA 

    pla 
    rts 

display_wait: 
    pha 
    lda #0                  ; set port b pins as input 
    sta IO_DDRB

display_busy:
    lda #DISP_RW            ; set display for read mode 
    sta IO_PORTA 

    ora #DISP_EN            ; send the read command 
    sta IO_PORTA 

    lda IO_PORTB
    and #$80                ; check busy flag 
    bne display_busy 

    lda #0                  ; set back to write mode 
    sta IO_PORTA 

    lda #$ff                ; set port b pins back to output 
    sta IO_DDRB 

    pla 
    rts 

message: .asciiz "Danny's Computer"

.segment "vec"
.word $0000
.word rom 
.word $0000
