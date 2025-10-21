f ?= main.s

# Extract the filename without its directory path and extension
BASE_NAME := $(basename $(notdir $(f)))

OBJECT_FILE := $(BASE_NAME).o
EXECUTABLE := $(BASE_NAME).out

.PHONY: all hexdump_output write default

all: $(EXECUTABLE) hexdump_output

$(OBJECT_FILE): $(f)
	@echo "Assembling $<"
	ca65 $< -o $@

$(EXECUTABLE): $(OBJECT_FILE)
	@echo "Linking $@"
	ld65 -C mem.cfg $< -o $@

hexdump_output: $(EXECUTABLE)
	@echo "Generating hexdump..."
	hexdump -C $<
	rm -f *.o *.out 

write: $(EXECUTABLE)
	@echo "Writing $< to ROM chip..."
	minipro -p AT28C256 -w $<
	rm -f *.o *.out 

default: all

clean:
	@echo "Cleaning up..."
	rm -f *.o *.out