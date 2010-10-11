info.game_data_path <- info.engine_path + "/../game_data";

printf("Information:\n");
printf("  Platform: %s\n", info.platform);
printf("  Native resolution: %dx%d\n", info.native_width, info.native_height);
printf("  Engine path: %s\n", info.engine_path);
printf("  Game data path: %s\n", info.game_data_path);


mouse    <- Mouse();
keyboard <- Keyboard();

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
	start = 0;
	
	constructor()
	{
		this.reset();
	}
	
	function increment(ms)
	{
		start -= ms;
	}
	
	function reset()
	{
		start = ::time_ms();
	}
	
	function _get(name)
	{
		switch (name) {
			case "elapsed": return ::time_ms() - this.start;
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

function between(v, m, M)
{
	return (v >= m) && (v < M);
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
