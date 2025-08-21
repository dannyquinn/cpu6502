f ?=
w ?= 0

ifeq ($(wildcard $(f).s),)
$(error Source file $(f).s does not exist)
endif

all: a.out hexdump_output write_rom clean

%.o: %.s
	@echo "Assembling $<"
	ca65 "$<"

a.out: $(f).o
	@echo "Linking $@"
	ld65 -C mem.cfg "$<"

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
	rm -f $(f).o a.out