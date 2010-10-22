include("utils/math.nut");
include("utils/string.nut");
include("utils/file.nut");
include("utils/translation.nut");
include("utils/component.nut");
include("utils/animation.nut");
include("utils/input.nut");
include("utils/timer.nut");

info.game_data_path <- info.engine_path + "/../game_data";
info.game_save_path <- info.engine_path + "/../game_save";
info.game_lang <- "es";
info.auto_quick_load <- false;

printf("Information:\n");
printf("  Platform: %s\n", info.platform);
printf("  Native resolution: %dx%d\n", info.native_width, info.native_height);
printf("  Engine path: %s\n", info.engine_path);
printf("  Game data path: %s\n", info.game_data_path);
printf("  Game save path: %s\n", info.game_save_path);
printf("  Game language: %s\n", info.game_lang);
printf("  Game argv: %s\n", object_to_string(info.argv));

;
//printf("  TEST BINARY: %d\n", ("z" + "\0z").len());

function loop_forever(fps = 40)
{
	while (1) { Screen.flip(); Screen.frame(40); }
}

//printf("%f", rgba("7FFFFF")[0]);