### Assembly code for eprom

/rom

#### Manual Steps

- ca65 source.s 
- ld65 -C mem.cfg source.o 
- hexdump -C a.out 
- minipro -p AT28C256 -w a.out 

#### Make

**make** - compile, link and display file content 

**make write** - compile, link and send output to programmer 

to target a file other than main.s use... 

**make write f=tests/1_basic.s**

/rom/tests - contains simple assembly programs that allow each part of the circuitry to be tested as it's being put together.

### Ardiuno bus monitor 

/src

Used to view the contents of the data & address buses along with the cpu r/w flag on each clock pulse.

### RS232 

minicom -b 9600 -D /dev/ttyUSB0 

### Links 

Assembler / Linker - https://cc65.github.io

Rom Flash - https://gitlab.com/DavidGriffith/minipro