// FAT TAG p5
// a port of Theo Watsons FAT TAG to p5/p5js
// sorce retrieved from http://fffff.at/fattag/

////////////////////////////////////////////////////////
// translators of some oF functions
// apart from these vectors have nbecome ArrayLists and also some differences in color settings

public class ofPoint
{
  public float x;
  public float y;
  ofPoint(float inX, float inY) {
    x = inX;
    y = inY;
  }
  void vecMulti(float val) {
    x *= val;
    y *= val;
  }
  void vecAdd(float val) {
    x += val;
    y += val;
  }
  void vecAddScalar(ofPoint val) {
    x += val.x;
    y += val.y;
  }
}
void ofPushStyle() {
  pushStyle();
}
void ofPopStyle() {
  popStyle();
}
void ofFill() {
  // in to the void
}
void ofRect(float a, float  b, float  c, float  d) {
  rect(a, b, c, d);
}
void ofCircle(float a, float b, float c) {
  ellipse(a, b, c, c);
}
void ofTriangle(float x1, float y1, float x2, float y2, float x3, float y3) {
  triangle(x1, y1, x2, y2, x3, y3);
}
void ofBackground(int r, int g, int b) {
  background(r, g, b);
}
float ofRandom(float low, float high) {
  return random(low, high);
}

////////////////////////////////////////////////////////

////////////////////////////////////////////////////////
// globals

public static final int NUM_POINTS = 10;
public static final float BOUNCE_FACTOR = 0.5;
public static final float ACCELEROMETER_FORCE = 0.2;

boolean bFirst;
boolean reverse;
boolean bClear;
int whichMode;
int orientation; // kept it
ArrayList <stroke> strokes;

// to simulate doubleclick in p5
int lastClickMillis = -1000;
int lastClickMillisDelta = 0;

////////////////////////////////////////////////////////
// class partice

class particle {

  float len;
  float curLen;
  ofPoint sPos;
  ofPoint pos;
  float speed;
  float size;
  ArrayList<ofPoint> pts; //vector <ofPoint> pts; 
  int orientation;

  particle(ofPoint startPos, float _size, float _speed, int orient) {

    pts = new ArrayList<ofPoint>();
    //pos = sPos = startPos;
    pos = new ofPoint(startPos.x, startPos.y);
    sPos = new ofPoint(startPos.x, startPos.y);
    size = _size;
    speed = _speed;
    orientation = orient;
    len = speed * 470;
  }

  void update() {
    if ( curLen > len ) return;
    curLen += speed;
    if ( len - curLen < 30 ) {
      speed *= 0.973;
    }
    // assert that orientation == 1
    if ( pos.y < height ) {
      pos.y += speed;
    }
  }

  void draw() {
    ofPushStyle();
    ofFill();
    // assert that orientation == 1
    ofRect(sPos.x, sPos.y, size, pos.y - sPos.y);
    ofCircle(pos.x, pos.y-0.5, size);
    ofPopStyle();
  }
};

////////////////////////////////////////////////////////
// class stroke

class stroke {

  int id; 
  ArrayList <ofPoint> pts;
  ArrayList <ofPoint> lNormal;
  ArrayList <ofPoint> rNormal;
  boolean closed;
  float r, g, b;
  ArrayList <particle> particles;

  stroke() {
    pts = new ArrayList<ofPoint>();
    lNormal = new ArrayList<ofPoint>();
    rNormal = new ArrayList<ofPoint>();
    particles = new ArrayList<particle>();
  }

  void update() {
    for (int i = 0; i < particles.size(); i++) {
      particles.get(i).update();
    }
  }

  void draw(boolean reverse) {
    if ( reverse ) {
      fill(255 - r, 255 - g, 255 - b);
    }
    else {
      fill(r, g, b);
    }
    for (int i = 0; i < particles.size(); i++) {
      particles.get(i).draw();
    }
    int drawTo = min(pts.size(), min(lNormal.size(), rNormal.size()));
    if (drawTo < 5)return;
    int numToDraw = pts.size() * 2;
    beginShape(TRIANGLE_STRIP);
    for (int j =0; j < drawTo; j++) {
      vertex(
      pts.get(j).x + lNormal.get(j).x, 
      pts.get(j).y + lNormal.get(j).y
        );
      vertex(
      pts.get(j).x + rNormal.get(j).x, 
      pts.get(j).y + rNormal.get(j).y
        );
    }
    endShape();
  }
};

////////////////////////////////////////////////////////
// app

void setup() {
  //size(1024, 768);
  size(900, 480);
  ofBackground(0, 0, 0);
  frameRate(60);
  strokes = new ArrayList<stroke>();
  strokes.clear();
  bClear = false;
  bFirst = true;
  whichMode = 0;
  reverse = false;
  noStroke();
}

void update() {
  if ( whichMode == 0 ) {
    ofBackground(255, 255, 0);
  }
  else if ( whichMode == 1) {
    ofBackground(0, 0, 0);
  }
  else if ( whichMode == 2) {
    ofBackground(255, 255, 255);
  }
  else {
    ofBackground(255, 255, 255);
  }
  if ( bClear ) {
    strokes.clear();
    bClear = false;
  }
  for (int i = 0; i < strokes.size(); i++) {
    strokes.get(i).update();
  }
}

void draw() {
  update();

  for (int i = 0; i < strokes.size(); i++) {
    strokes.get(i).draw(false);
  }

  ofPushStyle();
  fill(150, 150, 150, 100);
  ofTriangle(width, height, width-30, height, width, height-30);
  ofPopStyle();

  /*
  if (bFirst) {
     //
  }
  */
}

void mousePressed() {

  float x = mouseX;
  float y = mouseY;
  int touchId = 0;

  if ( x > width-30 && y > height - 30 ) {
    whichMode++;
    if ( whichMode >= 4 )whichMode = 0;
    bClear = true;
    return;
  }

  bFirst = false;
  if ( strokes.size() > 0 ) {    
    if ( strokes.size() > 13 ) {
      strokes.remove(0);
    }
  }

  int r, g, b;
  if ( whichMode == 0 ) {
    r = 255;
    g = 0;
    b = 255;
  }
  else if ( whichMode == 1) {
    r = 255;
    g = 255;
    b = 255;
  }
  else if ( whichMode == 2) {
    r = 0;
    g = 0;
    b = 0;
  }
  else {
    r = 255;
    g = 0;
    b = 0;
  }

  strokes.add(new stroke());
  strokes.get(strokes.size() - 1).id = touchId;
  strokes.get(strokes.size() - 1).r = r;
  strokes.get(strokes.size() - 1).g = g;
  strokes.get(strokes.size() - 1).b = b;
  strokes.get(strokes.size() - 1).closed = false;
}

void mouseDragged() {
  float x = mouseX;
  float y = mouseY;
  int touchId = 0;

  int which = -1;
  for (int i = 0; i < strokes.size(); i++) {
    if ( strokes.get(i).id == touchId && !strokes.get(i).closed ) {
      which = i; 
      break;
    }
  }

  if ( which != -1 ) {

    stroke s = strokes.get(which);

    if ( s.pts.size() > 0 ) {

      float dx = x-s.pts.get(s.pts.size() - 1).x;
      float dy = y-s.pts.get(s.pts.size() - 1).y;
      float len = sqrt(dx*dx + dy*dy);

      if (len >= 2.0) {
        ofPoint tmp = new ofPoint(x, y);
        tmp.vecMulti(0.3);
        tmp.x += s.pts.get(s.pts.size() - 1).x * 0.7;
        tmp.y += s.pts.get(s.pts.size() - 1).y * 0.7;
        s.pts.add(tmp);
      }
    }
    else {
      s.pts.add(new ofPoint(x, y));  
      s.lNormal.add(new ofPoint(0, 0));
      s.rNormal.add(new ofPoint(0, 0));
    }

    if ( (int)ofRandom(0, 5) == 3 ) {
      // assert oriontation to be portrait == 1
      int orient = 0;
      s.particles.add( new particle( s.pts.get(s.pts.size() - 1), ofRandom(1, 1.5), ofRandom(0.45, 1.3), orient) );
    }

    if ( s.pts.size() > 1) {

      ofPoint diff = new ofPoint( s.pts.get(s.pts.size() - 1).x - s.pts.get(s.pts.size()-2).x, s.pts.get(s.pts.size() - 1).y - s.pts.get(s.pts.size()-2).y);

      s.lNormal.add( new ofPoint( -diff.y, diff.x) );
      s.rNormal.add( new ofPoint( diff.y, -diff.x) );

      s.lNormal.get(s.lNormal.size() - 1).x = s.lNormal.get(s.lNormal.size() - 1).x * 0.3 + s.lNormal.get(s.lNormal.size()-2).x * 0.7;
      s.lNormal.get(s.lNormal.size() - 1).y = s.lNormal.get(s.lNormal.size() - 1).y * 0.3 + s.lNormal.get(s.lNormal.size()-2).y * 0.7;

      s.rNormal.get(s.rNormal.size() - 1).x = s.rNormal.get(s.rNormal.size() - 1).x* 0.3 + s.rNormal.get(s.rNormal.size()-2).x * 0.7;
      s.rNormal.get(s.rNormal.size() - 1).y = s.rNormal.get(s.rNormal.size() - 1).y* 0.3 + s.rNormal.get(s.rNormal.size()-2).y * 0.7;

      s.lNormal.get(s.lNormal.size() - 1).x *= 0.73;
      s.lNormal.get(s.lNormal.size() - 1).y *= 0.73;

      s.rNormal.get(s.rNormal.size() - 1).x *= 0.73;
      s.rNormal.get(s.rNormal.size() - 1).y *= 0.73;
      
    }
  }
}

void mouseReleased() {
  float x = mouseX;
  float y = mouseY;
  int touchId = 0;

  int which = -1;
  for (int i = 0; i < strokes.size(); i++) {
    if ( strokes.get(i).id == touchId && !strokes.get(i).closed ) {
      which = i; 
      break;
    }
  }

  if ( which >= 0 ) {  
    strokes.get(which).closed = true;

    if ( strokes.get(which).pts.size() > 10 ) {
      float amnt = 1.0;
      for (int i = strokes.get(which).pts.size()-5; i < strokes.get(which).pts.size(); i++) {
        strokes.get(which).lNormal.get(i).x *= amnt;
        strokes.get(which).lNormal.get(i).y *= amnt;
        strokes.get(which).rNormal.get(i).x *= amnt;
        strokes.get(which).rNormal.get(i).y *= amnt;
        if ( amnt > 0)amnt -= 0.25;
      }
    }
  }
}

void mouseClicked() {
  lastClickMillisDelta = millis()-lastClickMillis;
  if ( lastClickMillisDelta < 300 ) {
    bClear = true;
    bFirst = false;
  }
  lastClickMillis = millis();
}

