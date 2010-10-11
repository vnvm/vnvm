screen <- Screen.init(640, 480);

image_color <- Bitmap.fromFile("../game_data/2ico.jpg");
image_mask <- Bitmap.fromFile("../game_data/2mask.jpg");

//image_color.copyChannel(image_mask, "red", "alpha", 1);

/*
test2 <- Bitmap(640, 480);
test2.clear([0, 1, 0, 1]);




mask <- Bitmap(100, 100);
//mask.clear([0.2, 0.2, 0.2, 0.2]);
mask.clear([0, 0, 1, 0.5]);
test.copyChannel(mask, "blue", "blue");

test.draw(test2, 0, 0);
*/


/*while (1) {
	keyboard.update();
	printf("%d, %d : %d, %d\n", keyboard.dx, keyboard.dy, keyboard.pressing("lctrl"), keyboard.pressed("a"));
	
	Screen.frame(30);
}*/

local alpha = 0.0;

while (1) {
	screen.clear([0, 0, 1, 1]);
	mouse.update();
	/*
	test2.draw(screen, 10, 10, alpha);
	test.draw(screen, 600, 10);
	mask.draw(screen, 600, 200);
	*/
	
	image_color.drawTransition(screen, image_mask, 0, 0, alpha, "", 0);
	//image_color.draw(screen);
	printf("%d, %d : %d, %d : %d\r", mouse.x, mouse.y, mouse.dx, mouse.dy, mouse.dwheel);
	Screen.flip();
	Screen.frame(30);
	alpha += 0.01;
	if (alpha > 1) alpha = 0.0;
}

::screen.clear([0, 0, 0, 1]);
font <- Font("lucon.ttf", 16, 1);

font.print(::screen, "Hola", 16, 16, [1, 0, 0, 1]);

Screen.flip();
while (true) Screen.frame();

/*while (true) {
	input <- Screen.input();
	printf("%d, %d, %d\r", input.mouse.x, input.mouse.y, input.mouse.b);
	Screen.frame(60);
}*/

//local bmp = parsebmp(file("test.bmp", "rb"));

//while (true) { draw(bmp); frame(20); }

///*
{
	local data = blob(0);
	local pal = blob(0);

	for (local n = 0; n < 256; n++) data.writen(1, 'b');

	pal.writen(0xFF, 'b');
	pal.writen(0x00, 'b');
	pal.writen(0x00, 'b');
	pal.writen(0xFF, 'b');

	pal.writen(0x00, 'b');
	pal.writen(0xFF, 'b');
	pal.writen(0x00, 'b');
	pal.writen(0xFF, 'b');

	//Screen.init(800, 600, 800, 600);

	local bmp = Bitmap.fromData(data, 16, 16, 8, 1, pal, 4);
	//local bmp = Bitmap.fromFile("test.jpg");
	//local bmp = BMP.load(file("test.bmp", "rb"));

	print(bmp);
	
	screen.clear([1, 0, 0, 1]);
	screen.draw(bmp, 100, 100);
	Screen.flip();

	while (true) {
		Screen.frame(20);
	}

	//include("ymk/main.nut");
}
//*/