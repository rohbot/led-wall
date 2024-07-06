#include <FastLED.h>

// How many leds in your strip?
#define NUM_LEDS 256

#define LEDS_PER_ROW 16
#define NUM_ROWS 16

#define DATA_PIN 5



CRGB leds[NUM_LEDS];


unsigned long hue = 0;

unsigned long last_msg = 0;

void fadeAll() {
  for (int i = 0; i < NUM_LEDS; i++) {
    leds[i].nscale8(100);
  }
  FastLED.show();
}

void light_row(int row, CRGB colour) {

  if (row > NUM_ROWS) {
    return;
  }

  for (int i = 0; i < LEDS_PER_ROW; i++) {
    int pixel = (LEDS_PER_ROW * row) + i;
    leds[NUM_LEDS - pixel - 1] = colour;
  }
}

void waitFade() {
  while (leds[15].b > 0) {
    fadeAll();
    delay(30);
  }
}

void setup() {

  Serial.begin(115200);
  while (!Serial && millis() < 10000UL)
    ;
  Serial.println("ON");

  //FastLED.addLeds<NEOPIXEL, DATA_PIN>(leds, NUM_LEDS);
  FastLED.addLeds<WS2812, DATA_PIN, RGB>(leds, 0, NUM_LEDS);
  FastLED.setBrightness(10);
  for (int i = 0; i < NUM_ROWS; i++) {
    hue = map(i, 0, NUM_ROWS, 0, 160);
    light_row(i, CHSV(hue, 255, 255));
  }
  FastLED.show();

  waitFade();

  last_msg = millis();
}

unsigned long row_lit = 0;
int cur_row = 0;


unsigned long swap = 0;
bool make_twinkle = true;
byte val;
void loop() {
  
  if (millis() - last_msg > 100) {
    // matrix();
    fadeAll();
  
  }
  if (Serial.available() > 1) {
    last_msg = millis();
    // read the most recent byte (which will be from 0 to 255):
    byte cmd = Serial.read();
    byte pixel = Serial.read();
    // byte val = Serial.read();

    if (cmd > 0) {
      Serial.print("cmd: ");
      Serial.print(cmd);
      Serial.print("\tp: ");
      Serial.print(pixel);
      // Serial.print("\tv: ");
      // Serial.print(val);
    }
    if (cmd == 1) {
      FastLED.clear();
      FastLED.show();
      Serial.print("\t clear");
    } else if (cmd == 255) {
      FastLED.show();
    } else {
      // Set pixel value
      // int pixel = ((LEDS_PER_ROW) * (y)) + x;

      // if (y % 2) {
      //   pixel = ((LEDS_PER_ROW) * (y)) + (LEDS_PER_ROW - 1 - x);
      //   //pixel += 1;
      // }

      // Serial.print("\tled:");
      // Serial.print(pixel);
      leds[pixel] = CHSV(100, 255, 255);
    }
    Serial.println();
  }
}