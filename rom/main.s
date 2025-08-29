.setcpu "65C02"
.segment "ROM"

; IO Addresses 

io_portb            = $8000     ; 8 bit bi directional port 
io_porta            = $8001     ; 8 bit bi directional port
io_ddrb             = $8002     ; portb direction register
io_ddra             = $8003     ; porta direction register
io_pcr              = $800c     ; peripheral control register
io_ifr              = $800d     ; interupt flags register
io_ier              = $800e     ; interupt enable register

; Display control flags 
disp_en             = $80       ; display enable bit
disp_rw             = $40       ; read/write bit
disp_rs             = $20       ; register select bit

; Variables 


rom:
    ldx #$ff
    txs

    ; placeholder to the bios code.
    
loop:
    jmp loop

nmi:
    rti 
irq:
    rti

.segment "VEC"
.word nmi 
.word rom 
.word irq
