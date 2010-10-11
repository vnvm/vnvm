include("dividead/lz.nut");
include("dividead/dl1.nut");
include("dividead/sg.nut");
include("dividead/ab.nut");

local path_to_files = "c:/juegos/dividead";

local vfs = VFS([
	DL1(path_to_files + "/SG.DL1"),
	DL1(path_to_files + "/WV.DL1"),
]);

screen <- Screen.init(640, 480, 640, 480);	

local script = AB();
script.vfs = vfs;
script.set_script("AASTART");
script.execute();
