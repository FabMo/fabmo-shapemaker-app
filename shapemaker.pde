//2016
//jw4rd

//dat.gui 
var parameter = {
   material : 0,
   thickness : 12.6,
   machine : "FabMO",
   feedrate : 1200,
   plungerate : 200,
   cut_depth : -1,
   shape : "polygon",
   radius : 25,
   verts : 1000,
   pX : 75,
   pY : 75,
   width : 800,
   rotate : 0,
   show_section : false,
   units : 0,
   gcode : 0,
   td : 1.5875,
   pn : 1,
   pd : 3.175,
   tabs : false,
   pocketon : false,
   safe_height : 4,
   dpolygon : false,
   dheart : false,
   dstar : false,
   dspiral : false,
   drose : true,
   dbutterfly : false,
   dporcupine : false,
   dgraffiti : false,
   points : 5,
   turns : 3,
   ir : 3,
   size : 30,
   n : 6,
   d : 8,
   o : 0.00,
   k : 0.001,
   pins : 10,
   way : 150,
   wax : 150,
   resize : false,
}

var Colorparameterect = function() {
   this.color = "#000000";
}

var colorparameterect = new Colorparameterect();
var parameter2 = { make:function(){ parameter.gcode=1 });
var gui1 = new dat.GUI({ load: JSON });

//gui1.remember(parameter);

var f1 = gui1.addFolder('MACHINE PARAMETERS');
f1.add(parameter, 'machine').name('');
f1.addColor(colorparameterect, 'color').name('bg color');
f1.add(parameter, 'units', { mm:0 } );
f1.add(parameter, 'material', { plywood:0} );
f1.add(parameter, 'thickness', 0.1, 30.1).step(0.1).name('thickness');
f1.add(parameter, 'feedrate', 0, 20000).step(1);
f1.add(parameter, 'plungerate', 0, 1000).step(1);
f1.add(parameter, 'td', 0, 10.7).step(1.5875).name('tool diameter');
f1.add(parameter, 'cut_depth', -25, 1).name('cut depth').step(1);
f1.add(parameter, 'pn', 1, 10).name('# of passes').step(1);
f1.add(parameter, 'pd').name('pass depth').listen();
f1.add(parameter, 'safe_height', 0, 10).name('safe height').step(0.5);
f1.add(parameter, 'way', 0, 500).name('y max').step(1);
f1.add(parameter, 'wax', 0, 500).name('x max').step(1);
f1.add(parameter, 'resize').name('resize');
f1.add(parameter, 'show_section').name('show section');

var f2 = gui1.addFolder('SHAPE PARAMETERS');
f2.add(parameter, 'pX', 0,170).listen().name('X center');
f2.add(parameter, 'pY', 0,210).listen().name('Y center');
f2.add(parameter, 'rotate',-360,360).step(1);
f2.add(parameter, 'radius',1.1,120).step(0.01);
f2.add(parameter, 'verts',1,2000).step(1).name('vertices');

var f3 = gui1.addFolder('POLYGON');
f3.add(parameter, 'dpolygon').name('draw');
f3.add(parameter, 'pocketon').name('pocket');

var f5 = gui1.addFolder('STAR');
f5.add(parameter, 'dstar').name('draw');
f5.add(parameter, 'points',2,200).step(1);
f5.add(parameter, 'ir',0.1,25).step(0.1).name('inside ratio');

var f6 = gui1.addFolder('HEART');
f6.add(parameter, 'dheart').name('draw');
f6.add(parameter, 'k',-10,10).step(0.1).name('k');

var f7 = gui1.addFolder('ROSE');
f7.add(parameter, 'drose').name('draw');
f7.add(parameter, 'n',1,30).step(1).name('n');
f7.add(parameter, 'd',1,30).step(1).name('d');
f7.add(parameter, 'o',0,4).step(0.01).name('o');

var f8 = gui1.addFolder('BUTTERFLY');
f8.add(parameter, 'dbutterfly').name('draw');

var f9 = gui1.addFolder('PORCUPINE');
f9.add(parameter, 'dporcupine').name('draw');
f9.add(parameter, 'pins',1,100).step(2).name('pins');

var f10 = gui1.addFolder('GRAFFITI');
f10.add(parameter, 'dgraffiti').name('draw');

gui1.add(parameter2, 'make').name('SUBMIT JOB');

f7.open();

String[] gcode = { "" };
String[] txt = { "" };
int[] gfx = {};
int[] gfy = {};
int[] rl = {};
ArrayList vx;
ArrayList vy;
int row = 0;
int rowsum = 0;

int[] curvesx = {};
int[] curvesy = {};

//starz
int sides = 9;
int angle = 0;
float ir = 0;

//heart
float t, tmin = -PI, tmax = PI, tdif = .01;
t = tmin;
int radius2 = 0;
float offset = 0;
int feedrate = parameter.feedrate; //mm/min
int plungerate = parameter.plungerate; //mm/min
float z = -1; //(change back to -1)depth of cut mm
float sh = 4; //safe height 
int pn = 1;//number of passes
float pd = z/pn;//pass depth when pn > 1
float zd = z;//display z
int wax = parameter.wax;//work area of machine (mm)
int way = parameter.way;
float sf = $(window).height()/way;  //display scale factor
int width = wax*sf;
int height = $(window).height()-30;
float tool_diameter = 3.175;
float thickness = parameter.thick;
int verts = parameter.verts;  
float rotate = 0;
float x = 0;
float y = 0;
float x2 = 0;
float y2 = 0;
int pX = parameter.pX;
int pY = parameter.pY;
int scolor = color(0,128,255);
float radius = parameter.radius;  //radius of polygon

PFont font;
String[] fontList = PFont.list();
String[] raw;

public void setup(){
   size(width, height);
   background(0);
   strokeWeight(tool_diameter);
   strokeJoin(ROUND);
   strokeCap(ROUND);
   stroke(255);
   noFill();
   cursor(CROSS);
   //textSize(18);
   smooth();
   vx = new ArrayList(); 
   vy = new ArrayList(); 

   //textMode(SHAPE); 
   font = createFont("txt", 32);
   //font = loadFont("txt.ttf");
   font2 = createFont("monospace", 18);
   textFont(font);
   frameRate(16);
}

public void draw() {

   if(parameter.resize == true){
      resize();
   }

   resizeSketch();
   thickness = parameter.thickness;
   feedrate = parameter.feedrate;
   plungerate = parameter.plungerate;
   verts = parameter.verts;
   pX = parameter.pX*sf;
   pY = parameter.pY*sf;
   rotate = radians(parameter.rotate);
   z = parameter.cut_depth;
   pd = z/pn;
   zd = z;
   tool_diameter = parameter.td;
   pn = parameter.pn;
   parameter.pd = pd;
   parameter.safe_height = sh;

   if(parameter.gcode == 1){
      console.log('hi');
      makegcode();
   }

   //display working area of machine
   String bgcolor = colorparameterect.color;
   bgcolor = "ff" + bgcolor.substring(1);
   fill(unhex(bgcolor));
   stroke(255,255,0);
   strokeWeight(0);
   rect(0,$(window).height()-(way*sf)-100,(wax*sf)*2,$(window).height()*2);
   fill(221);

   //display parameters
   //text(bgcolor, wax*sf-160,60);

   //font
   textFont(font,parameter.size*sf);
   text(txt, pX, height-pY);

   textFont(font2);
   textSize(18);
   text("x:", 10,30);
   text("y:", 10,50);
   text(nf((height-mouseY)/sf,1), 30,50);
   text(nf(mouseX/sf,1), 30,30);

   if(parameter.show_section == true){
      section();
   }

   noStroke();//draw x y axis & origin
   fill(0,204,0);
   rect(0,height-way*sf,2,way*sf);
   fill(204,0,0);
   rect(0,height-2,wax*sf,height);
   fill(255,255,0);
   rect(0,$(window).height()-3,3,3);
   translate(0, height);
   scale(1,-1);

   radius2 = parameter.radius-tool_diameter/2;

   //pocket
   if(parameter.pocketon == true){

   //display pocket path settings
   stroke(200);
   noFill();
   strokeWeight(1);//display cut width

      for(radius = 0; radius <= radius2-(tool_diameter*0.9); radius = radius+tool_diameter*0.9){
         polygon();

      }  
   }
   
   //display shapes

   centerpoint();
   strokeWeight(tool_diameter*sf);//display cut width
   radius = radius2;


   if(parameter.dgraffiti == true){
      graffiti();
   }

   if(parameter.drose == true){
      rose();
   }

   if(parameter.dbutterfly == true){
      butterfly();
   }

   if(parameter.dporcupine == true){
      porcupine();
   }

   if(parameter.dpolygon == true){
      polygon();
   } 

   if(parameter.dstar == true){
      starz();
   } 

   if(parameter.dheart == true){
      dheart();
   }  

   if (mousePressed && (mouseButton == LEFT)){
      pX=mouseX;
      pY=height-mouseY;
      parameter.pX = pX/sf;
      parameter.pY = pY/sf;
   }
//end draw
}

void keyPressed(){

   if(keyCode == BACKSPACE){
      txt = txt.substring (0,txt.length()-1);
   }
   else if((key != CODED) && (key != TAB) && (key != ESC) && (key != DELETE)){
      txt = txt + key.toString();
   }

   //key BACKSPACE, TAB, ENTER, RETURN, ESC, and DELETE

   if (keyCode == LEFT){
      parameter.pX -= 1;
   }
   if (keyCode == RIGHT){
      parameter.pX += 1;
   }
   if (keyCode == UP){
      parameter.pY += 1;
   }
   if (keyCode == DOWN){
      parameter.pY -= 1;
   }
   if (key == ENTER){
      //parameter.gcode = 1;
      //maketxt();
   }

}

void section(){
   //draw material section view
   fill(160,82,45);
   rect(0,height,width,0-thickness*sf);
   fill(0,51,153);
   rect(pX-tool_diameter/2*sf,height-thickness*sf,tool_diameter*sf,abs(z)*sf);
   fill(255,0,0);
}

void makegcode(){
   header();
   if((parameter.pocketon == false) && (parameter.dpolygon == true)){  
      makepolygon();
   }
   if((parameter.pocketon == true) && (parameter.dpolygon == true)){
      makepolygonpocket();
   }
   if(parameter.dstar == true){
      makestarz();
   }

   if(parameter.dheart == true){
      makeheart();
   }

   if(parameter.drose == true){
      makerose();
   }

   if(parameter.dbutterfly == true){
      makebutterfly();
   }

   if(parameter.dporcupine == true){
      makeporcupine();
   }
   if(parameter.dgraffiti == true){
      makegraffiti();
   }

   footer(); 

   //make file string
   String[] sa = reverse(gcode);
   String g = join(sa, "\n");
   date = new Date();

   //format date
   second = nf(date.getSeconds(),2);
   hours = nf(date.getHours(),2);
   minutes = nf(date.getMinutes(),2);
   month = nf(date.getMonth()+1,2);
   day = nf(date.getDate(),2);

   //console.log(g);

   fabmo.submitJob({
      file : g,
      filename : "shape_mm_" + date.getFullYear() + "-" + month + "-" + day + "_" + hours + "." + minutes + "." + second + ".g",
      name : "shape_mm_" + date.getFullYear() + "-" + month + "-" + day + "_" + hours + "." + minutes + "." + second,
      description : "Generated by ShapeMaker" 
   });

   translate(0, height);
   scale(1,-1);
   parameter.gcode = 0;
   g="";
  
}

void header(){

   translate(0, height);
   scale(1,-1);
   gcode = splice(gcode," ",1);//inch g20
   gcode = splice(gcode,"g21",1);//inch g20
   gcode = splice(gcode,"g0z"+nf(sh,1,3),1); //go safe height
   gcode = splice(gcode,"g0x0y0",1); //go home
   gcode = splice(gcode,"m3",1);//turn on router

}

void footer(){
   gcode = splice(gcode,"m5",1);
   gcode = splice(gcode,"g0x0y0z"+nf(sh,1,3),1);
   gcode = splice(gcode,"m30",1);
}

void makepolygon(){   
   //first pass
   z = pd;
   int pn2 = pn - 1;
  
   for (int i = 0; i <= verts; i++) {
      x = (pX/sf+sin(TWO_PI/verts*i+rotate)*radius);
      y = (pY/sf+cos(TWO_PI/verts*i+rotate)*radius);  
      if (i == 0){
         gcode = splice(gcode,"g0x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);//go to first cut
         gcode = splice(gcode,"g4p0.5",1);
         gcode = splice(gcode,"g1z" + nf(pd,1,3) + "f" + plungerate,1); //go to cut depth
         gcode = splice(gcode,"g4p0.5",1);
         gcode = splice(gcode,"f" + feedrate,1);
      }
      else{
         gcode = splice(gcode,"g1x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);
      }
   } 
   //done first pass

   //if multiple pass
   while (pn2 != 0){
      pd = pd + z;
      for (int i = 0; i <= verts; i++){
         x = (pX/sf+sin(TWO_PI/verts*i+rotate)*radius);
         y = (pY/sf+cos(TWO_PI/verts*i+rotate)*radius);
         if (i == 0){
            gcode = splice(gcode,"g1z" + nf(pd,1,3) + "f" + plungerate,1); //go to cut depth
            gcode = splice(gcode,"g4p0.5",1);
            gcode = splice(gcode,"f" + feedrate,1);
            gcode = splice(gcode,"g1x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);
         }
         else{
            gcode = splice(gcode,"g1x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);
         }
      } 
      pn2 = pn2 -1;
   }

   gcode = splice(gcode,"g0z"+nf(sh,1,3),1);
   //reset
   z = parameter.cut_depth;
   pn = parameter.pn;
   pd = z/pn;
}

void makepolygonpocket(){
   radius2=radius;
   //multipass
   z = pd;
   int pn2 = pn - 1;
   for(radius = 0; radius < radius2-tool_diameter*0.9; radius = radius+tool_diameter*0.9){
      for (int i = 0; i <= verts; i++){
         x = (pX/sf+sin(TWO_PI/verts*i+rotate)*radius);
         y = (pY/sf+cos(TWO_PI/verts*i+rotate)*radius);
         if (i == 0 && radius ==0){
            gcode = splice(gcode,"g0x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);//go to first cut
            gcode = splice(gcode,"g1" + nf(pd,1,3) + "f" + plungerate,1); //go to cut depth
            gcode = splice(gcode,"g4p0.5",1);
            gcode = splice(gcode,"f" + feedrate,1);
            radius = tool_diameter*0.3;
         }
         else{
            gcode = splice(gcode,"g1x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);
         }
      } 
   }

   //if multiple passes 
   while (pn2 != 0){
      pd = pd + z;
      for(radius = 0; radius < radius2-tool_diameter*0.9; radius = radius+tool_diameter*0.9){
         for (int i = 0; i <= verts; i++){
            x = (pX/sf+sin(TWO_PI/verts*i+rotate)*radius);
            y = (pY/sf+cos(TWO_PI/verts*i+rotate)*radius);
            if (i == 0 && radius ==0){
               gcode = splice(gcode,"g0z" + nf(sh,1,3),1);
               gcode = splice(gcode,"g0x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);//go to first cut
               gcode = splice(gcode,"g1z" + nf(pd,1,3) + "f" + plungerate,1); //go to cut depth
               gcode = splice(gcode,"g4p0.5",1);
               gcode = splice(gcode,"f" + feedrate,1);
               radius = tool_diameter*0.4;

            }
            else{
               gcode = splice(gcode,"g1x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);
            }
         } 
      }
      pn2 = pn2 -1;
   }

   //reset pass depth
   pd = z;
   //go to safe height
   gcode = splice(gcode,"g1z" + nf(sh,1,3),1);
   //finish pass
   makepolygon();
   //end pocket
}

void mouseOver(){
   scolor = color(200,100,200);
}

void mouseOut(){
   scolor = color(0,128,255);
}

void makestarz(){
   //first pass
   z = pd;
   int pn2 = pn - 1;

   for (int i = 0; i <= parameter.points; i++){ 
      x = pX/sf+sin(TWO_PI/parameter.points*i+rotate)*(radius);
      y = pY/sf+cos(TWO_PI/parameter.points*i+rotate)*(radius);  
      ir = radius/parameter.ir;
      x2 = pX/sf+sin(TWO_PI/parameter.points*i+rotate+radians(360/(parameter.points*2)))*(ir);
      y2 = pY/sf+cos(TWO_PI/parameter.points*i+rotate+radians(360/(parameter.points*2)))*(ir);
      if (i == 0){
         gcode = splice(gcode,"g0x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);//go to first cut
         gcode = splice(gcode,"g4p0.5",1);
         gcode = splice(gcode,"g1z" + nf(pd,1,3) + "f" + plungerate,1); //go to cut depth
         gcode = splice(gcode,"g4p0.5",1);
         gcode = splice(gcode,"f" + feedrate,1);
         gcode = splice(gcode,"g1x" + nf(x2, 1, 3) + "y" + nf(y2, 1, 3),1);
      }
      if ((i > 0) && (i < parameter.points)){
         gcode = splice(gcode,"g1x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);
         gcode = splice(gcode,"g1x" + nf(x2, 1, 3) + "y" + nf(y2, 1, 3),1);
      }
      if (i == parameter.points){
         gcode = splice(gcode,"g1x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);
      }
   } 
   //done first pass

   //if multiple pass
   while (pn2 != 0){
      pd = pd + z;
      for (int i = 0; i <= parameter.points; i++){ 
         x = pX/sf+sin(TWO_PI/parameter.points*i+rotate)*(radius);
         y = pY/sf+cos(TWO_PI/parameter.points*i+rotate)*(radius);  
         x2 = pX/sf+sin(TWO_PI/parameter.points*i+rotate+radians(360/(parameter.points*2)))*(ir);
         y2 = pY/sf+cos(TWO_PI/parameter.points*i+rotate+radians(360/(parameter.points*2)))*(ir);
         if (i == 0){
            gcode = splice(gcode,"g1z" + nf(pd,1,3) + "f" + plungerate,1); //go to cut depth
            gcode = splice(gcode,"g4p0.5",1);
            gcode = splice(gcode,"f" + feedrate,1);
            gcode = splice(gcode,"g1x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);
            gcode = splice(gcode,"g1x" + nf(x2, 1, 3) + "y" + nf(y2, 1, 3),1);
         }
         if ((i > 0) && (i < parameter.points)){
            gcode = splice(gcode,"g1x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);
            gcode = splice(gcode,"g1x" + nf(x2, 1, 3) + "y" + nf(y2, 1, 3),1);
         }
         if (i == parameter.points){
            gcode = splice(gcode,"g1x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);
         }
      } 
      pn2 = pn2 -1;
   }

   gcode = splice(gcode,"g0z"+nf(sh,1,3),1);
   //reset
   z = parameter.cut_depth;
   pn = parameter.pn;
   pd = z/pn;
}

void centerpoint(){
   fill(255,150,0);
   noStroke();
   ellipse(pX,pY,5,5);
   noFill();
   stroke(scolor);
}

void rose(){
   beginShape(); 
   for (int i = 0; i <= verts; i++){

      T=(TWO_PI*parameter.d/verts*i);
      float r=cos(parameter.n/parameter.d*T+rotate)+parameter.o;
      x = pX-r*sin(T)*(radius*sf);
      y = pY-r*cos(T)*(radius*sf);
      vertex(x, y);
   }
   endShape();
}

void porcupine(){
   beginShape(); 
   for (int i = 0; i <= verts; i++){ 
      float T=(TWO_PI/verts*i);
      float r=sin(parameter.pins*T)-2*cos(T);
      x = pX-r*sin(T-rotate)*(radius/2*sf);
      y = pY-r*cos(T-rotate)*(radius/2*sf);
      vertex(x, y);
   }
   endShape();
}


void butterfly(){
   beginShape(); 
   for (int i = 0; i <= verts; i++){ 
      float T=(TWO_PI/verts*i);
      float e=exp(1.0);
      float r=pow(e,sin(T))-(2*cos(4*T))+pow(sin((2*T-PI)/24),5);
      x = pX+r*cos(T-rotate)*(radius/3*sf);
      y = pY+r*sin(T-rotate)*(radius/3*sf);
      vertex(x, y);
   }
   endShape();
}


void polygon(){
   beginShape(); 
   for (int i = 0; i <= verts; i++){ 
      x = pX+sin(TWO_PI/verts*i+rotate)*(radius*sf);
      y = pY+cos(TWO_PI/verts*i+rotate)*(radius*sf);
      vertex(x, y);
   }
   endShape();
}

void starz(){
   beginShape();
   for (int i = 0; i <= parameter.points; i++){ 
      x = pX+sin(TWO_PI/parameter.points*i+rotate)*(radius*sf);
      y = pY+cos(TWO_PI/parameter.points*i+rotate)*(radius*sf);  
      vertex(x, y);
      ir = radius/parameter.ir;
      x = pX+sin(TWO_PI/parameter.points*i+rotate+radians(360/(parameter.points*2)))*(ir*sf);
      y = pY+cos(TWO_PI/parameter.points*i+rotate+radians(360/(parameter.points*2)))*(ir*sf);
      vertex(x, y);
   }
   endShape();
}

void dheart(){
   beginShape();
   for (float i = 0; i <= verts; i = i+0.5){
      float T = (TWO_PI/verts*i);
      float sint = sin(TWO_PI/verts*i), cost = cos(TWO_PI/verts*i);
      float r = (sin(T) * sqrt(abs(cos(T))))/(sin(T)+ 1.4) - 2*sin(T) + 2+parameter.k;
      x = pX+r*cos(T+rotate)*(radius/4*sf);
      y = pY+r*sin(T+rotate)*(radius/4*sf);
      vertex(x,y);
   }
   endShape();
}

void makeheart(){  
   //first pass
   z = pd;
   int pn2 = pn - 1;
      for (float i = 0; i <= verts; i = i+ 0.5){
         float T = (TWO_PI/verts*i);
         float sint = sin(TWO_PI/verts*i), cost = cos(TWO_PI/verts*i);
         float r = (sin(T) * sqrt(abs(cos(T))))/(sin(T)+ 1.4) - 2*sin(T) + 2+parameter.k;
         x = pX/sf+r*cos(T+rotate)*(radius/4);
         y = pY/sf+r*sin(T+rotate)*(radius/4); 
      if (i == 0){
         gcode = splice(gcode,"g0x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);//go to first cut
         gcode = splice(gcode,"g4p0.5",1);
         gcode = splice(gcode,"g1z" + nf(pd,1,3) + "f" + plungerate,1); //go to cut depth
         gcode = splice(gcode,"g4p0.5",1);
         gcode = splice(gcode,"f" + feedrate,1);
      }
      else{
         gcode = splice(gcode,"g1x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);
      }
   } 
   //done first pass

   //if multiple pass
   while (pn2 != 0){
      pd = pd + z;
      for (float i = 0; i <= verts; i = i+ 0.5){
         float T = (TWO_PI/verts*i);
         float sint = sin(TWO_PI/verts*i), cost = cos(TWO_PI/verts*i);
         float r = (sin(T) * sqrt(abs(cos(T))))/(sin(T)+ 1.4) - 2*sin(T) + 2+parameter.k;
         x = pX/sf+r*cos(T+rotate)*(radius/4);
         y = pY/sf+r*sin(T+rotate)*(radius/4); 
         if (i == 0){
            gcode = splice(gcode,"g1z" + nf(pd,1,3) + "f" + plungerate,1); //go to cut depth
            gcode = splice(gcode,"g4p0.5",1);
            gcode = splice(gcode,"f" + plungerate,1);
            gcode = splice(gcode,"g1x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);
         }
         else{
            gcode = splice(gcode,"g1x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);
         }
      } 
      pn2 = pn2 -1;
   }

   gcode = splice(gcode,"g0z"+nf(sh,1,3),1);
   //reset
   z = parameter.cut_depth;
   pn = parameter.pn;
   pd = z/pn;
}

void makerose(){   
   //first pass
   z = pd;
   int pn2 = pn-1;
  
   for (int i = 0; i <= verts; i++){
      T=(PI*parameter.d/verts*i);
      float r=cos(parameter.n/parameter.d*T+rotate)+parameter.o;
      x = pX/sf-r*sin(T)*(radius);
      y = pY/sf-r*cos(T)*(radius);
      if (i == 0){
         gcode = splice(gcode,"g0x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);//go to first cut
         gcode = splice(gcode,"g1z" + nf(pd,1,3) + "f" + plungerate,1); //go to cut depth
         gcode = splice(gcode,"g4p0.5",1);//for drawing
         gcode = splice(gcode,"f" + feedrate,1);
      }
      else{
         gcode = splice(gcode,"g1x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);
      }
   } 
   //done first pass
   //if multiple pass
   while (pn2 != 0){
      pd = pd + z;
      for (int i = 0; i <= verts; i++){
         int k = parameter.n/parameter.d;
         T=(PI*parameter.d/verts*i);
/*
         if ((k & 1) == 0){
            float T=(TWO_PI*2*parameter.d/verts*i);//even
         } 
         else{
            float T=(TWO_PI*parameter.d/verts*i);//odd
         }
*/
         float r=cos(parameter.n/parameter.d*T+rotate)+parameter.o;
         x = pX/sf-r*sin(T)*(radius);
         y = pY/sf-r*cos(T)*(radius);

         if (i == 0){
            gcode = splice(gcode,"g1z" + nf(pd,1,3) + "f" + plungerate,1); //go to cut depth
            gcode = splice(gcode,"g4p0.5",1);
            gcode = splice(gcode,"f" + feedrate,1);
            gcode = splice(gcode,"g1x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);
         }
         else{
            gcode = splice(gcode,"g1x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);
         }
      } 
      pn2 = pn2 -1;
   }
   gcode = splice(gcode,"g0z"+nf(sh,1,3),1);
   //reset
   z = parameter.cut_depth;
   pn = parameter.pn;
   pd = z/pn;
}

void makebutterfly(){   
   //first pass
   z = pd;
   int pn2 = pn - 1;
     
   for (int i = 0; i <= verts; i++){

      float T=(TWO_PI/verts*i);
      float e=exp(1.0);
      float r=pow(e,sin(T))-(2*cos(4*T))+pow(sin((2*T-PI)/24),5);

      x = pX/sf+r*cos(T-rotate)*(radius/3);
      y = pY/sf+r*sin(T-rotate)*(radius/3);

      if (i == 0){
         gcode = splice(gcode,"g0x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);//go to first cut
         gcode = splice(gcode,"g4p0.5",1);
         gcode = splice(gcode,"g1z" + nf(pd,1,3) + "f" + plungerate,1); //go to cut depth
         gcode = splice(gcode,"g4p0.5",1);
         gcode = splice(gcode,"f" + feedrate,1);
      }
      else{
         gcode = splice(gcode,"g1x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);
      }
   } 
   //done first pass

   //if multiple pass
   while (pn2 != 0){
      pd = pd + z;
      for (int i = 0; i <= verts; i++){
         float T=(TWO_PI/verts*i);
         float e=exp(1.0);
         float r=pow(e,sin(T))-(2*cos(4*T))+pow(sin((2*T-PI)/24),5);
         x = pX/sf+r*cos(T-rotate)*(radius/3);
         y = pY/sf+r*sin(T-rotate)*(radius/3);
         if (i == 0){
            gcode = splice(gcode,"g1z" + nf(pd,1,3) + "f" + plungerate,1); //go to cut depth
            gcode = splice(gcode,"g4p0.5",1);
            gcode = splice(gcode,"f" + feedrate,1);
            gcode = splice(gcode,"g1x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);
         }
         else{
            gcode = splice(gcode,"g1x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);
         }
      } 
      pn2 = pn2 -1;
   }
   gcode = splice(gcode,"g0z"+nf(sh,1,3),1);
   //reset
   z = parameter.cut_depth;
   pn = parameter.pn;
   pd = z/pn;
}


void makeporcupine(){   
   //first pass
   z = pd;
   int pn2 = pn - 1;
  
   for (int i = 0; i <= verts; i++){

      float T=(TWO_PI/verts*i);
      float r=sin(parameter.pins*T)-2*cos(T);

      x = pX/sf-r*sin(T-rotate)*(radius/2);
      y = pY/sf-r*cos(T-rotate)*(radius/2);

      if (i == 0){
         gcode = splice(gcode,"g0x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);//go to first cut
         gcode = splice(gcode,"g4p0.5",1);
         gcode = splice(gcode,"g1z" + nf(pd,1,3) + "f" + plungerate,1); //go to cut depth
         gcode = splice(gcode,"g4p0.5",1);
         gcode = splice(gcode,"f" + feedrate,1);
      }
      else{
         gcode = splice(gcode,"g1x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);
      }
   } 
   //done first pass

   //if multiple pass
   while (pn2 != 0){
      pd = pd + z;
      for (int i = 0; i <= verts; i++){

         float T=(TWO_PI/verts*i);
         float r=sin(parameter.pins*T)-2*cos(T);
         x = pX/sf-r*sin(T-rotate)*(radius/2);
         y = pY/sf-r*cos(T-rotate)*(radius/2);

         if (i == 0){
            gcode = splice(gcode,"g1z" + nf(pd,1,3) + "f" + plungerate,1); //go to cut depth
            gcode = splice(gcode,"g4p0.5",1);
            gcode = splice(gcode,"f" + feedrate,1);
            gcode = splice(gcode,"g1x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);
         }
         else{
            gcode = splice(gcode,"g1x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);
         }
      } 
   pn2 = pn2 -1;
   }
   gcode = splice(gcode,"g0z"+nf(sh,1,3),1);
   //reset
   z = parameter.cut_depth;
   pn = parameter.pn;
   pd = z/pn;
}



void graffiti(){
   if (mousePressed && (mouseButton == LEFT)) {
      gfx = splice(gfx,pX/sf);
      gfy = splice(gfy,pY/sf);   
      beginShape();
      for (int i = gfx.length-2; i > 0; i--) {
         vertex(gfx[i]*sf,gfy[i]*sf);
      }
      endShape();
   }

if(row>0){
   int i2 = row;
   while (i2 > 0){
      i2--;
      curvesx=vx.get(i2);
      curvesy=vy.get(i2);
      beginShape();
      for (int i = curvesx.length-2; i > 0; i--){
         vertex(curvesx[i]*sf,curvesy[i]*sf);
      }
      endShape();
      }
   }
}

void mouseReleased() {

   if((parameter.dgraffiti == true) && (mouseButton == LEFT)){
      vx.add(gfx);
      vy.add(gfy);
      gfx={};
      gfy={};
      row++;
      //println(row);
   }
}


void mousePressed(){
   if ((mouseButton == RIGHT) && (parameter.dgraffiti == true)){
      row--;
      vx.remove(row);
      vy.remove(row);
      //println(row);    
   }   
}

void makegraffiti(){   
//first pass

   int i2 = 0;
   while (i2 < row){
      z = pd;
      int pn2 = pn - 1;

      curvesx=vx.get(i2);
      curvesy=vy.get(i2);
  
      for (int i = curvesx.length-2; i > 0; i--){

         x = curvesx[i];
         y = curvesy[i];

         if (i == curvesx.length-2){
            gcode = splice(gcode,"g0x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);//go to first cut
            gcode = splice(gcode,"g1z" + nf(pd,1,3) + "f" + plungerate,1); //go to cut depth
            gcode = splice(gcode,"g4p0.5",1);
            gcode = splice(gcode,"f" + feedrate,1);
         }
         else{
            gcode = splice(gcode,"g1x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);
         }
      } 
      //done first pass
      //if multiple pass
      while (pn2 != 0){
         pd = pd + z;
         for (int i = curvesx.length-2; i > 0; i--){

            x = curvesx[i];
            y = curvesy[i];

            if (i == curvesx.length-2){
               gcode = splice(gcode,"g0z"+nf(sh,1,3),1);
               gcode = splice(gcode,"g1x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);
               gcode = splice(gcode,"g1z" + nf(pd,1,3) + "f" + plungerate,1); //go to cut depth
               gcode = splice(gcode,"g4p0.5",1);
               gcode = splice(gcode,"f" + feedrate,1);
            }
            else{
               gcode = splice(gcode,"g1x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);
            }
         } 

         pn2 = pn2--;
      }

      gcode = splice(gcode,"g0z"+nf(sh,1,3),1);

      //reset
      z = parameter.cut_depth;
      pn = parameter.pn;
      pd = z/pn;
      i2++;
   }
}

public void resizeSketch(){
   sf = $(window).height()/way;
   height = $(window).height()-30;
   size(wax*sf, height);
}

public void resize(){
   way=parameter.way;
   wax=parameter.wax;
}


