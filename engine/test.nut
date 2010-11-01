screen <- Screen.init(640, 480);

local testbmp = Bitmap(800, 600, 32);
testbmp.clear([1, 0, 0, 1]);

local alpha = 0.0;

while (1) {
	screen.clear([0, 0, 1, 1]);
	::input.update();
	
	testbmp = Bitmap(800, 600, 32);
	
	//image_color.drawTransition(screen, image_mask, 0, 0, alpha, "", 0);
	screen.drawBitmap(testbmp);
	//image_color.draw(screen);
	//printf("%d, %d : %d, %d : %d               \r", ::input.mouse.x, ::input.mouse.y, ::input.mouse.dx, ::input.mouse.dy, ::input.mouse.dwheel);
	
	printf("%d\n", ::input.keyboard.pressed("f2"));
	
	Screen.flip();
	Screen.frame(30);
	alpha += 0.01;
	if (alpha > 1) alpha = 0.0;
}

