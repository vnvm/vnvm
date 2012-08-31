include("shuffle/lz.nut");
include("shuffle/pac.nut");
include("shuffle/dgp.nut");

local path_to_files = "c:/juegos/shuffle";

local pac_sg = PAC(path_to_files + "/sg.pac");
local pac_bg = PAC(path_to_files + "/bg.pac");
{
	screen_init(800, 600, 800, 600);
	local bg    = DGP(pac_bg["BG016A.GPD"]);
	local chara = DGP(pac_sg["SGAS13AA.GPD"]);
	
	while (true) {
		bg.draw();
		chara.draw(800 / 2 - chara.w / 2, 0);
		frame(15);
	}
}