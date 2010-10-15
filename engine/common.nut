include("utils/math.nut");
include("utils/string.nut");
include("utils/file.nut");
include("utils/translation.nut");
include("utils/component.nut");
include("utils/animation.nut");
include("utils/input.nut");
include("utils/timer.nut");

info.game_data_path <- info.engine_path + "/../game_data";

printf("Information:\n");
printf("  Platform: %s\n", info.platform);
printf("  Native resolution: %dx%d\n", info.native_width, info.native_height);
printf("  Engine path: %s\n", info.engine_path);
printf("  Game data path: %s\n", info.game_data_path);

function loop_forever(fps = 40)
{
	while (1) { Screen.flip(); Screen.frame(40); }
}

//printf("%f", rgba("7FFFFF")[0]);