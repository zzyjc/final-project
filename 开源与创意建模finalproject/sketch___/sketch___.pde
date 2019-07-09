int weizhiX=530;
int weizhiY=520;
int tempX;
int tempY;
int tempZ;
import processing.serial.*;
Serial myPort;
public static final char HEADER='M';
public static final short LF=10;
public static final short portlndex=2;
public static final short centerX=527;
public static final short centerY=520;

void serialEvent(Serial myPort) {
  
  String message=myPort.readStringUntil(LF);
  if (message!=null) {
    print(message);
    String[]data=message.split(",");
    println(data[1]);
    println(data[2]);
    if (data[0].charAt(0) == HEADER) {
      if (data.length>3) {
        tempX =Integer.parseInt(data[1]);
        tempY =Integer.parseInt(data[2]);
        tempZ =Integer.parseInt(data[3]);
      }
    }

    if (tempX>600) {
      weizhiX = weizhiX+2;
      if (weizhiX>1023) {
        weizhiX=1023;
      }
    }
    if (tempX<440) {
      weizhiX = weizhiX-2;
      if (weizhiX<0) {
        weizhiX=0;
      }
    }
    if (tempY>600) {
      weizhiY = weizhiY+2;
      if (weizhiY>1023) {
        weizhiY=1023;
      }
    }
    if (tempY<440) {
      weizhiY = weizhiY-2;
      if (weizhiY<0) {
        weizhiY=0;
      }
    }
  }
}


import com.thomasdiewald.pixelflow.java.DwPixelFlow;
import com.thomasdiewald.pixelflow.java.fluid.DwFluid2D;
import processing.core.*;
import processing.opengl.PGraphics2D;
// fluid simulation
DwFluid2D fluid;

// render targets
PGraphics2D pg_fluid;

ArrayList<Boid> flock = new ArrayList<Boid>();
ArrayList<Predator> pack = new ArrayList<Predator>();
int boidNum = 10;
int predNum = 1;

public void settings() {
  size(1023, 1023, P2D);
  //fullScreen(P2D);
}
public void setup() {
  myPort=new Serial(this, "com3", 9600);
  myPort.clear();
  DwPixelFlow context = new DwPixelFlow(this);
  context.print();
  context.printGL();
  fluid = new DwFluid2D(context, width, height, 1);
  fluid.param.dissipation_velocity = 0.70f;
  fluid.param.dissipation_density  = 0.49f;
  frameRate(60);
  for (int i=0; i<boidNum; i++) {
    flock.add(new Boid(new PVector(random(width), random(height))));
  }  
  for (int i=0; i<predNum; i++) {
    pack.add(new Predator(new PVector(random(width), random(height))));
  }
  fluid.addCallback_FluiData(new  DwFluid2D.FluidData() {
    public void update(DwFluid2D fluid) {

      for (Boid boid : flock) {
        for (Predator predator : pack) boid.repelForce(predator.getPos(), 80);
        boid.repelForce(new PVector(weizhiX, weizhiY), 150);
        boid.applyFlock(flock);
        boid.update();
        float px     = boid.position.x;
        float py     = height-boid.position.y;
        
        //float vx     =  +40;
        //float vy     =  -40;
        float vx     = (boid.velocity.x) * +20;
        float vy     = (boid.velocity.y) * -20;
        fluid.addVelocity(px, py, 20, vx, vy);
        fluid.addDensity (px, py, 20, boid.r, 200, 250, 1f);
      }
      if (0==0) {
        float px     = weizhiX;
        float py     = height-weizhiY;
        float vx     =  random(-700, 700);
        float vy     =  random(-700, 700);
        fluid.addVelocity(px, py, 30, vx, vy);
        //fluid.addDensity (px, py, 30, 0.0f, 0.4f, 1.0f, 1.0f);
        fluid.addDensity (px, py, 60, 255, 255, 255, 1.0f);
      }
      if (0==0) {
        float px     = 530;
        float py     = 520;
        float vx     =  random(-700, 700);
        float vy     =  random(-700, 700);
        fluid.addVelocity(px, py, 30, vx, vy);
        fluid.addDensity (px, py, 60, 0, 0.7f, 0.9f, 1.0f);
        //fluid.addDensity (px, py, 60, 0, 0, 0, 1.0f);
      }
    }
  }
  );
  pg_fluid = (PGraphics2D) createGraphics(width, height, P2D);
}
public void draw() {

  for (Boid boid : flock) {
    for (Predator predator : pack) boid.repelForce(predator.getPos(), 2);
    boid.repelForce(new PVector(weizhiX, weizhiY), 150);
    boid.applyFlock(flock);
    boid.update();
  }
  fluid.update();
  pg_fluid.beginDraw();
  pg_fluid.background(0);
  pg_fluid.endDraw();
  fluid.renderFluidTextures(pg_fluid, 0);
  image(pg_fluid, 0, 0);
}
class Boid {
  PVector
    position, 
    velocity, 
    acceleration;
  float r, g, b;
  Boid(PVector pos) {
    position = pos;
    velocity = new PVector(random(-1, 1), random(-1, 1));
    velocity.normalize();
    acceleration = new PVector();
    r = random(0.5, 1);
    g = random(0.5, 1);
    b = random(0.5, 1);
  }
  void update() {
    velocity.add(acceleration);
    position.add(velocity);
    acceleration.mult(0);
    velocity.limit(2);
    if (position.x<=0) {
      position.x = width;
    }
    if (position.x>width) {
      position.x = 0;
    }
    if (position.y<=0) {
      position.y = height;
    }
    if (position.y>height) {
      position.y = 0;
    }
    if (position.x<=580&&position.x>=480&&position.y<=570&&position.y>=460) {
      position.x = 530;
      position.y = 510;
    }
  }
  void applyForce(PVector force) {
    force.div(20);
    acceleration.add(force);
  }
  void applyFlock(ArrayList<Boid> friends) {
    seperationForce(friends);
    alignmentForce(friends);
    cohesionForce(friends);
  }
  void seperationForce(ArrayList<Boid> friends) {
    PVector posSum = new PVector();
    PVector sepVec = new PVector();
    float n = 0, d = 0;
    for (Boid friend : friends) {
      d = PVector.sub(friend.getPos(), this.getPos()).mag();
      if (d!=0 && d<=40) {
        posSum.add(friend.getPos());
        n++;
      }
    }
    if (n!=0) {
      posSum.div(n);
      sepVec = PVector.sub(position, posSum);
      sepVec.limit(2*2);
      applyForce(sepVec);
    }
  }
  void alignmentForce(ArrayList<Boid> friends) {
    PVector velSum = new PVector();
    PVector alignVec = new PVector();
    float n = 0, d = 0;
    for (Boid friend : friends) {
      d = PVector.sub(friend.getPos(), this.getPos()).mag();
      if (d!=0 && d<=40) {
        velSum.add(friend.getVel());
        n++;
      }
    }
    if (n!=0) {
      velSum.div(n);
      alignVec = velSum;
      alignVec.limit(40);
      applyForce(alignVec);
    }
  }

  void cohesionForce(ArrayList<Boid> friends) {
    PVector posSum = new PVector();
    PVector cohVec = new PVector();
    float n = 0, d = 0;
    for (Boid friend : friends) {
      d = PVector.sub(friend.getPos(), this.getPos()).mag();
      if (d!=0 && d<=40) {
        posSum.add(friend.getPos());
        n++;
      }
    }
    if (n!=0) {
      posSum.div(n);
      cohVec = PVector.sub(posSum, position);
      cohVec.limit(2);
      applyForce(cohVec);
    }
  }

  void repelForce(PVector source, float range) {
    PVector repVec = new PVector();
    float d = PVector.sub(source, position).mag();
    if (d!=0 && d<= range) {
      repVec = PVector.sub(position, source);
      repVec.normalize();
      repVec.mult(map(d, range, 0, 0, 2*80));
    }
    applyForce(repVec);
  }
  PVector getPos() {
    return position;
  }

  PVector getVel() {
    return velocity;
  }

  PVector getAcc() {
    return acceleration;
  }
}
class Predator extends Boid {
  Predator(PVector pos) {
    super(pos);
    velocity.mult(1.5);
  }
}
