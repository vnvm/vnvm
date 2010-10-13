include("common.nut");

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
	// True love
	// -----------------
	// True love
	include("shuffle/main.nut");
} else {
	include("game_selector/main.nut");
	//printf("Not detected any compatible Visual Novel\n");
}
