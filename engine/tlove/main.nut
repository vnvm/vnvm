include("tlove/mrs.nut");
include("tlove/pak.nut");
include("tlove/dat.nut");

//local path_to_files = "../data/tlove";
local path_to_files = "c:/juegos/tlove";

pak_mid <- PAK(path_to_files + "/MIDI");
pak_dat <- PAK(path_to_files + "/DATE");
pak_mrs <- PAK(path_to_files + "/MRS");
pak_eff <- PAK(path_to_files + "/EFF");

{
	screen <- Screen.init(640, 400);

	local dat = DAT();
	dat.set_script("MAIN.DAT");
	//dat.set_script("TITLE.DAT");
	//dat.set_script("701.DAT");
	dat.execute();
	return;

	/*
	local i_u = MRS(pak_mrs["AG030U.MRS"]);
	local i_d = MRS(pak_mrs["AG030D.MRS"]);
	local mrs = MRS(pak_mrs["AC010A.MRS"]);
	//local mrs2 = MRS(pak_mrs["AC010B.MRS"]);
	
	
	local y = 0;
	while (true) {
		screen.clear([1, 1, 1, 1]);
		//mrs2.draw(0, 100);
		{
			i_u.draw(0, y);
			i_d.draw(0, y + i_u.h);
			mrs.draw();
			y--;
		}
		Screen.flip();
		Screen.frame();
	}
	
	local z = mrs.image.split(32, 32);
	z[2].draw(screen);
	Screen.flip();
	while (1) Screen.frame();
	*/
}