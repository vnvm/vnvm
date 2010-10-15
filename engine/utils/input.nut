class Input extends Component
{
	keyboard = null;
	mouse    = null;
	joypad   = null;

	constructor()
	{
		this.mouse    = Mouse();
		this.keyboard = Keyboard();
		this.joypad   = Joypad();
	}

	function update(elapsed_time = 0)
	{
		this.mouse.update();
		this.keyboard.update();
		this.joypad.update();
	}
	
	function setVibration(left = 1.0, right = 1.0, time = 20, wait = 0)
	{
		this.joypad.setVibration(left, right, time, wait);
	}
	
	function pad_pressed(key)
	{
		return this.joypad.pressed(key) || this.keyboard.pressed(key);
	}

	function pad_pressing(key)
	{
		return this.joypad.pressing(key) || this.keyboard.pressing(key);
	}
	
	function mouseInRect(rect)
	{
		return pointInRect({x=mouse.x, y=mouse.y}, rect);
	}
	
	function mouseMoved()
	{
		return (mouse.dx != 0) && (mouse.dy != 0);
	}
}

input <- Input();