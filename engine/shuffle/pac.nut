class PAC
{
	file = null;
	name = null;
	files = {};

	constructor(name)
	{
		this.name = name;
		this.file = ::file(name, "rb");
		parse_header();
	}
	
	function parse_header()
	{
		local h = {
			magic   = file.readstringz(4),
			version = file.readn('i'),
			start   = file.readn('i'),
			count   = file.readn('i'),
		};
		if (h.magic != "CAPF") throw("Not a PAC File.");

		file.seek(0x20);
		
		for (local n = 0; n < h.count; n++)
		{
			local e = {
				pos  = file.readn('i'),
				len  = file.readn('i'),
				name = file.readstringz(0x20),
			};
			files[e.name] <- e;
			//::printf("%s\n", e.name);
		}
	}
	
	static function getslice(slice) {
		file.seek(slice.pos);
		return file.readslice(slice.len);
	}

	function _get(name)
	{
		try {
			return getslice(files[name]);
		} catch (e) {
			throw(e);
			return null;
		}
	}
}