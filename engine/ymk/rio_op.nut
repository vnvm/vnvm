/*
SPECIAL FLAGS:
	993 - TEXT_SPEED
	996 - DISABLE SAVE
*/

class RIO_OP
{
	</ id=0x28, format="12", description="" />
	static function UNK_28(param, text)
	{
		this.TODO();
	}

	</ id=0x55, format="1", description="" />
	static function UNK_55(unk)
	{
		this.TODO();
	}
	
	</ id=0x61, format="1s", description="" />
	static function MOVIE(can_stop, name)
	{
		local movie = Movie();
		movie.load(::path_to_files + "/" + name);
		movie.viewport(0, 0, screen.w, screen.h);
		movie.play();
		while (movie.playing) {
			mouse.update();
			keyboard.update();
			if (can_stop) {
				if (mouse.pressed(0)) break;
			}
			movie.update();
			Screen.frame(30);
		}
		movie.stop();
	}
	
	</ id=0x64, format="4", description="" />
	static function UNK_64(unk1)
	{
		this.TODO();
	}

	</ id=0x68, format="2221", description="" />
	static function UNK_68(unk1, unk2, unk3, unk4)
	{
		this.TODO();
	}

	</ id=0x85, format="2", description="" />
	static function UNK_85(param)
	{
		this.TODO();
	}

	</ id=0x86, format="2", description="" />
	static function UNK_86(unk1)
	{
		this.TODO();
	}

	</ id=0x89, format="1", description="" />
	static function UNK_89(unk)
	{
		this.TODO();
	}

	</ id=0x8C, format="21", description="" />
	static function UNK_8C(unk1, unk2)
	{
		this.TODO();
	}

	</ id=0x8E, format="1", description="" />
	static function UNK_8E()
	{
		this.TODO();
	}
}