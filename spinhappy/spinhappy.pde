Maxim maxim;
AudioPlayer player;
PImage[] faces;
Circle[] circles = new Circle[100];
int halfW, halfH; // Center of sketch.
float tick = 0;
boolean paused = false;

class Circle {
  float diameter;
  float distance;
  float offset;

  public Circle(float diameter, float distance, float offset) {
    this.diameter = diameter;
    this.distance = distance;
    this.offset = offset;
  }

  public float calculateX(float tick) {
    float x = distance * cos(tick + offset);
    return x;
  }

  public float calculateY(float tick) {
    float y = distance * sin(tick + offset);
    return y;
  }

  public void draw(float x, float y) {
    ellipse(x, y, diameter, diameter);
  }
}

void setup() {
  frameRate(60);
  size(500, 500);
  fill(253, 116, 0);
  stroke(255, 255, 26);
  strokeWeight(10);
  smooth();

  halfW = width / 2;
  halfH = height / 2;

  // Initialize circles.
  for (int i = 0; i < circles.length; i++) {
    float diameter = random(5, 50);
    float distance = random(10, 350);
    float offset = random(0, TWO_PI);
    circles[i] = new Circle(diameter, distance, offset);
  }

  // Load and play audio file.
  maxim = new Maxim(this);
  player = maxim.loadFile("beat.wav");
  player.setLooping(true);

  // Load face images.
  faces = new PImage[] {
      loadImage("face0.png"),
      loadImage("face1.png"),
      loadImage("face2.png"),
      loadImage("face3.png")
  };
}

void draw() {
  if (paused) {
    return;
  }

  player.play();
  float fromCenter = dist(mouseX, mouseY, halfW, halfH);

  // Fade background according to proximity to center.
  float bgR = map(fromCenter, 0, halfW, 0, 31);
  float bgG = map(fromCenter, 0, halfW, 67, 138);
  float bgB = map(fromCenter, 0, halfW, 88, 112);
  background(bgR, bgG, bgB);

  // Vary speed by mouse position.
  tick += 0.05;
  float speed = norm(fromCenter, 0, halfW); // Also affects "spread"
  player.speed(speed);

  // Draw rotating circles.
  for (Circle c : circles) {
    float x = c.calculateX(tick) * speed + halfW;
    float y = c.calculateY(tick) * speed + halfH;
    c.draw(x, y);
  }

  // Draw center face.
  int face = (int)map(fromCenter, 0, halfW, 0, faces.length - 1);
  face = constrain(face, 0, faces.length - 1);
  ellipse(halfW, halfH, 50, 50);
  image(faces[face], halfW - 25, halfH - 25);
}

// Pause / unpause.
void mouseClicked() {
  if (paused) {
    player.play();
    paused = false;
  } else {
    player.stop();
    paused = true;
  }
}
