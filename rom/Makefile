f ?= main.s
w ?= 0

ifeq ($(suffix $(f)),.s)
	ifeq ($(wildcard $(f)),)
		$(error Source file $(f) does not exist)
	endif
else
	$(error Source file must end with .s)
endif

OBJECT_FILE := asm.o

all: a.out hexdump_output write_rom clean

$(OBJECT_FILE): $(f)
	@echo "Assembling $<"
	ca65 $< -o $@

a.out: $(OBJECT_FILE)
	@echo "Linking $@"
	ld65 -C mem.cfg $(OBJECT_FILE) -o a.out

.PHONY: hexdump_output
hexdump_output: a.out
	@echo "Generating hexdump..."
	hexdump -C a.out

.PHONY: write_rom
write_rom: a.out
ifeq ($(w), 1)
	@echo "Writing a.out to ROM chip..."
	minipro -p AT28C256 -w a.out
endif

default: all

.PHONY: clean
clean:
	@echo "Cleaning up..."
	rm -f $(OBJECT_FILE) a.out