/*
SPECIAL FLAGS:
	993 - TEXT_SPEED
	996 - DISABLE SAVE

PRINCESS WALTZ:
	sub_406F00
*/

class RIO_OP_base
{
	</ id=0x28, format="12", description="" />
	static function UNK_28(param, text)
	{
		//this.interface.enabled = false;
		//gameStep();
		this.TODO();
	}
	
	/*
		pw0001@04DC: OP(0x86) : UNK_86_DELAY : [230,0]
		pw0001@04DC: OP(0x86) : UNK_86_DELAY : [230,0]...  @TODO
		pw0001@04DF: OP(0x01) : JUMP_IF : [3,998,0,20]
		pw0001@04EA: OP(0x03) : SET : [1,996,0,1]
		**SET 996=1
		pw0001@04F2: OP(0x82) : WAIT : [1000,0]
	*/

	</ id=0x86, format="11", description="" />
	static function UNK_86_DELAY(unk1, unk2)
	{
		if (unk1 > 0)
		{
			this.interface.enabled = false;
			//this.interface.enabled = 0;
			//gameStep();
		}
		this.TODO();
		//Screen.delay(unk1);
	}
	
	</ id=0x55, format="1", description="" />
	static function UNK_55(unk)
	{
		//this.interface.enabled = false;
		//gameStep();
		//this.interface.enabled = false;
		/*
		this.interface.enabled = true;
		this.interface.text_title = "";
		this.interface.text_body = "";
		*/
		this.TODO();
	}

	</ id=0x29, format="22", description="" />
	static function UNK_29(param1, param2)
	{
		this.TODO();
	}

	</ id=0x30, format="22", description="" />
	static function UNK_30(param1, param2)
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
		local timer = TimerComponent(500);
		while (movie.playing) {
			input.update();

			if (can_stop && timer.ended && pressedNext()) break;

			timer.update(this.ms_per_frame);
			movie.update();
			Screen.frame(30);
		}
		movie.stop();
	}

	</ id=0x62, format="1", description="" />
	static function UNK_62(param)
	{
		this.TODO();
	}

	</ id=0x64, format="1111", description="" />
	static function CHARA_PUT_INFO(unk1, unk2, unk3, unk4)
	{
		this.TODO();
	}

	</ id=0x84, format="1", description="" />
	static function UNK_84(param)
	{
		this.TODO();
	}

	</ id=0x85, format="2", description="" />
	static function UNK_85(param)
	{
		this.TODO();
	}

	</ id=0x88, format="111", description="" />
	static function UNK_88(unk1, unk2, unk3)
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
	static function UNK_8E(param)
	{
		this.TODO();
	}

	</ id=0xBD, format="2", description="" />
	static function UNK_BD(param)
	{
		this.TODO();
	}

	</ id=0xBE, format="1", description="" />
	static function UNK_BE(param)
	{
		this.TODO();
	}

	</ id=0xBC, format="22", description="" />
	static function UNK_BC(param1, param2)
	{
		this.TODO();
	}

	</ id=0xE5, format="1", description="" />
	static function UNK_E5(param)
	{
		this.TODO();
	}

	/*
	</ id=0xE6, format="...", description="" />
	static function UNK_E6()
	{
		this.TODO();
	}
	*/
}

switch (engine_version) {
	case "pw": // For Pricess Waltz.
		class RIO_OP extends RIO_OP_base
		{
			</ id=0x28, format=".....", description="" />
			static function UNK_28()
			{
				this.TODO();
			}

			</ id=0x64, format="111111", description="" />
			static function CHARA_PUT_INFO(index, unk2, unk3, unk4, unk5, unk6)
			{
				this.TODO();
			}
		}
	break;
	// For YMK and others.
	default:
	//case "ymk": 
		class RIO_OP extends RIO_OP_base
		{
		}
	break;
}