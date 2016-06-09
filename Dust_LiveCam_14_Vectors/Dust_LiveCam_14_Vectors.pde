/***********************************************************************
 
 Demo of the MSAFluid library (www.memo.tv/msafluid_for_processing)
 Move mouse to add dye and forces to the fluid.
 Click mouse to turn off fluid rendering seeing only particles and their paths.
 Demonstrates feeding input into the fluid and reading data back (to update the particles).
 Also demonstrates using Vertex Arrays for particle rendering.
 
/***********************************************************************
 
 Copyright (c) 2008, 2009, Memo Akten, www.memo.tv
 *** The Mega Super Awesome Visuals Company ***
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of MSA Visuals nor the names of its contributors 
 *       may be used to endorse or promote products derived from this software
 *       without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS 
 * OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE. 
 *
 * ***********************************************************************/
import gab.opencv.*;
import processing.video.*;
import processing.serial.*;
import msafluid.*;
import java.awt.*;
import javax.media.opengl.GL2;


final float FLUID_WIDTH = 120;

float invWidth, invHeight;    // inverse of screen dimensions
float aspectRatio, aspectRatio2;

MSAFluidSolver2D fluidSolver;
ParticleSystem particleSystem;
//FanForces fanforces;
OpenCV opencv;
//Serial myPort;
Rectangle[] faces;

PImage imgFluid;

PImage copyImgCV;
int numPixels;

boolean drawFluid = true;

PVector location;

int screenWidth = 1280; 
int screenHeight = 720;

Capture liveCam;

PImage ourBackground;
PImage stillFrame; //particles comes from here
PVector noff;

boolean setOnce = false;
boolean CopyBG = false;
boolean startDust = false;

boolean OFF = false;

// Face Tracking
float PosFaceX, PosFaceY, WidthFace, HeightFace;

float faceXOff = 0;
float faceYOff = 0;
float faceWOff = 0;
float faceHOff = 0;
float growing = 1;


float FanForcesX, FanForcesY;
float[] Accel_x = {.1, 1, 10};
float[] Accel_y = {.1, 1, 10};
int timeEllapsed;

void setup() {

  size(screenWidth, screenHeight, P3D);    // use OPENGL rendering for bilinear filtering on texture

//  String portName = Serial.list()[2];
//  myPort = new Serial(this, portName, 9600);

  stillFrame = createImage(screenWidth, screenHeight, ARGB);
  ourBackground = createImage(screenWidth, screenHeight, RGB);

  copyImgCV = createImage(screenWidth/8, screenHeight/8, ARGB);

  liveCam = new Capture(this, screenWidth, screenHeight);
  liveCam.start();

  opencv = new OpenCV(this, screenWidth/8, screenHeight/8);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);  

  location = new PVector(width/2, height/2);
  noff = new PVector(random(1000), random(1000));

  FanForcesX = Accel_x[0];
  FanForcesY = Accel_y[0];

  invWidth = 1.0f/width;
  invHeight = 1.0f/height;
  aspectRatio = width * invHeight;
  aspectRatio2 = aspectRatio * aspectRatio;

  // create fluid and set options
  fluidSolver = new MSAFluidSolver2D((int)(FLUID_WIDTH), (int)(FLUID_WIDTH * height/width));
  fluidSolver.enableRGB(true).setFadeSpeed(0.003).setDeltaT(0.5).setVisc(0.0001);

  // create image to hold fluid picture
  imgFluid = createImage(fluidSolver.getWidth(), fluidSolver.getHeight(), RGB);

  // create particle system
  particleSystem = new ParticleSystem();
}


void draw() {
  background(255, 255, 255);

  if (liveCam.available() == true) {
    liveCam.read();
  }
  
  timeEllapsed = millis();

  if (liveCam.pixels.length <= 0 ) return;

  stillFrame.loadPixels();
  liveCam.loadPixels();

  if (!setOnce) {
    setOnce = true;
    for ( int i = 0; i < screenWidth*screenHeight; i++) {
      stillFrame.pixels[i] = color(255, 255, 255, 255);
    }
    stillFrame.updatePixels();
  }

  copyImgCV.copy(liveCam, 0, 0, screenWidth, screenHeight, 0, 0, screenWidth/8, screenHeight/8);
  opencv.loadImage(copyImgCV);


  for ( int i = 0; i < screenWidth*screenHeight; i++) {
    color c = stillFrame.pixels[i];
    color c2 = liveCam.pixels[i];
    color c3 = color (red(c2), green(c2), blue(c2), 255); //Simpler but slower method;

    //      float c3R = c2 >> 16 & 0xFF;
    //      float c3G = c2 >> 8 & 0xFF;
    //      float c3B = c2 & 0xFF;
    //      
    //    color c3 = color(c3R, c3G, c3B, 255.0);

    if ( alpha(c) > 0 ) stillFrame.pixels[i] = c3;
  }


  //  PVector ploc = location;
  //  location.x = map(noise(noff.x), 0, 1, 0, width);
  //  location.y = map(noise(noff.y), 0, 1, 0, height);
  //  // location.x = width*.25 + map(noise(noff.x), 0, 1, 0, width*.5);
  //  // location.y = height*.25 + map(noise(noff.y), 0, 1, 0, height*.5);
  //
  //  noff.add(0.05, 0.05, 0);

  //  float mouseNormX = location.x * invWidth;
  //  float mouseNormY = location.y * invHeight;
  //  float mouseVelX = (location.x - ploc.x) * invWidth;
  //  float mouseVelY = (location.y - ploc.y) * invHeight;
  //
  //  if (startDust) addForce(mouseNormX, mouseNormY, 20, 20);


  stillFrame.updatePixels();
  fluidSolver.update();

  ////  if (drawFluid && startDust) {
  ////    for (int i=0; i<fluidSolver.getNumCells (); i++) {
  ////      int d = 2;
  ////      imgFluid.pixels[i] = color(fluidSolver.r[i] * d, fluidSolver.g[i] * d, fluidSolver.b[i] * d);
  ////    }  
  ////    imgFluid.updatePixels();
  ////    //  fastblur(imgFluid, 2);
  ////    //image(imgFluid, 0, 0, width, height);
  ////  }


  faces = opencv.detect();

  for (int i = 0; i < faces.length; i++) {
    PosFaceX = faces[i].x * 8 ;
    PosFaceY = faces[i].y  * 8 ;
    WidthFace = faces[i].width * 8;
    HeightFace = faces[i].height * 8;
  }

  if (faces.length==1) { //If we have a face, trigger startDust and tells Arduino
    startDust =true; 
    //myPort.write('1');
    //println(faces.length);
  }
  else {
    //myPort.write('0');
    //println(faces.length);
  }

  PVector ploc = location;
  location.x = PosFaceX-faceXOff + map(noise(noff.x), 0, 1, 0, WidthFace+faceWOff);
  location.y = (PosFaceY-50)+faceYOff + map(noise(noff.y), 0, 1, 0, HeightFace+faceHOff);

  stroke(255, 0, 0);
  strokeWeight(3);
  rect(PosFaceX-faceXOff, (PosFaceY-50)+faceYOff, WidthFace+faceWOff, HeightFace+faceHOff);

  noff.add(0.15, 0.15, 0);

  float mouseNormX = location.x * invWidth;
  float mouseNormY = location.y * invHeight;

  //  float mouseVelX = (location.x - ploc.x) * invWidth;
  //  float mouseVelY = (location.y - ploc.y) * invHeight;


  println(timeEllapsed);  

  if (timeEllapsed/1000 > 10 && timeEllapsed/1000 < 20) {
      FanForcesX = Accel_x[1];
      FanForcesY = Accel_y[1];
  } else if (timeEllapsed/1000 > 20 && timeEllapsed/1000 < 40) {    
      FanForcesX = Accel_x[2];
      FanForcesY = Accel_y[2];
  } else if (timeEllapsed/1000 > 40) {    
      FanForcesX = Accel_x[0];
      FanForcesY = Accel_y[0];
  }
  
  println("fans", FanForcesX);

  if (startDust) addForce(mouseNormX, mouseNormY, 1, 1, FanForcesX, FanForcesY); //dx and dy means the velocity and direction

  image(ourBackground, 0, 0);
  image(stillFrame, 0, 0);

  if (startDust==true) particleSystem.updateAndDraw();

  if (faceXOff <= 160 && faces.length==1) {
    faceXOff += .45 *growing;
    faceYOff += .2 *growing;
    faceWOff += .9 *growing;
    faceHOff += .5 *growing;
  } 
  else if (faceYOff <= 300 && faces.length==1) {
    faceXOff += .1 *growing;
    faceYOff += .2 *growing;
    faceWOff += .2 *growing;
    faceHOff -= .05 *growing;
  }
}


void keyPressed() {
  switch(key) {
  case 'r': 
    renderUsingVA ^= true; 
    println("renderUsingVA: " + renderUsingVA);
    break;

  case 'b':
    CopyBG = true;
    ourBackground.copy(liveCam, 0, 0, screenWidth, screenHeight, 0, 0, screenWidth, screenHeight);
    break;

    //  case 'o':
    //    OFF ^= true;
    //    break;

  case 't':
    startDust ^= true;
    break;
  }
  //println(frameRate);
}



// add force and dye to fluid, and create particles
void addForce(float x, float y, float dx, float dy, float _FanForcesX, float _FanForcesY) {
  float speed = dx * dx  + dy * dy * aspectRatio2;    // balance the x and y components of speed with the screen aspect ratio

  if (speed > 0) {
    if (x<0) x = 0; 
    else if (x>1) x = 1;
    if (y<0) y = 0; 
    else if (y>1) y = 1;

    float colorMult = 5;
    float velocityMult = 3.0f;

    int index = fluidSolver.getIndexForNormalizedPosition(x, y);

    //color drawColor;

    //colorMode(HSB, 360, 1, 1);
    //float hue = ((x + y) * 180 + frameCount) % 360;
    //drawColor = color(hue, 1, 1);
    //colorMode(RGB, 1);  

    //    fluidSolver.rOld[index]  += red(drawColor) * colorMult;
    //    fluidSolver.gOld[index]  += green(drawColor) * colorMult;
    //    fluidSolver.bOld[index]  += blue(drawColor) * colorMult;

    particleSystem.addParticles(x * width, y * height, 900);

    //dx = (mouseX)/ ( width /5);  // dx and dy means the velocity and direction
    //dy = -((mouseY)/ ( height /5));  // dx and dy means the velocity and direction
    dx = _FanForcesX;
    dy = _FanForcesY;
    //    dx = -.1;
    //    dy = -.1;
    
    fluidSolver.uOld[index] += dx * velocityMult;
    fluidSolver.vOld[index] += dy * velocityMult;
  }
}

void captureEvent(Capture c) {
  c.read();
}

