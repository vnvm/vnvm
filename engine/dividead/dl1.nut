class DL1
{
	name = null;
	file = null;
	entries = {};
	
	constructor(name)
	{
		this.name = name;
		this.file = ::file(name, "rb");
		this.entries = {};
		parse_header();
	}
	
	function parse_header()
	{
		if (file.readstringz(8) != "DL1.0\x1A") throw("Invalid DL1 file");
		local count  = file.readn('w');
		local offset = file.readn('i');
		local pos    = 0x10;

		file.seek(offset);
		
		for (local n = 0; n < count; n++) {
			local name = file.readstringz(12);
			local size = file.readn('i');
			this.entries[name] <- [pos, size];
			pos += size;
		}
	}

	static function getslice(slice) {
		file.seek(slice[0]);
		return file.readslice(slice[1]);
	}

	function _get(name)
	{
		name = name.toupper();
		if (name in this.entries) {
			return getslice(this.entries[name]);
		} else {
			throw(::format("Can't find '%s'", name));
			return null;
		}
	}
	
	function list()
	{
		local l = [];
		foreach (k, v in entries) l.push(k);
		return l;
	}
	
	function print()
	{
		foreach (k, v in entries) {
			::printf("'%s'\n", k);
		}
	}
}

class VFS
{
	list = null;
	
	constructor(list)
	{
		this.list = list;
	}
	
	function _get(name)
	{
		//list[1].print();
		foreach (fs in list)
		{
			try { return fs[name]; } catch (e) { }
		}
		//return 1;
		throw(::format("Not exists '%s' in vfs", name));
	}
	
	function get_image(name)
	{
		return SG.get(this[name]);
	}
}