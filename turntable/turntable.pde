import processing.sound.*; // Import the Processing sound library

// Declare image and audio variables
PImage baseImage, pulley, offButtonImage, vinylImage, armImage;
SoundFile song;

boolean power = false;
boolean needleUp = false;
float angle = 0;
float needleAngle = 0;

void setup() {
  size(1440, 1117); 
  
  // Load all images
  baseImage = loadImage("turntable_0008_Layer-0.png");
  pulley = loadImage("turntable_0802_motorpulley-png");
  offButtonImage = loadImage("turntable_0005_off-button.png");
  vinylImage = loadImage("vinyl.png");
  armImage = loadImage("turntable_0003_arm.png");
  
  // Load the sound file
  song = new SoundFile(this, "AET310song-mp3");
}

void draw() {
  background(0); // Clear screen each frame
  angle += 1; // Increase rotation angle each frame (adjust for speed)
  
  imageMode(CORNER);
  image(baseImage, 0, 0); // Draw base image
  
  // Draw vinyl and pulley based on power state
  if (!power) {
    image(offButtonImage, 152, 948); // Show off button image
    imageMode(CENTER);
    image(vinylImage, 646, 558); // Static vinyl
  } else {
    // Animated pulley
    push();
    imageMode(CENTER);
    translate(192, 204);
    rotate(radians(angle * 6));
    image(pulley, 0, 0);
    pop();
    
    // Spinning vinyl
    push();
    imageMode(CENTER);
    translate(646, 558);
    rotate(radians(angle));
    image(vinylImage, 0, 0);
    pop();
  }
  
  drawArm(); // Draw tonearm
  
  // Debug text showing mouse position and needle angle
  fill(255, 0, 0);
  textSize(30);
  text(mouseX + " " + mouseY + " " + degrees(needleAngle), 100, 100);
}

void drawArm() {
  push();
  imageMode(CENTER);
  translate(1218, 257); // Pivot point of the tonearm
  if (needleUp) {
    needleAngle = mapToAngle(mouseX, mouseY); // Calculate angle when dragging
  }
  rotate(needleAngle); 
  imageMode(CORNER);
  image(armImage, -92, -166); // Draw arm relative to pivot
  pop();
}

void mousePressed() {
  // Toggle power button if clicked in button area
  if (mouseX > 150 && mouseX < 210 && mouseY > 950 && mouseY < 990) {
    power = !power; // Flip power state
    
    if (!power) {
      if (song.isPlaying()) {
        song.pause(); // Stop music if power turned off
      }
    } else {
      if (onVinyl()) {
        playSong(); // Start music if needle is on vinyl
      }
    }
  } else {
    // Toggle needle up/down on click elsewhere
    needleUp = !needleUp;
    if (!needleUp) {
      if (onVinyl() && power) {
        playSong(); // Start song when needle is placed and power is on
      }
    }
  }
}

// Converts mouse position to tonearm rotation angle
float mapToAngle(int mouseX, int mouseY) {
  int armBaseX = 1218;
  int armBaseY = 257;
  float angle = atan2(armBaseY - mouseY, mouseX - armBaseX);
  return (3 * PI / 2 - angle) % (TWO_PI); // Adjust for correct rotation
}

// Check if needle is over vinyl area
boolean onVinyl() {
  // Rough check for if needle is over the vinyl region
  float x = 1218 + cos(needleAngle) * 200; // estimated arm length
  float y = 257 + sin(needleAngle) * 200;
  return dist(x, y, 646, 558) < 150; // distance from vinyl center
}

// Start song playback from the beginning
void playSong() {
  if (!song.isPlaying()) {
    song.play();
  }
}
