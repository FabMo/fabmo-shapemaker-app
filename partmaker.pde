//2015
//jward

//dat.gui 
var obj = {
	material : 0,
	thickness : 12.6,
	machine : "FabMO",
	feedrate : 1200,
	plungerate : 1000,
	cut_depth : -3,
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
	dstar : true,
	dspiral : false,
	drose : false,
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
	resize : false
}

var ColorObject = function() {
	this.color = "#000000";
}

var colorObject = new ColorObject();

var obj2 = { make:function(){ obj.gcode=1 });
var gui1 = new dat.GUI({ load: JSON });
gui1.remember(obj);

var f1 = gui1.addFolder('MACHINE PARAMETERS');
f1.add(obj, 'machine').name('');
f1.addColor(colorObject, 'color').name('bg color');
f1.add(obj, 'units', { mm:0 } );
f1.add(obj, 'material', { plywood:0} );
f1.add(obj, 'thickness', 0.1, 30.1).step(0.1).name('thickness');
f1.add(obj, 'feedrate', 0, 20000).step(1);
f1.add(obj, 'plungerate', 0, 1000).step(1);
f1.add(obj, 'td', 0, 10.7).step(1.5875).name('tool diameter');
f1.add(obj, 'cut_depth', -25, 1).name('cut depth').step(1);
f1.add(obj, 'pn', 1, 10).name('# of passes').step(1);
f1.add(obj, 'pd').name('pass depth').listen();
f1.add(obj, 'safe_height', 0, 10).name('safe height').step(0.5);
f1.add(obj, 'way', 0, 500).name('y max').step(1);
f1.add(obj, 'wax', 0, 500).name('x max').step(1);
f1.add(obj, 'resize').name('resize');
f1.add(obj, 'show_section').name('show section');

var f2 = gui1.addFolder('SHAPE PARAMETERS');
f2.add(obj, 'pX', 0,170).listen().name('X center');
f2.add(obj, 'pY', 0,210).listen().name('Y center');
f2.add(obj, 'rotate',-360,360).step(1);
f2.add(obj, 'radius',1.1,120).step(0.01);
f2.add(obj, 'verts',1,2000).step(1).name('vertices');

var f3 = gui1.addFolder('POLYGON');
//f3.add(obj, 'shape')
f3.add(obj, 'dpolygon').name('draw');
f3.add(obj, 'pocketon').name('pocket');

//var f4 = gui1.addFolder('SPIRAL');
//f4.add(obj, 'dspiral').name('draw');
//f4.add(obj, 'turns',1,12).step(1);

var f5 = gui1.addFolder('STAR');
f5.add(obj, 'dstar').name('draw');
f5.add(obj, 'points',2,200).step(1);
f5.add(obj, 'ir',0.1,25).step(0.1).name('inside ratio');

var f6 = gui1.addFolder('HEART');
f6.add(obj, 'dheart').name('draw');
f6.add(obj, 'k',-10,10).step(0.1).name('k');

var f7 = gui1.addFolder('ROSE');
f7.add(obj, 'drose').name('draw');
f7.add(obj, 'n',1,30).step(1).name('n');
f7.add(obj, 'd',1,30).step(1).name('d');
f7.add(obj, 'o',0,4).step(0.01).name('o');

var f8 = gui1.addFolder('BUTTERFLY');
f8.add(obj, 'dbutterfly').name('draw');

var f9 = gui1.addFolder('PORCUPINE');
f9.add(obj, 'dporcupine').name('draw');
f9.add(obj, 'pins',1,100).step(2).name('pins');

var f10 = gui1.addFolder('GRAFFITI');
f10.add(obj, 'dgraffiti').name('draw');

gui1.add(obj2, 'make').name('MAKE CUT FILE');

f5.open();

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

//star
int sides = 9;
int angle = 0;
float ir = 0;

//heart
float t, tmin = -PI, tmax = PI, tdif = .01;
t = tmin;

//spiral
float theta = 0;
int turns = 3;

int radius2 = 0;
float offset = 0;
int feedrate = obj.feedrate; //mm/min
int plungerate = obj.plungerate; //mm/min
float z = -1; //(change back to -1)depth of cut mm
float sh = 4; //safe height 
int pn = 1;//number of passes
float pd = z/pn;//pass depth when pn > 1
float zd = z;//display z

int wax = obj.wax; //work area of machine (mm)
int way = obj.way;

float sf = $(window).height()/way;  //display scale factor

//int width = wax*sf+2;
//int height = way*sf;
int width = wax*sf;
int height = $(window).height()-30;

float tool_diameter = 3.175;
float thickness = obj.thick;
int verts = obj.verts;  
float rotate = 0;
float x = 0;
float y = 0;
float x2 = 0;
float y2 = 0;
int pX = obj.pX;
int pY = obj.pY;
int scolor = color(0,128,255);

float radius = obj.radius;  //radius of polygon

//font
//font = loadFont("txt.ttf");

PFont font;
String[] fontList = PFont.list();
String[] raw;

public void setup() {
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
}

public void draw() 
{
	if(obj.resize == true){
		resize();
	}
	resizeSketch();

	thickness = obj.thickness;
	feedrate = obj.feedrate;
	plungerate = obj.plungerate;
	verts = obj.verts;
	pX = obj.pX*sf;
	pY = obj.pY*sf;
	rotate = radians(obj.rotate);
	z = obj.cut_depth;
	pd = z/pn;
	zd = z;
	tool_diameter = obj.td;
	pn = obj.pn;
	obj.pd = pd;
	obj.safe_height = sh;

	if(obj.gcode == 1) {
		makegcode();
	}

	//display working area of machine

	String bgcolor = colorObject.color;
	bgcolor = "ff" + bgcolor.substring(1);
	fill(unhex(bgcolor));

	stroke(255,255,0);
	strokeWeight(0);
	rect(0,$(window).height()-(way*sf)-100,(wax*sf)*2,$(window).height()*2);
	fill(221);

	//display parameters
	//text(bgcolor, wax*sf-160,60);

	//font
	textFont(font,obj.size*sf);
	text(txt, pX, height-pY);

	textFont(font2);
	textSize(18);
	text("x:", 10,30);
	text("y:", 10,50);
	text(nf((height-mouseY)/sf,1), 30,50);
	text(nf(mouseX/sf,1), 30,30);

	if(obj.show_section == true) {
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

	radius2 = obj.radius-tool_diameter/2;

	//pocket
	if(obj.pocketon == true)
	{

		//display pocket path settings
		stroke(200);
		noFill();
		strokeWeight(1);//display cut width

		//polygon pocket from inside
		for(radius = 0; radius <= radius2-(tool_diameter*0.9); radius = radius+tool_diameter*0.9)
		{
			polygon();
			//if(obj.dpolygon == true){
			//polygon();
			//}
		}
	}

	//display shapes

	centerpoint();

	strokeWeight(tool_diameter*sf);//display cut width
	radius = radius2;

	turns = obj.turns;
	theta =0;
	if(obj.dspiral == true){
		while(turns > 0) {
			spiral();
			turns -= 1;
		}
	}

	if(obj.dgraffiti == true){
		graffiti();
	}

	if(obj.drose == true){
		rose();
	}

	if(obj.dbutterfly == true){
		butterfly();
	}

	if(obj.dporcupine == true){
		porcupine();
	}


	if(obj.dpolygon == true){
		polygon();
	} 

	if(obj.dstar == true){
		starz();
	} 

	if(obj.dheart == true){
		dheart();
	}  

	if (mousePressed && (mouseButton == LEFT)) {
		pX=mouseX;
		pY=height-mouseY;
		obj.pX = pX/sf;
		obj.pY = pY/sf;
	}

} // draw()

void keyPressed()
{

	if(keyCode == BACKSPACE) {
		txt = txt.substring (0,txt.length()-1);
	}
	else if((key != CODED) && (key != TAB) && (key != ESC) && (key != DELETE)) {
		txt = txt + key.toString();
	}

	//key BACKSPACE, TAB, ENTER, RETURN, ESC, and DELETE

	if (keyCode == LEFT) {
		obj.pX -= 1;
	}
	if (keyCode == RIGHT) {
		obj.pX += 1;
	}
	if (keyCode == UP) {
		obj.pY += 1;
	}
	if (keyCode == DOWN) {
		obj.pY -= 1;
	}
	if (key == ENTER) {
		//obj.gcode = 1;
		//maketxt();
	}

	/*
	if ((key == 'h') || (key == 'H'))
	{
	println("the H key hides the GUI");
	println("press H again to show the GUI");
	}
	*/
}

void section() {
	//draw material section view
	fill(160,82,45);
	rect(0,height,width,0-thickness*sf);
	fill(0,51,153);
	rect(pX-tool_diameter/2*sf,height-thickness*sf,tool_diameter*sf,abs(z)*sf);
	fill(255,0,0);
}

void makegcode() 
{
	header();
	if((obj.pocketon == false) && (obj.dpolygon == true)) {  
		makepolygon();
	}

	if((obj.pocketon == true) && (obj.dpolygon == true)) {
		makepolygonpocket();
	}

	if(obj.dstar == true) {
		makestarz();
	}

	if(obj.dheart == true) {
		makeheart();
	}

	if(obj.drose == true) {
		makerose();
	}

	if(obj.dbutterfly == true) {
		makebutterfly();
	}

	if(obj.dporcupine == true) {
		makeporcupine();
	}
	
	if(obj.dgraffiti == true) {
		makegraffiti();
	}

	/*
	else
	{
	alert("no shape to draw");
	translate(0, height);
	scale(1,-1);
	obj.gcode = 0;
	return;
	}
	*/
	footer(); 

	//make file & download link
	String[] sa = reverse(gcode);
	String g = join(sa, "\n");
	var date = new Date();

	//format date
	second = nf(date.getSeconds(),2);
	hours = nf(date.getHours(),2);
	minutes = nf(date.getMinutes(),2);
	month = nf(date.getMonth()+1,2);
	day = nf(date.getDate(),2);

	/*
	var link = document.getElementById("download-link");

	link.setAttribute("href", "data:text/plain;base64," + btoa(g));

	//filename
	//link.setAttribute("download", "gcode_mm_" + date.getFullYear() + "-" + month + "-" + day + "_" + hours + "." + minutes + "." + second + ".g");

	link.setAttribute("download", "partmaker.g");
	//download(link);

	link.style.display = "none";
	link.click();
	//window.location.href = 'data:image/octet-stream;base64,' + btoa(g);
	*/
	fabmoDashboard.submitJob(g, { filename : "gcode_mm_" + date.getFullYear() + "-" + month + "-" + day + "_" + hours + "." + minutes + "." + second + ".g", name : 'PartMaker', description : 'Generated by PartMaker' });

	var reload = document.getElementById("reload");
	reload.setAttribute("href", "javascript:history.go(0)");
	reload.style.display = "inline";

	translate(0, height);
	scale(1,-1);
	obj.gcode = 0;
  
}

// write gcode
void header() {
	translate(0, height);
	scale(1,-1);
	//gcode header
	//gcode = splice(gcode,"(units=mm/min)",1);
	gcode = splice(gcode,"g21",1);//inch g20
	gcode = splice(gcode,"g0z"+nf(sh,1,3),1); //go safe height
	gcode = splice(gcode,"g0x0y0",1); //go home
	//gcode = splice(gcode,"MS," + feedrate + "," + plungerate,1); //cutting and plunge rate
	gcode = splice(gcode,"m3",1);//turn on router
	//gcode = splice(gcode,"g4p0.5",1);
}

void footer() {
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
		if (i == 0) {
			gcode = splice(gcode,"g0x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);//go to first cut
			gcode = splice(gcode,"g4p0.5",1);
			gcode = splice(gcode,"g1z" + nf(pd,1,3) + "f" + plungerate,1); //go to cut depth
			gcode = splice(gcode,"g4p0.5",1);
			gcode = splice(gcode,"f" + feedrate,1);
		}
		else {
		gcode = splice(gcode,"g1x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);
		}
	} 
	//done first pass

	//if multiple pass
	while (pn2 != 0)
	{
		pd = pd + z;
		for (int i = 0; i <= verts; i++)  {
			x = (pX/sf+sin(TWO_PI/verts*i+rotate)*radius);
			y = (pY/sf+cos(TWO_PI/verts*i+rotate)*radius);
			if (i == 0) {
				gcode = splice(gcode,"g1z" + nf(pd,1,3) + "f" + plungerate,1); //go to cut depth
				gcode = splice(gcode,"g4p0.5",1);
				gcode = splice(gcode,"f" + feedrate,1);
				gcode = splice(gcode,"g1x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);
			}
			else {
				gcode = splice(gcode,"g1x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);
			}
		} 
		pn2 = pn2 -1;
	}

	gcode = splice(gcode,"g0z"+nf(sh,1,3),1);
	//reset
	z = obj.cut_depth;
	pn = obj.pn;
	pd = z/pn;
}

void makepolygonpocket() {

	radius2=radius;
	//multipass
	z = pd;
	int pn2 = pn - 1;
	for(radius = 0; radius < radius2-tool_diameter*0.9; radius = radius+tool_diameter*0.9)
	{
    
		for (int i = 0; i <= verts; i++) 
		{
			x = (pX/sf+sin(TWO_PI/verts*i+rotate)*radius);
			y = (pY/sf+cos(TWO_PI/verts*i+rotate)*radius);
		    
			if (i == 0 && radius ==0)
			{
				gcode = splice(gcode,"g0x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);//go to first cut
				gcode = splice(gcode,"g1" + nf(pd,1,3) + "f" + plungerate,1); //go to cut depth
				gcode = splice(gcode,"g4p0.5",1);
				gcode = splice(gcode,"f" + feedrate,1);
				radius = tool_diameter*0.3;
			}
			else {
				gcode = splice(gcode,"g1x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);
			}
		}
	}

	//if multiple passes 
	while (pn2 != 0) {
		pd = pd + z;
		for(radius = 0; radius < radius2-tool_diameter*0.9; radius = radius+tool_diameter*0.9) {
			for (int i = 0; i <= verts; i++) {
				x = (pX/sf+sin(TWO_PI/verts*i+rotate)*radius);
				y = (pY/sf+cos(TWO_PI/verts*i+rotate)*radius);

				if (i == 0 && radius ==0) {
					gcode = splice(gcode,"g0z" + nf(sh,1,3),1);
					gcode = splice(gcode,"g0x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);//go to first cut
					gcode = splice(gcode,"g1z" + nf(pd,1,3) + "f" + plungerate,1); //go to cut depth
					gcode = splice(gcode,"g4p0.5",1);
					//gcode = splice(gcode,"M2," + nf(x, 1, 3) + "," + nf(y, 1, 3),1);
					gcode = splice(gcode,"f" + feedrate,1);
					radius = tool_diameter*0.4;
				}
				else {
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

void mouseOver() {
	scolor = color(200,100,200);
}

void mouseOut() {
	scolor = color(0,128,255);
}

void makestarz()
{
	//first pass
	z = pd;
	int pn2 = pn - 1;
	  

	for (int i = 0; i <= obj.points; i++) { 
		x = pX/sf+sin(TWO_PI/obj.points*i+rotate)*(radius);
		y = pY/sf+cos(TWO_PI/obj.points*i+rotate)*(radius);  

		ir = radius/obj.ir;

		x2 = pX/sf+sin(TWO_PI/obj.points*i+rotate+radians(360/(obj.points*2)))*(ir);
		y2 = pY/sf+cos(TWO_PI/obj.points*i+rotate+radians(360/(obj.points*2)))*(ir);
		//
		if (i == 0) {
			gcode = splice(gcode,"g0x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);//go to first cut
			gcode = splice(gcode,"g4p0.5",1);
			gcode = splice(gcode,"g1z" + nf(pd,1,3) + "f" + plungerate,1); //go to cut depth
			gcode = splice(gcode,"g4p0.5",1);
			gcode = splice(gcode,"f" + feedrate,1);
			gcode = splice(gcode,"g1x" + nf(x2, 1, 3) + "y" + nf(y2, 1, 3),1);
		}
		if ((i > 0) && (i < obj.points)) {
			gcode = splice(gcode,"g1x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);
			gcode = splice(gcode,"g1x" + nf(x2, 1, 3) + "y" + nf(y2, 1, 3),1);
		}

		if (i == obj.points) {
			gcode = splice(gcode,"g1x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);
		}
	} 
	//done first pass

	//if multiple pass
	while (pn2 != 0)
	{
		pd = pd + z;
		for (int i = 0; i <= obj.points; i++) 
		{ 
			x = pX/sf+sin(TWO_PI/obj.points*i+rotate)*(radius);
			y = pY/sf+cos(TWO_PI/obj.points*i+rotate)*(radius);  

			ir = radius/obj.ir;

			x2 = pX+sin(TWO_PI/obj.points*i+rotate+radians(360/(obj.points*2)))*(ir);
			y2 = pY+cos(TWO_PI/obj.points*i+rotate+radians(360/(obj.points*2)))*(ir);

			if (i == 0) {
				gcode = splice(gcode,"g1z" + nf(pd,1,3) + "f" + plungerate,1); //go to cut depth
				gcode = splice(gcode,"g4p0.5",1);
				gcode = splice(gcode,"f" + feedrate,1);
				gcode = splice(gcode,"g1x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);
			}
			if ((i > 0) && (i < obj.points)) {
				gcode = splice(gcode,"g1x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);
				gcode = splice(gcode,"g1x" + nf(x2, 1, 3) + "y" + nf(y2, 1, 3),1);
			}
			if (i == obj.points) {
				gcode = splice(gcode,"g1x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);
			}
		} 
		pn2 = pn2 -1;
	}
	gcode = splice(gcode,"g0z"+nf(sh,1,3),1);
	//reset
	z = obj.cut_depth;
	pn = obj.pn;
	pd = z/pn;
}

void centerpoint()
{
	fill(255,150,0);
	noStroke();
	ellipse(pX,pY,5,5);
	noFill();
	stroke(scolor);
}

void rose()
{
	beginShape(); 
	for (int i = 0; i <= verts; i++) {
		T=(TWO_PI*obj.d/verts*i);
		float r=cos(obj.n/obj.d*T+rotate)+obj.o;
		x = pX-r*sin(T)*(radius*sf);
		y = pY-r*cos(T)*(radius*sf);
		vertex(x, y);
	}
	endShape();
}

void porcupine() {
	beginShape(); 
	for (int i = 0; i <= verts; i++) 
	{ 
		float T=(TWO_PI/verts*i);
		float r=sin(obj.pins*T)-2*cos(T);

		x = pX-r*sin(T-rotate)*(radius/2*sf);
		y = pY-r*cos(T-rotate)*(radius/2*sf);
		vertex(x, y);
	}
	endShape();
}

void butterfly()
{
	beginShape(); 
	for (int i = 0; i <= verts; i++) 
	{ 
		float T=(TWO_PI/verts*i);
		float e=exp(1.0);
		float r=pow(e,sin(T))-(2*cos(4*T))+pow(sin((2*T-PI)/24),5);

		x = pX+r*cos(T-rotate)*(radius/3*sf);
		y = pY+r*sin(T-rotate)*(radius/3*sf);
		vertex(x, y);
	}
	endShape();
}

void polygon()
{
	beginShape(); 
	for (int i = 0; i <= verts; i++) 
	{ 
		x = pX+sin(TWO_PI/verts*i+rotate)*(radius*sf);
		y = pY+cos(TWO_PI/verts*i+rotate)*(radius*sf);
		vertex(x, y);
	}
	endShape();
}

void starz()
{

	beginShape();
	for (int i = 0; i <= obj.points; i++) 
	{ 
		x = pX+sin(TWO_PI/obj.points*i+rotate)*(radius*sf);
		y = pY+cos(TWO_PI/obj.points*i+rotate)*(radius*sf);  
		vertex(x, y);

		ir = radius/obj.ir;

		x = pX+sin(TWO_PI/obj.points*i+rotate+radians(360/(obj.points*2)))*(ir*sf);
		y = pY+cos(TWO_PI/obj.points*i+rotate+radians(360/(obj.points*2)))*(ir*sf);
		vertex(x, y);
	}
	endShape();
}

void dheart()
{
	beginShape();
	for (float i = 0; i <= verts; i = i+0.5) 
	{

		float T = (TWO_PI/verts*i);
		float sint = sin(TWO_PI/verts*i), cost = cos(TWO_PI/verts*i);
		float r = (sin(T) * sqrt(abs(cos(T))))/(sin(T)+ 1.4) - 2*sin(T) + 2+obj.k;
		x = pX+r*cos(T+rotate)*(radius/4*sf);
		y = pY+r*sin(T+rotate)*(radius/4*sf);

		vertex(x,y);
	}
	endShape();
}

void spiral()
{
	beginShape();
	for (int i = 0; i <= verts; i++)
	{
		x = pX+radius/3*sf*sin(TWO_PI/verts*i+rotate)*theta;
		y = pY+radius/3*sf*cos(TWO_PI/verts*i+rotate)*theta;
		vertex(x,y);
		theta += 1/verts;

		if(i == verts) {
			theta = theta-(1/verts);
		}
	} 
	endShape();
}

void makeheart()
{
	   
	//first pass
	z = pd;
	int pn2 = pn - 1;
	  
	for (float i = 0; i <= verts; i = i+ 0.5) {
		float T = (TWO_PI/verts*i);
		float sint = sin(TWO_PI/verts*i), cost = cos(TWO_PI/verts*i);
		float r = (sin(T) * sqrt(abs(cos(T))))/(sin(T)+ 1.4) - 2*sin(T) + 2+obj.k;

		x = pX/sf+r*cos(T+rotate)*(radius/4);
		y = pY/sf+r*sin(T+rotate)*(radius/4); 

		if (i == 0) {
			gcode = splice(gcode,"g0x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);//go to first cut
			gcode = splice(gcode,"g4p0.5",1);
			gcode = splice(gcode,"g1z" + nf(pd,1,3) + "f" + plungerate,1); //go to cut depth
			gcode = splice(gcode,"g4p0.5",1);
			gcode = splice(gcode,"f" + feedrate,1);
		}
		else {
			gcode = splice(gcode,"g1x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);
		}
	} 
	//done first pass

	//if multiple pass
	while (pn2 != 0) {
		pd = pd + z;
		for (float i = 0; i <= verts; i = i+ 0.5) 
		{
			float T = (TWO_PI/verts*i);
			float sint = sin(TWO_PI/verts*i), cost = cos(TWO_PI/verts*i);
			float r = (sin(T) * sqrt(abs(cos(T))))/(sin(T)+ 1.4) - 2*sin(T) + 2+obj.k;

			x = pX/sf+r*cos(T+rotate)*(radius/4);
			y = pY/sf+r*sin(T+rotate)*(radius/4); 

			if (i == 0) {
				gcode = splice(gcode,"g1z" + nf(pd,1,3) + "f" + plungerate,1); //go to cut depth
				gcode = splice(gcode,"g4p0.5",1);
				gcode = splice(gcode,"f" + plungerate,1);
				gcode = splice(gcode,"g1x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);
			}
			else {
				gcode = splice(gcode,"g1x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);
			}
		} 
		pn2 = pn2 -1;
	}

	gcode = splice(gcode,"g0z"+nf(sh,1,3),1);
	//reset
	z = obj.cut_depth;
	pn = obj.pn;
	pd = z/pn;
}    

void makerose(){   
	//first pass
	z = pd;
	int pn2 = pn - 1;
	  
	for (int i = 0; i <= verts; i++) {
		T=(TWO_PI*obj.d/verts*i);

		float r=cos(obj.n/obj.d*T+rotate)+obj.o;
		x = pX/sf-r*sin(T)*(radius);
		y = pY/sf-r*cos(T)*(radius);

		if (i == 0) {
			gcode = splice(gcode,"g0x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);//go to first cut
			gcode = splice(gcode,"g1z" + nf(pd,1,3) + "f" + plungerate,1); //go to cut depth
			gcode = splice(gcode,"g4p0.5",1);//for drawing
			gcode = splice(gcode,"f" + feedrate,1);
		}
		else {
			gcode = splice(gcode,"g1x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);
		}
	}

	//if multiple pass
	while (pn2 != 0)
	{
		pd = pd + z;
		for (int i = 0; i <= verts; i++) 
		{
			int k = obj.n/obj.d;
			if ((k & 1) == 0) {
				float T=(TWO_PI*2*obj.d/verts*i);//even
			} else {
				float T=(TWO_PI*obj.d/verts*i);//odd
			}

			float r=cos(obj.n/obj.d*T+rotate)+obj.o;
			x = pX/sf-r*sin(T)*(radius);
			y = pY/sf-r*cos(T)*(radius);

			if (i == 0) 
			{
				gcode = splice(gcode,"g1z" + nf(pd,1,3) + "f" + plungerate,1); //go to cut depth
				gcode = splice(gcode,"g4p0.5",1);
				gcode = splice(gcode,"f" + feedrate,1);
				gcode = splice(gcode,"g1x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);
			}
			else 
			{
				gcode = splice(gcode,"g1x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);
			}
		} 
		pn2 = pn2 -1;
	}

	gcode = splice(gcode,"g0z"+nf(sh,1,3),1);
	//reset
	z = obj.cut_depth;
	pn = obj.pn;
	pd = z/pn;
}

void makebutterfly() {   
	//first pass
	z = pd;
	int pn2 = pn - 1;
	  
	for (int i = 0; i <= verts; i++) {
		float T=(TWO_PI/verts*i);
		float e=exp(1.0);
		float r=pow(e,sin(T))-(2*cos(4*T))+pow(sin((2*T-PI)/24),5);

		x = pX/sf+r*cos(T-rotate)*(radius/3);
		y = pY/sf+r*sin(T-rotate)*(radius/3);

		if (i == 0) {
		gcode = splice(gcode,"g0x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);//go to first cut
		gcode = splice(gcode,"g4p0.5",1);
		gcode = splice(gcode,"g1z" + nf(pd,1,3) + "f" + plungerate,1); //go to cut depth
		gcode = splice(gcode,"g4p0.5",1);
		gcode = splice(gcode,"f" + feedrate,1);
		}
		else {
		gcode = splice(gcode,"g1x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);
		}
	} 

	//if multiple pass
	while (pn2 != 0) {
		pd = pd + z;
		for (int i = 0; i <= verts; i++) {
			float T=(TWO_PI/verts*i);
			float e=exp(1.0);
			float r=pow(e,sin(T))-(2*cos(4*T))+pow(sin((2*T-PI)/24),5);

			x = pX/sf+r*cos(T-rotate)*(radius/3);
			y = pY/sf+r*sin(T-rotate)*(radius/3);

			if (i == 0) {
				gcode = splice(gcode,"g1z" + nf(pd,1,3) + "f" + plungerate,1); //go to cut depth
				gcode = splice(gcode,"g4p0.5",1);
				gcode = splice(gcode,"f" + feedrate,1);
				gcode = splice(gcode,"g1x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);
			}
			else {
				gcode = splice(gcode,"g1x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);
			}
		} 
		pn2 = pn2 -1;
	}
	gcode = splice(gcode,"g0z"+nf(sh,1,3),1);
	
	//reset
	z = obj.cut_depth;
	pn = obj.pn;
	pd = z/pn;
}

void makeporcupine(){   
	//first pass
	z = pd;
	int pn2 = pn - 1;
	  
	for (int i = 0; i <= verts; i++) {
		float T=(TWO_PI/verts*i);
		float r=sin(obj.pins*T)-2*cos(T);

		x = pX/sf-r*sin(T-rotate)*(radius/2);
		y = pY/sf-r*cos(T-rotate)*(radius/2);

		if (i == 0) {
			gcode = splice(gcode,"g0x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);//go to first cut
			gcode = splice(gcode,"g4p0.5",1);
			gcode = splice(gcode,"g1z" + nf(pd,1,3) + "f" + plungerate,1); //go to cut depth
			gcode = splice(gcode,"g4p0.5",1);
			gcode = splice(gcode,"f" + feedrate,1);
		}
		else {
			gcode = splice(gcode,"g1x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);
		}
	} 

	//if multiple pass
	while (pn2 != 0) {
		pd = pd + z;
		for (int i = 0; i <= verts; i++) {

			float T=(TWO_PI/verts*i);
			float r=sin(obj.pins*T)-2*cos(T);

			x = pX/sf-r*sin(T-rotate)*(radius/2);
			y = pY/sf-r*cos(T-rotate)*(radius/2);
		
			if (i == 0) {
				gcode = splice(gcode,"g1z" + nf(pd,1,3) + "f" + plungerate,1); //go to cut depth
				gcode = splice(gcode,"g4p0.5",1);
				gcode = splice(gcode,"f" + feedrate,1);
				gcode = splice(gcode,"g1x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);
			}
			else {
				gcode = splice(gcode,"g1x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);
			}
		} 
		pn2 = pn2 -1;
	}
	gcode = splice(gcode,"g0z"+nf(sh,1,3),1);
	
	//reset
	z = obj.cut_depth;
	pn = obj.pn;
	pd = z/pn;
}

void graffiti()
{

	if (mousePressed && (mouseButton == LEFT)) {
		gfx = splice(gfx,pX/sf);
		gfy = splice(gfy,pY/sf);

		beginShape();
		for (int i = gfx.length-2; i > 0; i--) {
			vertex(gfx[i]*sf,gfy[i]*sf);
		}
		endShape();
	}

	if(row >0) {
		int i2 = row;
		while (i2 > 0)
		{
			i2--;
			curvesx=vx.get(i2);
			curvesy=vy.get(i2);

			beginShape();
			for (int i = curvesx.length-2; i > 0; i--) {
			vertex(curvesx[i]*sf,curvesy[i]*sf);
			}
			endShape();
		}
	}

}

void mouseReleased() {

	if(obj.dgraffiti == true){

		vx.add(gfx);
		vy.add(gfy);

		gfx={};
		gfy={};

		row++;

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

	  
		for (int i = curvesx.length-2; i > 0; i--) {
			x = curvesx[i];
			y = curvesy[i];

			if (i == curvesx.length-2) {
				gcode = splice(gcode,"g0x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);//go to first cut
				gcode = splice(gcode,"g1z" + nf(pd,1,3) + "f" + plungerate,1); //go to cut depth
				gcode = splice(gcode,"g4p0.5",1);
				gcode = splice(gcode,"f" + feedrate,1);
			}
			else {
				gcode = splice(gcode,"g1x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);
			}
		} 

		//if multiple pass
		while (pn2 != 0) {
			pd = pd + z;
			for (int i = curvesx.length-2; i > 0; i--) {
				x = curvesx[i];
				y = curvesy[i];

				if (i == curvesx.length-2) {
					gcode = splice(gcode,"g0z"+nf(sh,1,3),1);
					gcode = splice(gcode,"g1x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);
					gcode = splice(gcode,"g1z" + nf(pd,1,3) + "f" + plungerate,1); //go to cut depth
					gcode = splice(gcode,"g4p0.5",1);
					gcode = splice(gcode,"f" + feedrate,1);
				}
				else {
					gcode = splice(gcode,"g1x" + nf(x, 1, 3) + "y" + nf(y, 1, 3),1);
				}
			} 
			pn2 = pn2 -1;
		}
		gcode = splice(gcode,"g0z"+nf(sh,1,3),1);

		//reset
		z = obj.cut_depth;
		pn = obj.pn;
		pd = z/pn;
		i2++;
	}
}

public void resizeSketch() {
	sf = $(window).height()/way;
	height = $(window).height()-30;
	size(wax*sf, height);
}

public void resize()
{
	way=obj.way;
	wax=obj.wax;
}


