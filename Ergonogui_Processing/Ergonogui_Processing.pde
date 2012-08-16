
import netP5.NetAddress;
import oscP5.OscMessage;
import oscP5.OscP5;
import controlP5.ControlP5;
import processing.core.PApplet;
import processing.core.PFont;
import processing.serial.Serial;

import java.util.ArrayList;
import java.util.LinkedList;

import processing.core.PApplet;
import processing.core.PVector;

import controlP5.Button;
import controlP5.CallbackEvent;
import controlP5.CallbackListener;
import controlP5.ControlP5;
import controlP5.Controller;

static final char HEADER = 'H';



int[] heights = {
    40-1, 60-1, 60-1, 60-1, 60-1
  };
  int[] positionsY = {
    0, 40, 40+60, 40+60*2, 40+60*3
  };

ControlP5 gui;
OscP5 osc;
Serial port;

Sensor[] sensors;

boolean taratura = false;
NetAddress remoteLocation;

void setup() {
  size(400, 520);

  this.gui = new ControlP5(this);
  PFont font = createDefaultFont(12);
  gui.setFont(font);

  sensors = new Sensor[sensorNumber];
  for (int i=0; i<sensorNumber; i++) {
    sensors[i] = new Sensor(i, this, gui);
    sensors[i].setOffset(10, 100);
  }

  initGui();

  /* start oscP5, listening for incoming messages at port 12000 */
  this.osc = new OscP5(this, 1200);
  remoteLocation = new NetAddress(remoteAddress, remotePort);

  // call this only in the end because serialEvent method is asynchronous and
  // can be called before setup() is finished and some object may haven't been initialized yet
  println(Serial.list());
  this.port = new Serial(this, Serial.list()[0], 9600);
}

void initGui() {
  gui.addToggle("setCalibration").setSize(100-1, 29).setPosition(10, 10).setCaptionLabel("calibration");

  gui.addButton("id_label")
    .setSize(heights[0], 39)
      .setPosition(10+positionsY[0], 60)
        .setCaptionLabel("id")
          .setLock(true)
            .setColorBackground(color(240))
              .setColorCaptionLabel(color(0));
  gui.addButton("min_in_label")
    .setSize(heights[1], 39)
      .setPosition(10+positionsY[1], 60)
        .setCaptionLabel("min in")
          .setLock(true)
            .setColorBackground(color(240))
              .setColorCaptionLabel(color(0));
  gui.addButton("max_in_label")
    .setSize(heights[2], 39)
      .setPosition(10+positionsY[2], 60)
        .setCaptionLabel("max in")
          .setLock(true)
            .setColorBackground(color(240))
              .setColorCaptionLabel(color(0));
  gui.addButton("min_out_label")
    .setSize(heights[3], 39)
      .setPosition(10+positionsY[3], 60)
        .setCaptionLabel("min out")
          .setLock(true)
            .setColorBackground(color(240))
              .setColorCaptionLabel(color(0));
  gui.addButton("max_out_label")
    .setSize(heights[4], 39)
      .setPosition(10+positionsY[4], 60)
        .setCaptionLabel("max out")
          .setLock(true)
            .setColorBackground(color(240))
              .setColorCaptionLabel(color(0));
}

void draw() {
  background(0);

  checkSensors();

  for (Sensor s: sensors) {
    s.draw(this);
  }
}

void checkSensors() {
  String s = "";
  int size = 10; // Arduino sends 10 byte:
  // 1 byte header, 2 byte * 4 sensors, 1 byte ender

  int inByte, n=0;
  if (port.available() >= size) {
    if (port.read() == HEADER) {

      for (int i=0; i<sensorNumber; i++) {
        inByte = port.read();
        n = inByte;
        inByte = port.read();
        n += inByte*255;

        print(n+", ");
        sensors[i].setRawData(n);
      } // end sensors


      if (port.read()==13) {
        println("ok..");
      }
    } // end well formed message
  } // end serial available
}

void setCalibration(boolean n) {
  for (Sensor s: sensors) 
  {
    s.setCalibration(n);
  }
}

void serialEvent(Serial port) {
}

void min_in_0(float n) {
  sensors[0].set_min_in(n);
}
void max_in_0(float n) {
  sensors[0].set_max_in(n);
}
void min_out_0(float n) {
  sensors[0].set_min_out(n);
}
void max_out_0(float n) {
  sensors[0].set_max_out(n);
}

void min_in_1(float n) {
  sensors[1].set_min_in(n);
}
void max_in_1(float n) {
  sensors[1].set_max_in(n);
}
void min_out_1(float n) {
  sensors[1].set_min_out(n);
}
void max_out_1(float n) {
  sensors[1].set_max_out(n);
}

void min_in_2(float n) {
  sensors[2].set_min_in(n);
}
void max_in_2(float n) {
  sensors[2].set_max_in(n);
}
void min_out_2(float n) {
  sensors[2].set_min_out(n);
}
void max_out_2(float n) {
  sensors[2].set_max_out(n);
}

void min_in_3(float n) {
  sensors[3].set_min_in(n);
}
void max_in_3(float n) {
  sensors[3].set_max_in(n);
}
void min_out_3(float n) {
  sensors[3].set_min_out(n);
}
void max_out_3(float n) {
  sensors[3].set_max_out(n);
}

void send_NOTE_IN(int id) {
  OscMessage myMessage = new OscMessage("/test/in");
  myMessage.add(id); 
  this.osc.send(myMessage, remoteLocation);
}

void send_NOTE_OUT(int id) {
  OscMessage myMessage = new OscMessage("/test/out");
  myMessage.add(id); 
  this.osc.send(myMessage, remoteLocation);
}

void send_OSC(int id, float value) {
  OscMessage myMessage = new OscMessage("/ergonogui/"+id);
  myMessage.add(value);
  this.osc.send(myMessage, remoteLocation);
}

