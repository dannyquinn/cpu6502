#include <Arduino.h>

#define CLOCK 2
#define READ_WRITE 3
#define SYNC 4

const unsigned int ADDR[] = {22,24,26,28,30,32,34,36,38,40,42,44,46,48,50,52};
const unsigned int DATA[] = {39,41,43,45,47,49,51,53};

void onClock(); 

void setup() {

  for (int i=0; i < 16; i ++) {
    pinMode(ADDR[i], INPUT);
    if (i < 8) {
      pinMode(DATA[i], INPUT);
    }
  }
  pinMode(CLOCK, INPUT); 
  pinMode(READ_WRITE, INPUT);
  pinMode(SYNC, INPUT);
  attachInterrupt(digitalPinToInterrupt(CLOCK), onClock, RISING);

  Serial.begin(9600);
}

void loop() {}

void onClock() {
  unsigned int addr = 0; 
  unsigned int data =0;

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