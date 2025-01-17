import megamu.mesh.*;
import java.awt.geom.*;
import processing.pdf.*;

public class point {
  point() {
  }
  point(float x, float y) {
    this.x = x;
    this.y = y;
  }
  float x;
  float y;
};

point get_random_point(point min, point max) {
  return new point(random(min.x, max.x), 
  random(min.y, max.y));
}

/*class Line {
 point p0;
 point p1;
 };*/

//returns (length,angle)
point new_connected_point(point p, point p0, float min_dist, float max_dist, float min_angle, float max_angle) {
  float angle = random(min_angle, max_angle);
  float length = random(min_dist, max_dist);
  p.x = p0.x + length * cos(angle);
  p.y = p0.y + length * sin(angle);
  return new point(length, angle);
}

class NoodlePoint {
  NoodlePoint() {
    p = new point();
    a = new point();
    b = new point();
  }
  point p; // main point
  point a, b; // remote noodle-points
  void draw() {
    draw_line(p, a);
    draw_line(p, b);
  }
  void remote_points(float main_line_length, float main_angle) {
    float min_length = 0.2 * main_line_length;
    float max_length = 0.6 * main_line_length;
    float min_var = 0.3;
    new_connected_point(a, p, min_length, max_length, main_angle+min_var, main_angle+PI-min_var);
    new_connected_point(b, p, min_length, max_length, main_angle-min_var, main_angle-PI+min_var);
  }
  void get_points(float[][] points, int i) {
    points[i][0] = p.x;
    points[i][1] = p.y;
    points[i+1][0] = a.x;
    points[i+1][1] = a.y;
    points[i+2][0] = b.x;
    points[i+2][1] = b.y;
  }
};

void draw_line(point p0, point p1) {
  line(p0.x, p0.y, p1.x, p1.y);
}

void draw_triangle(point p0, point p1, point p2) {
  triangle(p0.x, p0.y, p1.x, p1.y, p2.x, p2.y);
}

void draw_quad(point p0, point p1, point p2, point p3) {
  quad(p0.x, p0.y, p1.x, p1.y, p2.x, p2.y, p3.x, p3.y);
}

void draw_hull_from_points(float[][] points) { 
  Hull hull = new Hull(points);
  int[] p = hull.getExtrema();
  for (int i = 1; i < p.length; i++) {
    line(points[p[i-1]][0], points[p[i-1]][1], points[p[i]][0], points[p[i]][1]);
  }
  int l = p.length-1;
  line(points[p[0]][0], points[p[0]][1], points[p[l]][0], points[p[l]][1]);
}

void draw_hull_from_points2(float[][] points) {
  Hull hull = new Hull(points);
  int[] p = hull.getExtrema();
  beginShape();
  for (int i = 0; i < p.length; i++) {
    vertex(points[p[i]][0], points[p[i]][1]);
  }
  endShape(CLOSE);
}

boolean lines_intersect(point p0, point p1, point l0, point l1) {
  return Line2D.linesIntersect(p0.x, p0.y, p1.x, p1.y, l0.x, l0.y, l1.x, l1.y);
}

class Noodle {
  Noodle() {
    p0 = new NoodlePoint();
    p1 = new NoodlePoint();
    p0.p = get_random_point(new point(150, 150), new point(750, 750));
    println(p0.p.x + " " + p0.p.y);
    point info = new_connected_point(p1.p, p0.p, 75, 150, 0, 2*PI);
    p0.remote_points(info.x, info.y);
    p1.remote_points(info.x, info.y);
  }
  void draw() {
    //draw_line(p0.p, p1.p);
    //p0.draw();
    //p1.draw();
  }
  void draw_hull() {
    float[][] points = new float[6][2];
    p0.get_points(points, 0);
    p1.get_points(points, 3);
    draw_hull_from_points(points);
  }
  void var_color(float r, float g, float b, float var) {
    //fill(r+random(var*2)-var, g+random(var*2)-var, b+random(var*2)-var, 220);
  }
  void draw_hull2(float r, float g, float b) {
    float var = 30;
    if (!lines_intersect(p0.a, p0.b, p0.p, p1.p)) {
      //draw_line(p0.a, p0.b);
      var_color(r, g, b, var);
      draw_triangle(p0.a, p0.b, p0.p);
    }
    if (!lines_intersect(p1.a, p1.b, p0.p, p1.p)) {
      //draw_line(p1.a, p1.b);
      var_color(r, g, b, var);
      draw_triangle(p1.a, p1.b, p1.p);
    }
    //draw_line(p0.a, p1.a);
    var_color(r, g, b, var);
    draw_quad(p0.a, p0.p, p1.p, p1.a);
    //draw_line(p0.b, p1.b);
    var_color(r, g, b, var);
    draw_quad(p0.b, p0.p, p1.p, p1.b);
  }
  NoodlePoint p0, p1;
};

void setup() {
  strokeWeight(0.5);
  size(900, 900);
  background(255);
  //colorMode(HSB, 1);
  fill(255,255,255,220);
  //strokeWeight(3);
  strokeJoin(ROUND);
  noLoop();
  beginRecord(PDF, "linesA-060.pdf"); 
}

void draw() {
  int num_noodles = (int) random(50, 80);
  Noodle noodles[] = new Noodle[num_noodles];
  float[][] points = new float[6*num_noodles][2];
  for (int i = 0; i < num_noodles; i++) {
    fill(255,255,255,200);
    //fill(random(100,255), random(100,255), random(100,255), 220);
    noodles[i] = new Noodle();
    //noodles[i].draw();
    noodles[i].draw_hull2(random(100,255), 0,0);
    noodles[i].p0.get_points(points, i*6);
    noodles[i].p1.get_points(points, i*6+3);
  }
  //fill(255,255,255,10);
  //fill(random(100,255), random(100,255), random(100,255), 30);
  draw_hull_from_points(points);
  
  endRecord();
}

/*void keyPressed(){
  if(key == 's') {
    void setup() {
}
    //saveFrame("lines-#####.pdf");
  }
}
*/

