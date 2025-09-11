;

.ifndef io_porta
; Interface Adapter 
io_portb                = $8000
io_porta                = $8001
io_ddrb                 = $8002
io_ddra                 = $8003

; Display flags 
disp_en                 = $40
disp_rw                 = $20 
disp_rs                 = $10

.endif
