function _writestringz(f, text, zero = 1)
{
	foreach (c in text) f.writen(c, 'b');
	if (zero) f.writen(0, 'b');
}

function writefile(fname, text) {
	local f = file(fname, "wb");
	 _writestringz(f, text, 0);
	 f = null;
}

function readfile(fname) {
	local f = file(fname, "rb");
	local r = f.readstring(f.len());
	f = null;
	return r;
}

function copyfile(from, to) {
	writefile(to, readfile(from));
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

/*class Serializer
{
	static function store(stream, object) {
		switch (type(object)) {
			case "string":
				stream.writen('b', 0);
				stream.writen('i', object.len());
				_writestringz(stream, object);
			break;
			case "integer":
				stream.writen('b', 1);
				stream.writen('i', object);
			break;
			case "float":
				stream.writen('b', 2);
				stream.writen('f', object);
			break;
			case "null":
				stream.writen('b', 3);
			break;
			case "bool":
				stream.writen('b', 4);
				stream.writen('b', object ? 1 : 0);
			break;
			case "array":
				stream.writen('b', 5);
				stream.writen('i', object.len());
				foreach (sub_object in object) store(stream, sub_object);
			break;
			case "table":
				stream.writen('b', 6);
				stream.writen('i', object.len());
				foreach (sub_key, sub_object in object) {
					store(stream, sub_key);
					store(stream, sub_object);
				}
			break;
			case "instance":
				if ("getStoreProperties" in object) {
					stream.writen('b', 7);
					stream.writen('i', object.len());
					foreach (sub_key, sub_object in object) {
						store(stream, sub_key);
						store(stream, sub_object);
					}
				} else if ("saveStream" in object) {
					object.saveStream(stream);
				}
			break;
			default:
				throw("Serializer::store - Can't serialize object.");
			break;
		}
	}
}
*/	

