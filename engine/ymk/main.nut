include("ymk/tbl.nut");
include("ymk/anm.nut");
include("ymk/arc.nut");
include("ymk/state.nut");
include("ymk/rio_op.nut");
include("ymk/rio_op_anim.nut");
include("ymk/rio_op_audio.nut");
include("ymk/rio_op_flow.nut");
include("ymk/rio_op_text.nut");
include("ymk/rio_op_timer.nut");
include("ymk/rio_op_scene.nut");
include("ymk/rio_op_menus.nut");
include("ymk/rio_op_effects.nut");
include("ymk/rio.nut");
include("ymk/wip.nut");
include("ymk/resman.nut");

Audio.init();

//screen_init(640, 480, 800, 600);
screen <- Screen.init(800, 600, 800, 600);

sceneLayerShow  <- Bitmap(800, 600);
sceneLayerDraw  <- Bitmap(800, 600);
sceneLayerMixed <- Bitmap(800, 600);

resman <- RESMAN();

//path_to_files <- "c:/juegos/yume";
//path_to_files <- "C:/projects/svn2.tales-tra.com/yume/port/ARC";
path_to_files <- info.game_data_path + "/ymk";

arc <- ARC_CONTAINER();
arc.add(path_to_files + "/Se.arc");
arc.add(path_to_files + "/Bgm.arc");
arc.add(path_to_files + "/Chip.arc");
arc.add(path_to_files + "/Rio.arc");
arc.add(path_to_files + "/Voice.arc");

rio <- RIO();

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

rio.load("START").execute();
//rio.load("MAINMENU").execute();
//rio.load("t001_01", 1, 0x0000161F).execute();
//rio.load("t001_01", 1, 0x48E1).execute();
//rio.load("t001_01", 1, 0x5D19).execute();
//rio.load("t001_01").execute();
//rio.load("EVCHK").execute();

//arc_bgm.print(); local music = Music.fromStream(arc_bgm["BGM07.OGG"]); music.play(); loop_forever();
//local sound = Sound.fromStream(arc_voice["AEKA0062.OGG"]); sound.play(); loop_forever();
