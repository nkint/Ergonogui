class Sensor {

  

  ControlP5 gui;
  Ergono parent;

  ArrayList<Controller> controllers = new ArrayList<Controller>();

  float value;
  LinkedList<Float> history = new LinkedList<Float>(); // take history of raw data
  int id;

  float min_in = 0;
  float max_in = 0;
  float min_out = 0;
  float max_out = 255;

  int offsetX;
  int offsetY;
  boolean calibration= false;

  boolean send_everything = false;

  float threshold = threasholdIN;
  boolean inside_NOTE = false; 

  //-------------------------------------------------------------- setup
  //-------------------------------------------------------------- setup

  Sensor(int id, Ergono parent, ControlP5 gui) {
    this.id = id;
    this.gui = gui;
    this.parent = parent;

    this.value = 0;
    this.history = getZeroLinkedList();
    this.min_in = Integer.MAX_VALUE;
    this.max_in = Integer.MIN_VALUE;

    init();
  }

  LinkedList<Float> getZeroLinkedList() {
    LinkedList<Float> l = new LinkedList<Float>();
    for (int i=0; i<400; i++) {
      l.add(Float.valueOf(0));
    }
    return l;
  }


  //-------------------------------------------------------------- draw
  //-------------------------------------------------------------- draw

  void draw(PApplet parent) {
    parent.stroke(250);
    parent.noFill();
    parent.rect(offsetX, 1+40 + offsetY + 80*id, 280-2, 39-2);

    parent.stroke(255, 0, 0);
    parent.beginShape();
    for (int i=0; i<history.size(); i++) {
      float v = history.get(i);
      float x = PApplet.map(i, 0, history.size(), 0, 280);
      float y = PApplet.map(v, min_in, max_in, 40, 0);
      parent.vertex(offsetX + x, offsetY + 80*id + 40 + y);
    }
    parent.endShape();

    parent.stroke(100, 100);
    float y = offsetY + 80*id + 40 + PApplet.map(threshold, min_out, max_out, 0, 40); 
    parent.line(offsetX, y, offsetX + 280, y );
  }

  //-------------------------------------------------------------- getter && setter
  //-------------------------------------------------------------- getter && setter

  void set_min_in(float n) {
    this.min_in = n;
    this.controllers.get(1).setValue(n);
  }

  void set_max_in(float n) {
    this.max_in = n;
    this.controllers.get(2).setValue(n);
  }

  void set_min_out(float n) {
    this.min_out = n;
    this.controllers.get(3).setValue(n);
  }

  void set_max_out(float n) {
    this.min_out = n;
    this.controllers.get(4).setValue(n);
  }

  void setOffset(int x, int y) {
    this.offsetX = x;
    this.offsetY = y;
    for (Controller c: controllers) {
      PVector p = c.getPosition();
      p.x += x;
      p.y += y;
      c.setPosition(p);
    }
  }

  void setCalibration(boolean n) {
    this.calibration  = n;
    history = getZeroLinkedList();

    if (n) {
      Controller c;
      c = controllers.get(1);
      c.setColorBackground(color(100, 180, 100));
      c = controllers.get(2);
      c.setColorBackground(color(100, 180, 100));
    } 
    else {
      controllers.get(1).setColorBackground(ControlP5.getColor().getBackground());
      controllers.get(2).setColorBackground(ControlP5.getColor().getBackground());
    }
  }

  void setRawData(int n) {
    this.value = n;

    if (calibration) {
      min_in = Math.min(min_in, n);
      max_in = Math.max(max_in, n);
      controllers.get(1).setValue(min_in);
      controllers.get(2).setValue(max_in);
      return;
    }

    // update the circular buffer for history
    if (history.size()<400) {
      // allocate new element
      history.add(new Float(value));
    }
    else {
      // re-using element..
      Float v = history.removeLast();
      v = Float.valueOf(value);
      history.addFirst(v);
    }

    value = PApplet.map(value, min_in, max_in, min_out, max_out);
    parent.send_OSC(id, value);
    //		if(value>threshold && !inside_NOTE) {
    //			inside_NOTE = true;
    //			parent.send_NOTE_IN(id);
    //		}
    //		if(value<threshold && inside_NOTE) {
    //			inside_NOTE = false;
    //			parent.send_NOTE_OUT(id);
    //		}
  }

  //-------------------------------------------------------------- init gui
  //-------------------------------------------------------------- init gui

  void init() {
    Controller c;

    c = gui.addNumberbox("id"+id)
      .setSize(heights[0], 40)
        .setPosition(positionsY[0], offsetY+80*id)
          .setValue(id)
            .setDecimalPrecision(1)
              .setMin(0)
                .setLock(true)
                  .setCaptionLabel("");
    controllers.add(c);

    c = gui.addNumberbox("min_in"+id)
      .setSize(heights[1], 40)
        .setPosition(positionsY[1], offsetY+80*id)
          .setValue(0)
            .setDecimalPrecision(1)
              .setCaptionLabel("");
    controllers.add(c);

    c = gui.addNumberbox("max_in"+id)
      .setSize(heights[2], 40)
        .setPosition(positionsY[2], offsetY+80*id)
          .setValue(0)
            .setDecimalPrecision(1)
              .setCaptionLabel("");
    controllers.add(c);

    c = gui.addNumberbox("min_out"+id)
      .setSize(heights[3], 40)
        .setPosition(positionsY[3], offsetY+80*id)
          .setValue(0)
            .setDecimalPrecision(1)
              .setCaptionLabel("");
    controllers.add(c);

    c = gui.addNumberbox("max_out"+id)
      .setSize(heights[4], 40)
        .setPosition(positionsY[4], offsetY+80*id)
          .setValue(255)
            .setDecimalPrecision(1)
              .setCaptionLabel("");
    controllers.add(c);

    //gui.addButton("asd"+id);
  }
}

