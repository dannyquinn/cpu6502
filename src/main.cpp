#include <Arduino.h>

#define CLOCK 2       // Clock used to trigger interupt
#define READ_WRITE 3  // CPU Read/Write pin 
#define SYNC 4        // CPU Sync pin, low on opcode.

// Pins assigned for address & data buses.
const unsigned int ADDR[] = {39,41,43,45,38,40,42,44,47,49,51,53,46,48,50,52};
const unsigned int DATA[] = {22,24,26,28,30,32,34,36};

void onClock(); 

void setup() {
  // Set address pins as input
  for (int i=0; i < 16; i ++) {
    pinMode(ADDR[i], INPUT);
  }

  // Set data pins as input
  for (int i=0; i < 8; i++) {
    pinMode(DATA[i], INPUT);
  }

  // Set control pins as inputs
  pinMode(CLOCK, INPUT); 
  pinMode(READ_WRITE, INPUT);
  pinMode(SYNC, INPUT);
  
  attachInterrupt(digitalPinToInterrupt(CLOCK), onClock, RISING);

  Serial.begin(9600);
}

void loop() {}

void onClock() {
  unsigned int addr = 0; 
  unsigned int data = 0;
  // On each clock pulse output the contents of the buses and 
  // the read/write - sync flags 
  //
  // 0000-0000-0000-0000 00000000 0000 _ r 00
  // |    Address       |  Data  | AH |S|R|DH
  //
  // Address - Binary representation 
  // Data - Binary represenetation 
  // AH - Address in Hex 
  // S - Sync Flag 
  // R - R/W flag 
  // DH - Data Hex 
  
  for (int i=0; i < 16; i++) {
    if (i !=0 && i % 4 == 0) {
      Serial.print("-");
    }
    int bit = digitalRead(ADDR[i])?1:0;
    Serial.print(bit);
    addr = (addr << 1) | bit;    
  }

  Serial.print(" ");

  for (int i=0;i<8;i++){
    int bit = digitalRead(DATA[i])?1:0;
    Serial.print(bit);
    data = (data << 1) | bit;
  }

  char readWrite = digitalRead(READ_WRITE) ? 'r' : 'W';
  char opCode = digitalRead(SYNC) ? 'O': '_';

  char output[17]; 
  sprintf(output, " %04x %c %c %02x", addr, readWrite, opCode, data);
  Serial.println(output);
}