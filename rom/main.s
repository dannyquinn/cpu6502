.setcpu "65C02"
.segment "rom"
.include "constant.s"
rom:
.include "wozmon.s"

.segment "vec"
.word $0000 
.word rom 
.word $0000
