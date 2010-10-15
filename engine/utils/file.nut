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
