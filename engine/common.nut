include("math.nut");

info.game_data_path <- info.engine_path + "/../game_data";

printf("Information:\n");
printf("  Platform: %s\n", info.platform);
printf("  Native resolution: %dx%d\n", info.native_width, info.native_height);
printf("  Engine path: %s\n", info.engine_path);
printf("  Game data path: %s\n", info.game_data_path);

mouse    <- Mouse();
keyboard <- Keyboard();
joypad   <- Joypad();

class Translation
{
	texts = null;
	
	function reset()
	{
		this.texts = {};
	}
	
	function get(text_id, text, title = "")
	{
		if (text_id in this.texts) {
			return this.texts[text_id];
		} else {
			return {
				text  = text,
				title = title,
			};
		}
	}

	function add(text_id, text, title = "")
	{
		this.texts[text_id] <- {
			text  = text,
			title = title,
		};
		//printf("%d: %s, %s", text_id, title, text);
	}
}

translation <- Translation();

class Timer
{
	start  = 0;
	length = 0;
	
	constructor(length = 0)
	{
		this.length = length;
		this.reset();
	}
	
	function increment(ms)
	{
		start -= ms;
	}
	
	function reset()
	{
		start  = ::time_ms();
	}
	
	function _get(name)
	{
		switch (name) {
			case "elapsed" : return ::time_ms() - this.start;
			case "elapsedf": return (::time_ms() - this.start).tofloat() / this.length.tofloat();
			case "ended"   : return (::time_ms() - this.start) >= this.length;
		}
	}
}

array_join <- function(array, separator) {
	local ret = "";
	for (local n = 0; n < array.len(); n++) {
		if (n != 0) ret += separator;
		ret += array[n];
	}
	return ret;
};

function loop_forever(fps = 40)
{
	while (1) { Screen.flip(); Screen.frame(40); }
}

function object_to_string(v)
{
	switch (type(v)) {
		case "instance":
			return typeof v;
		break;
		case "array":
			local vv = [];
			foreach (c in v) vv.push(object_to_string(c));
			return "[" + array_join(vv, ",") + "]";
		break;
		case "string":
			return "\"" + v + "\"";
		break;
	}
	return v.tostring();
}

function saveblob(name, blob)
{
	local file = ::file(name, "wb");
	if (!(blob instanceof ::blob)) {
		local len = blob.len();
		blob.seek(0);
		blob = blob.readblob(len);
	}
	file.writeblob(blob);
}

function file_exists(name)
{
	try {
		local file = ::file(name, "rb");
		return true;
	} catch (e) {
		//print("ERROR: " + e);
		return false;
	}
}

function exists_in_path_any(path, files)
{
	foreach (file in files) {
		if (file_exists(path + "/" + file)) return true;
	}
	return false;
}

function exists_in_game_path_any(files)
{
	return exists_in_path_any(info.game_data_path, files);
}
