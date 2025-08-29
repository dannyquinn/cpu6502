### Assembly code for eprom

/rom

#### Manual Steps

- ca65 source.s 
- ld65 -C mem.cfg source.o 
- hexdump -C a.out 
- minipro -p AT28C256 -w a.out 

#### Make

Execute ca65, ld65 & hexdump 

- make f=\<filename\>       

Execute ca65, ld65 & minipro

- make f=\<filename\> w=1  

/rom/tests - contains simple assembly programs that allow each part of the circuitry to be tested as it's being put together.

### Ardiuno bus monitor 

/src

Used to view the contents of the data & address buses along with the cpu r/w flag on each clock pulse.


### Links 

Assembler / Linker - https://cc65.github.io

Rom Flash - https://gitlab.com/DavidGriffith/minipro