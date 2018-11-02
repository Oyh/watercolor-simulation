float layer_alpha = 3;
ArrayList<ArrayList<ArrayList<PVector>>> stacklist;
color[] c = new color[3];
PGraphics p, m1, m2;

void setup() {
  size(800, 800);
  colorMode(HSB, 100);
  background(0, 0, 100);
  
  m1 = createGraphics(width, height);
  m2 = createGraphics(width, height);
  p = createGraphics(width, height);
  
  stacklist = new ArrayList<ArrayList<ArrayList<PVector>>>();
  stacklist.add(polystack(width/2, height/5*3, width/3.5, 10));
  stacklist.add(polystack(width/2, height/5*2, width/3.5, 10));
  c[0] = color(98, 96, 89);
  c[1] = color(14, 73, 96);
  
  draw_stack(stacklist);
}

void draw_stack(ArrayList<ArrayList<ArrayList<PVector>>> stacklist) {
  for (int is_empty = 1, layer = 0, step = 5; is_empty != 0; layer += step) {
    is_empty = 0;
    for (int i = 0; i < stacklist.size(); ++i) {
      ArrayList<ArrayList<PVector>> stack = stacklist.get(i);
      for (int j = layer; j < layer+step; ++j) {
        if (j < stack.size()) {
          is_empty = 1;
          ArrayList<PVector> poly = stack.get(j);
          draw_poly(poly, c[i]);
        } else {
          break;
        }
      }
    }
  }
  save("1.png");
  println("finish");
}

void draw_poly(ArrayList<PVector> poly, color c) {
  m1.beginDraw();
  m1.colorMode(HSB, 100);
  m1.background(0, 0, 0);
  m1.stroke(0, 0, layer_alpha);
  m1.fill(0, 0, layer_alpha);
  m1.beginShape();
  for (int i = 0; i < poly.size(); ++i) {
    m1.vertex(poly.get(i).x, poly.get(i).y);
  }
  m1.endShape(CLOSE);
  m1.endDraw();
  
  m2.beginDraw();
  m2.colorMode(HSB, 100);
  m2.background(0, 0, 0);
  m2.noStroke();
  m2.fill(0, 0, 100);
  for (int i = 0; i < 900; ++i) {
    float x = random(0, width), y = random(0, height);
    float r = abs(randomGaussian()) * width*0.03 + width*0.02;
    m2.ellipse(x, y, r, r);
  }
  m2.blend(m1, 0, 0, width, height, 0, 0, width, height, DARKEST);
  m2.endDraw();
  
  p.beginDraw();
  p.colorMode(HSB, 100);
  p.background(c);
  p.mask(m2);
  p.endDraw();
  
  image(p, 0, 0);
}

ArrayList<ArrayList<PVector>> polystack(float x, float y, float r, int nsides) {
  ArrayList<ArrayList<PVector>> stack;
  ArrayList<PVector> base_poly, poly;
  
  stack = new ArrayList<ArrayList<PVector>>();
  
  base_poly = rpoly(x, y, r, nsides);
  base_poly = deform(base_poly, x, y, 4, 4, 1);
  
  for (int i = 0; i < 70; ++i) {
    poly = deform(base_poly, x, y, 5, 3, 1);
    stack.add(poly);
  }
  
  return stack;
}

ArrayList<PVector> rpoly(float x, float y, float r, int nsides) {
  ArrayList<PVector> points = new ArrayList<PVector>();
  float sx, sy;
  float angle = TWO_PI / nsides;

  for (float a = 0; a < TWO_PI; a += angle) {
    sx = x + cos(a) * r;
    sy = y + sin(a) * r;
    points.add(new PVector(sx, sy));
  }

  return points;
}

ArrayList<PVector> deform(ArrayList<PVector> points, float x, float y,
                          int depth, float variance, float vdiv) {
  float sx1, sy1, sx2 = 0, sy2 = 0;
  ArrayList<PVector> new_points = new ArrayList<PVector>();

  for (int i = 0; i < points.size(); ++i) {
    sx1 = points.get(i).x;
    sy1 = points.get(i).y;
    sx2 = points.get((i + 1) % points.size()).x;
    sy2 = points.get((i + 1) % points.size()).y;

    new_points.add(new PVector(sx1, sy1));
    float tmp = constrain(abs(randomGaussian()), 0, 4);
    if (tmp < 3) {
      subdivide(new_points, sx1, sy1, sx2, sy2, depth, 3, 1);
    } else {
      subdivide(new_points, sx1, sy1, sx2, sy2, depth, 2, 1.2);
    }
  }

  return new_points;
}

float calc_angle(float x1, float y1, float x2, float y2) {
  float ret = atan2(y2 - y1, x2 - x1);
  if (ret < 0) {
    ret += TWO_PI;
  }
  return degrees(ret);
}

void subdivide(ArrayList<PVector> new_points, float x1, float y1, 
               float x2, float y2, int depth, float variance, float vdiv) {
  float midx, midy;
  float nx, ny;
  
  if (depth > 0) {
    midx = (x1 + x2) / 2;
    midy = (y1 + y2) / 2;
    
    float distance = sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2));
    distance /= variance;
    
    nx = midx + randomGaussian() * distance;
    ny = midy + randomGaussian() * distance;
    
    float tmp = vdiv + random(-0.1, 0.1);
    subdivide(new_points, x1, y1, nx, ny, depth - 1, variance*vdiv, tmp);
    new_points.add(new PVector(nx, ny));
    subdivide(new_points, nx, ny, x2, y2, depth - 1, variance*vdiv, tmp);
  }
}
