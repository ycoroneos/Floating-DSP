#include <Wire.h>

uint8_t pll_data[7] = {
  0x2,0x0,0x7D,0x0,0xC,0x23,0x1,
};

uint8_t regular_data[][2] = {
  {0x0, 0xE},
  {0x0, 0xF},
  {0x15, 0x1},
  {0xA, 0x1},
  {0xB, 0x5},
  {0xC, 0x1},
  {0xD, 0x5},
  {0x1C, 0x21},
  {0x1E, 0x41},
  {0x23, 0xE7},
  {0x24, 0xE7},
  {0x25, 0xE7},
  {0x26, 0xE7},
  {0x19, 0x3},
  {0x29, 0x3},
  {0x2A, 0x3},
  {0xF2, 0x1},
  {0xF3, 0x1},
  {0xF9, 0x7F},
  {0xFA, 0x3},
};

const size_t dcount = sizeof(regular_data)/sizeof(regular_data[0]);

int led=13;

void setup() {
  pinMode(led, OUTPUT);
  Wire.begin();
  Serial.begin(9600);
  sendstuff(&regular_data[0][0], 2);
  sendstuff(pll_data, 7);
  for (int i=0; i<dcount-1; ++i) {
    sendstuff(&regular_data[i][0], 2);
  }
  Serial.println("Done i2c\n");
}

void sendstuff(uint8_t *bytes, int count) {
  Wire.beginTransmission(0x76);
  Wire.write(0x40);
  for (int i=0; i<count; ++i) {
    Wire.write(bytes[i]);
  }
  Wire.endTransmission();
}

void loop() {
  digitalWrite(led, HIGH);   // turn the LED on (HIGH is the voltage level)
  delay(1000);               // wait for a second
  digitalWrite(led, LOW);    // turn the LED off by making the voltage LOW
  delay(1000);               // wait for a second
}
