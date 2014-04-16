PFont segoe;

void setup(){
  size(round(displayWidth * 0.75), round(displayHeight * 0.75));
  if(frame != null){
    frame.setResizable(true);
  }
  segoe = loadFont("suil_164.vlw");
}

void draw(){
  background(31, 174, 255);
  drawCog(width/2-340, 20, 1);
  textAlign(CENTER);
   textFont(segoe, 128);
  text("Enceladus", width/2, 128);
  textFont(segoe, 40);
  text("Type in your function:", width/2, 380);
  textFont(segoe, 28);
  text("Result:", width/2-210, 470);
  rect(width/2-250, 400, 500, 40);
  drawCog(width/2+262, 404, 0.25);
  noFill();
  stroke(255);
  rect(width/2+252, 400, 40, 39);
  rect(width/2-250, 442, 542, 150);
}

void drawCog(int x, int y, float scale){
  ellipseMode(CORNER);
  noStroke();
  fill(255);
  ellipse(x, y, 128*scale, 128*scale);
  fill(31, 174, 255);
  rect(x+64*scale, y, 64*scale, 128*scale);
  ellipse(x+14*scale, y+14*scale, 100*scale, 100*scale);
  fill(255);
  float dist = 75*scale;
  for(int i=1; i<=8; i++){
    pushMatrix();
    translate(x+64*scale-sin(PI/8.0*i-PI/32.0)*dist, y+64*scale-cos(PI/8.0*i-PI/32.0)*dist);
    rotate(-PI/8.0*i+PI/16.0);
    rect(0, 0, 14*scale, 14*scale);
    popMatrix();
  }
}

