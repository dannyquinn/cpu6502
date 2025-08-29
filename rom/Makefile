f ?= main.s

OBJECT_FILE := asm.o
EXECUTABLE := a.out

.PHONY: all hexdump_output write default

all: $(EXECUTABLE) hexdump_output clean

$(OBJECT_FILE):
	@echo "Assembling $(f)"
	ca65 $(f) -o $@

$(EXECUTABLE): $(OBJECT_FILE)
	@echo "Linking $@"
	ld65 -C mem.cfg $(OBJECT_FILE) -o $(EXECUTABLE)

hexdump_output: $(EXECUTABLE)
	@echo "Generating hexdump..."
	hexdump -C $(EXECUTABLE)

write: $(EXECUTABLE)
	@echo "Writing $(EXECUTABLE) to ROM chip..."
	minipro -p AT28C256 -w $(EXECUTABLE)

default: all

clean:
	@echo "Cleaning up..."
	rm -f $(OBJECT_FILE) $(EXECUTABLE)