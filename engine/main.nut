include("common.nut");
include("tests.nut");

if ((info.argv.len() >= 2) && (info.argv[1] == "qload")) {
	info.auto_quick_load <- true;
	local subgame_path = "pw";
	if (info.argv.len() >= 3) subgame_path = info.argv[2];
	info.game_data_path <- info.game_data_path + "/" + subgame_path;
}

//include("test.nut");

if (exists_in_game_path_any(["chip.arc"])) {
	// -----------------
	// Will engine
	// -----------------
	// Yume Miru Kusuri
	// Princess Waltz
	// Enzai
	// Absolute Obedience
	include("ymk/main.nut");
} else if (exists_in_game_path_any(["SG.DL1"])) {
	// -----------------
	// C's games
	// -----------------
	// Dividead
	// ...
	include("dividead/main.nut");
} else if (exists_in_game_path_any(["MRS"])) {
	// -----------------
	// True love
	// -----------------
	// True love
	include("tlove/main.nut");
} else if (exists_in_game_path_any(["sysprg.arc"])) {
	// -----------------
	// Ethornell
	// -----------------
	// Shuffle!
	// Edelweiss
	// ...
	include("shuffle/main.nut");
} else if (exists_in_game_path_any(["MSD", "SE", "VOICE"])) {
	// -----------------
	// Sono hanabira
	// -----------------
	// Sono hanabira
	include("hanabira/main.nut");
} else {
	include("game_selector/main.nut");
	//printf("Not detected any compatible Visual Novel\n");
}
