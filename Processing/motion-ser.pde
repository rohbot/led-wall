import gab.opencv.*;
import processing.video.*;

import processing.serial.*;
OpenCV opencv;
Capture video;

Serial myPort;

int rows = 16;
int cols = 16;
int LEDS_PER_ROW = 16;
PVector areaFlow;

int x;
int y;
int w;
int h;

int inByte = -1;    // Incoming serial data

String buf ="";
int num_pixels = rows * cols;

int[] data = new int[num_pixels];
int val;

int threshold = 2500;

boolean data_updated;
void setup() {
  size(1280, 480);
  video = new Capture(this, "pipeline:autovideosrc");
  opencv = new OpenCV(this, 640, 480);
  video.start();
  w = opencv.width / cols;
  h = opencv.height / rows;

  String portName = Serial.list()[1];
  myPort = new Serial(this, portName, 115200);
  sendClear();
  //colorMode(HSB,255);
  for (int i = 0; i < num_pixels; i++) {
    data[i] = 0;
  }
}

void draw() {
  background(0);

  if (video.width == 0 || video.height == 0)
    return;

  opencv.loadImage(video);
  opencv.flip(1);
  opencv.calculateOpticalFlow();
  pushMatrix(); 
  scale(-1, 1);
  image(video, -video.width, 0);
  popMatrix();
  //sendClear();
  //colorMode(HSB);
  data_updated = false;
  for (int j =0; j < rows; j++) {
    for (int i =0; i< cols; i++) {

      int pixel = ((LEDS_PER_ROW) * (j)) + i;

      if (j % 2 == 0) {
        pixel = ((LEDS_PER_ROW) * (j)) + (LEDS_PER_ROW - 1 - i);
      }
      x = w * i ;
      y = h * j;
      areaFlow = opencv.getTotalFlowInRegion(x, y, w, h);
      if (areaFlow.mag() >  threshold) {
        float raw_val = map(areaFlow.mag(), threshold, 1000, 0, 255);
        if (raw_val  < 0) {
          val = 0;
        } else if (raw_val > 254) {
          val = 254;
        } else {
          val = int(raw_val);
        }
        text(areaFlow.mag(), x + (w/2), y + (h/2));
        fill(150, 0, 0);
        rect(x, y, w, h);
        println(i, j, pixel, areaFlow.mag(), raw_val, val);
        //data[pixel] = val;
        data_updated = true;
        sendPixelVal(pixel, 100);
      }
    }
  }
  if (data_updated) {
    sendDisplay();
  }


  //sendDisplay();
  translate(video.width, 0);
  stroke(255, 0, 0);
  //colorMode(RGB);
  opencv.drawOpticalFlow();
}

void captureEvent(Capture c) {
  c.read();
}


void sendDisplay() {
  myPort.write(0xFF);
  myPort.write(0x00);
  //myPort.write(0x00);
}


void sendClear() {
  myPort.write(0x01);
  myPort.write(0x00);
  //myPort.write(0x00);
}


void sendPixelVal(int pixel, int val) {
  myPort.write(0x02);
  myPort.write(pixel);
  //myPort.write(val);
}

void serialEvent(Serial myPort) {
  inByte = myPort.read();
  if (inByte != '\n') {
    buf += (char)inByte;
  } else {
    println(buf);
    buf = "";
  }
}
