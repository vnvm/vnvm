path_to_files <- info.game_data_path;

if (exists_in_game_path_any(["prwaltz.exe"])) {
	engine_version <- "pw"; // Princess Waltz
} else if (exists_in_game_path_any(["yumemiru.exe"])) {
	engine_version <- "ymk"; // Yume Miru Kusuri
} else {
	engine_version <- "unknown";
}

printf("Detected engine: '%s'\n", engine_version);

include("ymk/formats/tbl.nut");
include("ymk/formats/anm.nut");
include("ymk/formats/arc.nut");
include("ymk/formats/wip.nut");

include("ymk/state.nut");
include("ymk/scene.nut");
include("ymk/interface.nut");
include("ymk/rio_op.nut");
include("ymk/rio_op_table.nut");
include("ymk/rio_op_audio.nut");
include("ymk/rio_op_flow.nut");
include("ymk/rio_op_text.nut");
include("ymk/rio_op_timer.nut");
include("ymk/rio_op_scene.nut");
include("ymk/rio_op_menus.nut");
include("ymk/rio_op_effects.nut");
switch (engine_version) {
	case "ymk": include("ymk/rio_op_version_ymk.nut"); break;
	case "pw" : include("ymk/rio_op_version_pw.nut" ); break;
}
include("ymk/rio.nut");
include("ymk/resman.nut");

Audio.init();

//screen_init(640, 480, 800, 600);
screen <- Screen.init(800, 600, 800, 600);

sceneLayerShow  <- Bitmap(800, 600);
sceneLayerDraw  <- Bitmap(800, 600);
sceneLayerMixed <- Bitmap(800, 600);

resman <- RESMAN();

arc <- ARC_CONTAINER();
// Common arcs.
arc.add(path_to_files + "/Se.arc");
arc.add(path_to_files + "/Bgm.arc");
arc.add(path_to_files + "/Chip.arc");
arc.add(path_to_files + "/Rio.arc");
arc.add(path_to_files + "/Voice.arc");

switch (engine_version) {
	case "pw":
		arc.add(path_to_files + "/CARDIMG.arc");
		arc.add(path_to_files + "/Chip_0.arc");
		arc.add(path_to_files + "/Chip_1.arc");
		arc.add(path_to_files + "/Chip_2.arc");
		arc.add(path_to_files + "/Chip_3.arc");
		arc.add(path_to_files + "/Chip_4.arc");
		arc.add(path_to_files + "/Chip_5.arc");
		arc.add(path_to_files + "/Chip_6.arc");
		arc.add(path_to_files + "/Chip_A.arc");
		arc.add(path_to_files + "/Chip_B.arc");
		arc.add(path_to_files + "/Chip_C.arc");
		arc.add(path_to_files + "/Chip_D.arc");
		arc.add(path_to_files + "/Chip_E.arc");
		arc.add(path_to_files + "/Chip_F.arc");
		arc.add(path_to_files + "/Chip_G.arc");
		arc.add(path_to_files + "/Chip_H.arc");
		arc.add(path_to_files + "/Chip_I.arc");
		arc.add(path_to_files + "/Chip_J.arc");
		arc.add(path_to_files + "/Chip_K.arc");
		arc.add(path_to_files + "/Chip_L.arc");
		arc.add(path_to_files + "/Chip_M.arc");
		arc.add(path_to_files + "/Chip_N.arc");
		arc.add(path_to_files + "/Chip_O.arc");
		arc.add(path_to_files + "/Chip_P.arc");
		arc.add(path_to_files + "/Chip_Q.arc");
		arc.add(path_to_files + "/Chip_R.arc");
		arc.add(path_to_files + "/Chip_S.arc");
		arc.add(path_to_files + "/Chip_T.arc");
		arc.add(path_to_files + "/Chip_U.arc");
		arc.add(path_to_files + "/Chip_V.arc");
		arc.add(path_to_files + "/Chip_W.arc");
		arc.add(path_to_files + "/Chip_X.arc");
		arc.add(path_to_files + "/Chip_Y.arc");
		arc.add(path_to_files + "/Chip_Z.arc");
	break;
}

//RIO().load("CG_WAIT").save("CG_WAIT.BIN");
//RIO().load("pw0002_1").save("pw0002_1.BIN");
//RIO().load("pw0002_1").save("pw0002_1.BIN");
//RIO().load("SLG_SAVE").save("SLG_SAVE.BIN");
//RIO().load("BATTLE").save("BATTLE.BIN");
//RIO().load("CONTINUE").save("CONTINUE.BIN");
//pw0001

rio <- RIO();
rio.state.load_system();
rio.load("START");

switch (engine_version) {
	case "pw":
		//rio.state.flags_set_range_count(1050, 30, 1); // ENABLE BGM
		//rio.state.flags_set_range(1000, 2999, 1); // ENABLE ALL
	break;
	default: /*case "ymk":*/
		rio.state.flags_set_range(1051, 1067, 1); // ENABLE BGM

		rio.state.flags_set_range(1100, 1108, 1); // ENABLE CG (PAGE 1)
		rio.state.flags_set_range(1109, 1117, 1); // ENABLE CG (PAGE 2)
		rio.state.flags_set_range(1118, 1126, 1); // ENABLE CG (PAGE 3)
		rio.state.flags_set_range(1127, 1135, 1); // ENABLE CG (PAGE 4)
		rio.state.flags_set_range(1136, 1144, 1); // ENABLE CG (PAGE 5)
		rio.state.flags_set_range(1145, 1153, 1); // ENABLE CG (PAGE 6)
		rio.state.flags_set_range(1154, 1162, 1); // ENABLE CG (PAGE 7)
		rio.state.flags_set_range(1163, 1170, 1); // ENABLE CG (PAGE 8)

		rio.state.flags_set_range(1200, 1270, 1); // AEKA
		rio.state.flags_set_range(1271, 1339, 1); // KIRIMIYA
		rio.state.flags_set_range(1340, 1403, 1); // NEKOKO
		rio.state.flags_set_range(1404, 1412, 1); // MISC

		rio.state.flags_set_range(1500, 1512, 1); // ENABLE EVENTS (AEKA)
		rio.state.flags_set_range(1513, 1524, 1); // ENABLE EVENTS (KIRIMIYA)
		rio.state.flags_set_range(1525, 1538, 1); // ENABLE EVENTS (NEKOKO)
		rio.state.flags_set_range(1539, 1541, 1); // ENABLE EVENTS (AYA)
	break;
}

function export_images_to_translate() {
	for (local n = 1; n <= 18; n++) resman.get_image(format("EC_%03d", n)).export(path_to_files + "/translation/en");
	resman.get_image("MAIN_BGP").export(path_to_files + "/translation/en");
}

//resman.get_image("CG04_03").export(path_to_files + "/translation/en");
//resman.get_image("MAINIP").export(path_to_files + "/translation/en");
//resman.get_image("MAIN_AGP").export(path_to_files + "/translation/en");
//resman.get_image("EXTRAAGP").export(path_to_files + "/translation/en");

//resman.get_image("CONTINUE").export(path_to_files + "/translation/en");
//export_images_to_translate();

//resman.get_image("EC_001").images[0].save("EC_001.tga", "tga");
//resman.get_image("BG16_001").images[0].save("BG16_001.png", "png");
//resman.get_mask("EFMSK_19").images[0].save("EFMSK_19.png", "png");
//resman.get_mask("EFMSK_31").images[0].save("EFMSK_31.png", "png");
//resman.get_mask("EFMSK_19").images[0].save("EFMSK_19.bmp", "bmp");
//resman.get_mask("EFMSK_31").images[0].save("EFMSK_31.bmp", "bmp");


//rio.load("pw0001", 1, 0x6D48);
//rio.load("pw0001", 1, 0xC162);
//rio.load("pw0001", 1, 0x17664);
//rio.load("pw0001", 1, 0x7192);

//rio.load("pw0015_1", 1, 0x1779F);

//rio.load("pw0001", 1, 0xBC0A);
//rio.load("pw0002_1", 1, 0x2025);
// SLOW: RESMAN.Loading 'X1_AA01S'...
//rio.load("pw0001", 1, 0xBD21);

//rio.load("pw0001", 1, 0x3EDB);
//rio.load("pw0001", 1, 0x431A);
//rio.load("pw0001", 1, 0x43E7);
//rio.load("pw0015_1", 1, 0x17AED);
//rio.load("pw0015_1", 1, 0x9E11);
//rio.load("t001_02a", 1, 0x8B76);
//rio.load("pw0002_1", 1, 0xB249);
//rio.load("START");
//rio.load("MAINMENU")
//rio.load("t001_01", 1, 0x0000161F)
//rio.load("t001_01", 1, 0x48E1)
//rio.load("t001_01", 1, 0x5D19)
//rio.load("t001_01")
//rio.load("EVCHK")

//rio.save("MAINMENU.BIN");

if (info.auto_quick_load) {
	rio.state.load(100);
}

rio.execute();

//arc_bgm.print(); local music = Music.fromStream(arc_bgm["BGM07.OGG"]); music.play(); loop_forever();
//local sound = Sound.fromStream(arc_voice["AEKA0062.OGG"]); sound.play(); loop_forever();
