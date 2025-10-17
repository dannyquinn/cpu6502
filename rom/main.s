.setcpu "65C02"
.segment "rom"
.include "constant.s"
.include "bios.s"
rom:
.include "wozmon.s"

.segment "vec"
.word $0000 
.word wozman 
.word $0000
