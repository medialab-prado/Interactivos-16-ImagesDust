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

class Particle {
  final static float MOMENTUM = 0.62;
  final static float FLUID_FORCE = 1.7;

  float x, y;
  float vx, vy;
  float alpha;
  float mass;
  float [] colors = new float[3];
  float myForce = .016;
  float wind;  // to match with the drection of the fans
  

  void init(float x, float y, float currR, float currG, float currB) {//, boolean OFF) {
    this.x = x;
    this.y = y;
    vx = 0;
    vy = 0;
//    OFF_ = OFF;
//    if (OFF == true) {
//      alpha = 0;
//    } else {
      alpha  = random(0.3, 1);
//    }
    
    mass = random(0.5, 1);
    colors[0] = currR;
    colors[1] = currG;
    colors[2] = currB;
    wind = -2;
    
  }


  void update() {
    // only update if particle is visible
    if (alpha == 0) return;

    // read fluid info and add to velocity
    int fluidIndex = fluidSolver.getIndexForNormalizedPosition(x * invWidth, y * invHeight);
//  vx = fluidSolver.u[fluidIndex] * width * mass * FLUID_FORCE + vx * MOMENTUM;
//  vy = fluidSolver.v[fluidIndex] * height * mass * FLUID_FORCE + vy * MOMENTUM;

    vx = fluidSolver.u[fluidIndex] * width * mass * myForce + vx * MOMENTUM;
    vy = fluidSolver.v[fluidIndex] * height * mass * myForce + vy * MOMENTUM;
  
    if(myForce < FLUID_FORCE) myForce += .005;
    
    // simple gravity
    //vy+= -.4;
    
    // wind
    //vx+= wind;

    // update position
    x += vx;
    y += vy;

    // bounce of edges
    if (x<0) {
      x = 0;
      vx *= -1;
    } else if (x > width) {
      x = width;
      vx *= -1;
    }  

    if (y<0) {
      y = 0;
      vy *= -1;
    } else if (y > height) {
      y = height;
      vy *= -1;
    }

    // hackish way to make particles glitter when the slow down a lot
    if (vx * vx + vy * vy < 1) {
      vx = random(-1, 1);
      vy = random(-1, 1);
    }

    // fade out a bit (and kill if alpha == 0);
    alpha *= 0.98;
    if (alpha < 0.01) alpha = 0;
  }


  void updateVertexArrays(int i, FloatBuffer posBuffer, FloatBuffer colBuffer) {
    int vi = i * 4;
    posBuffer.put(vi++, x - vx);
    posBuffer.put(vi++, y - vy);
    posBuffer.put(vi++, x);
    posBuffer.put(vi++, y);

    int ci = i * 6;
    colBuffer.put(ci++, alpha);
    colBuffer.put(ci++, alpha);
    colBuffer.put(ci++, alpha);
    colBuffer.put(ci++, alpha);
    colBuffer.put(ci++, alpha);
    colBuffer.put(ci++, alpha);
  }


  void drawOldSchool(GL2 gl) {
    gl.glColor3f(colors[0], colors[1], colors[2]);

    // gl.glVertex2f(x-vx, y-vy);  // ??????????
    gl.glVertex2f(x-1, y-1);

    gl.glVertex2f(x, y);
  }
}







