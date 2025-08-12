#!/bin/zsh

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <filename (without extension)>"
  exit 1
fi

FILENAME="$1"

WRITE_FLAG=0 
if [[ "$2" == "-w" ]]; then
  WRITE_FLAG=1
fi

# Assemble
ca65 "${FILENAME}.s"

# Link
ld65 -C mem.cfg "${FILENAME}.o"

# Hexdump output
hexdump -C a.out

# Write to ROM chip
if [[ $WRITE_FLAG -eq 1 ]]; then
  minipro -p AT28C256 -w a.out
fi