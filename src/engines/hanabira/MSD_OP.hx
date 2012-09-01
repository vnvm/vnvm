package engines.hanabira;

/**
 * ...
 * @author soywiz
 */

class MSD_OP
{
	</ id=1, description="Sets the line number" />
	function LINE_NUMBER(line)
	{
		
	}

	</ id=5, description="Sets a flag value" />
	function FLAG_SET(flag, value)
	{
		
	}

	</ id=6, description="Jump" />
	function JUMP(flag, unk1, unk2, unk3)
	{
		
	}
	
	</ id=100, description="Background" />
	function SET_BACKGROUND(unknown, file)
	{
		this.scene.background.mgd = ::MGD(::paks["MGD"].get(file + ".MGD"));
	}

	</ id=102, description="Set character image" />
	function CHARACTER_IMAGE(index, file)
	{
		if (file == 0 || file == "DAMMY") {
			this.scene.characters[index].mgd = null;
		} else {
			//printf("CHARACTER_IMAGE\n");
			this.scene.characters[index].mgd = ::MGD(::paks["MGD"].get(file + ".MGD"));
		}
	}

	</ id=103, description="Set character image" />
	function CHARACTER_POSITION(index, x, y, unk)
	{
		local character = this.scene.characters[index];
		//character.x = x;
		//character.y = y;
		//this.scene.updateLayerDraw();
		//this.scene.copyLayerShowToDraw();
	}

	/*</ id=104, description="Set character image" />
	function CHARACTER_POSITION(index, file)
	{
	}*/

	</ id=110, description="Performs a transition" />
	function TRANSITION(unk1, time_ms, unk2, file)
	{
		
		if (file != "" && file != 0) {
			this.scene.transitionMask = ::MGD(::paks["MGD"].get(file + ".MGD")).image;
		}

		local timer = Timer(time_ms);
		this.scene.stepf = 0.0;
		while (timer.elapsedf < 1.0) {
			::input.update();
			timer.update(1000 / 30);
			this.scene.drawTo(::screen);
			Screen.flip();
			Screen.frame(30);
			this.scene.stepf = timer.elapsedf;
		}
		this.scene.copyLayerShowToDraw();
	}

	</ id=201, description="Set background music" />
	function MUSIC(file, unk1, unk2, unk3)
	{
		
	}

	</ id=1005, description="Set title" />
	function SET_CHAPTER_TITLE(title)
	{
		
	}

	</ id=2001, description="Set text color" />
	function SET_TEXT_COLOR(type, r, g, b)
	{
		
	}
	
	</ id=2008, description="Set voice file" />
	function SET_VOICE_FILE(text_id, file)
	{
		
	}

	</ id=2010, description="Set text" />
	function SET_TEXT(text_id, unk1, unk2, file, unk3, unk4)
	{
		
	}

	</ id=2009, description="Do a frame" />
	function WAIT_TEXT()
	{
		MSD_OP.TRANSITION(0, 200, 0, "");
		/*while (true) {
			::input.update();
			this.scene.drawTo(::screen);
			Screen.flip();
			Screen.frame(30);
		}*/
	}
}
