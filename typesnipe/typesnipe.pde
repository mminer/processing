// Holds information about the letter "enemy".
class Letter {
  final char character;
  final String characterStr;
  final float x;
  float y;

  public Letter(float x, float y) {
    this.character = generateCharacter();
    this.characterStr = String.valueOf(this.character);
    this.x = x;
    this.y = y;
  }

  // Displays the letter.
  public void draw() {
    text(characterStr, x, y);
  }

  // Moves the letter down the y-axis.
  public void advance(float amount) {
    this.y += amount;
  }

  // Returns true if the given character matches this one.
  public boolean matches(char character) {
    return this.character == character;
  }

  // Returns true if it's beyond the given y-axis value.
  public boolean beyondBoundary(float boundary) {
    return this.y > boundary;
  }

  // Returns the y value.
  public float getY() {
    return y;
  }

  // Gets a random lowercase alpha characters.
  char generateCharacter() {
    char character = (char)((int)random(0, 26) + 97);

    // Skip visually similar characters (in the pixel font we're using).
    if (character == 'u' || character == 'v' || character == 'x' || character == 'k') {
      character = generateCharacter();
    }

    return character;
  }
}

// Images
PImage level;
PImage[] clouds;
PVector[] cloudPositions;

// Sounds
Maxim maxim;
AudioPlayer music;
AudioPlayer successSound;
AudioPlayer failureSound;

// Fonts
PFont blockFont;
PFont pixelFont;

int spawnSpeed = 2000; // Milliseconds
float cloudSpeed = 1;
float boundary;

ArrayList<Letter> letters;
int score;
float letterSpeed;
int lastSpawn;
boolean alive;

void setup() {
  // Load images.
  level = loadImage("images/level.png");
  clouds = new PImage[] {
    loadImage("images/cloud1.png"),
    loadImage("images/cloud2.png"),
    loadImage("images/cloud3.png")
  };

  cloudPositions = new PVector[] {
    new PVector(50, 50),
    new PVector(500, 150),
    new PVector(250, 250),
  };

  // Load audio.
  maxim = new Maxim(this);

  music = maxim.loadFile("audio/music.wav");
  music.speed(0.8);
  music.setLooping(true);
  music.play();

  successSound = maxim.loadFile("audio/success.wav");
  failureSound = maxim.loadFile("audio/failure.wav");
  successSound.setLooping(false);
  failureSound.setLooping(false);

  // Load fonts.
  blockFont = createFont("fonts/block.ttf", 32);
  pixelFont = createFont("fonts/pixel.ttf", 32);
  textAlign(CENTER, CENTER);

  frameRate(30);
  smooth();
  size(630, 480);
  boundary = height - 35;
  reset();
}

void draw() {
  background(208, 244, 247); // Light blue

  // Draw clouds.
  for (int i = 0; i < clouds.length; i++) {
    image(clouds[i], cloudPositions[i].x, cloudPositions[i].y);
    cloudPositions[i].x += cloudSpeed;

    // Loop around when it reaches the edge of the screen.
    if (cloudPositions[i].x > width) {
      cloudPositions[i].x = -clouds[i].width;
    }
  }

  if (alive) { // Draw letters
    textFont(pixelFont);
    fill(64);
    textSize(32);
    float lowestLetter = 0;

    for (Letter letter : letters) {
      letter.draw();
      letter.advance(letterSpeed);

      // Ensure it hasn't gone beyond the boundary.
      if (letter.beyondBoundary(boundary)) {
        alive = false;
      }

      if (letter.getY() > lowestLetter) {
        lowestLetter = letter.getY();
      }
    }

    // Make the music's tempo increase the closer to losing the player is.
    if (lowestLetter < height * 0.3) {
      music.speed(0.8);
    } else if (lowestLetter < height * 0.6) {
      music.speed(1);
    } else {
      music.speed(1.2);
    }

    // Spawn a new letter periodically.
    if (millis() - lastSpawn > spawnSpeed) {
      spawnLetter();
      lastSpawn = millis();
    }

    // Gradually speed up the rate at which letters advance.
    letterSpeed += 0.001;
  } else { // Draw reset screen
    textFont(blockFont);
    fill(255);

    // Score indicator.
    textSize(64);
    text("Score: " + score, width / 2, height / 2 - 60);

    // Play again instructions.
    textSize(32);
    text("Press Enter To Play Again", width / 2, height / 2);
  }

  image(level, 0, 0);

  if (alive) {
    // Draw score.
    textFont(blockFont);
    fill(255);
    text("" + score, width / 2, height - 28);
  }
}

void keyReleased() {
  // Enter resets the game.
  if (keyCode == ENTER || keyCode == RETURN) {
    reset();
    return;
  }

  // Skip out early if we're not playing.
  if (!alive) {
    return;
  }

  // Only consider keys a - z.
  if ((int)key < 97 || (int)key > 122) {
    return;
  }

  for (Letter letter : letters) {
    if (letter.matches(key)) {
      score++;
      successSound.cue(0);
      successSound.play();
      letters.remove(letter);
      spawnLetter();
      return;
    }
  }

  // If we make it to here, no letter matches the key pressed.
  score--;
  failureSound.cue(0);
  failureSound.play();
}

// Resets the game.
void reset() {
  letters = new ArrayList<Letter>();
  score = 0;
  letterSpeed = 1;
  lastSpawn = 0;
  alive = true;
}

// Creates a new letter at the top of the screen.
void spawnLetter() {
  float x = random(10, width - 10);
  Letter letter = new Letter(x, -15);
  letters.add(letter);
}
