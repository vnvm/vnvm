class ARC
{
	path = null;
	file = null;
	types = null;
	
	constructor(path)
	{
		this.path = path;
		::printf("ARC: '%s'\n", path);
		this.file = ::file(path, "rb");
		parse();
	}
	
	function parse()
	{
		local types_count;
		local type_list = [];
		local type_name, type_start, type_count;

		file.seek(0);
		
		types_count = file.readn('i');
		
		for (local n = 0; n < types_count; n++)
		{
			type_name  = file.readstringz(4);
			type_count = file.readn('i');
			type_start = file.readn('i');

			type_list.push([type_name, type_count, type_start]);
		}
		
		//printf("%d\n", type_list.len());
		
		types = {};

		foreach (type in type_list)
		{
			type_name  = type[0];
			type_count = type[1];
			type_start = type[2];

			file.seek(type_start);
			
			types[type_name] <- {};
			
			for (local n = 0; n < type_count; n++) {
				local file_name  = file.readstringz(9);
				local file_size  = file.readn('i');
				local file_start = file.readn('i');
				
				types[type_name][file_name] <- {
					type     = type_name,
					name     = file_name,
					position = file_start,
					size     = file_size,
				};
			}
		}
	}
	
	function locate(type, base, show_error = 1)
	{
		if ((type in types) && (base in types[type])) {
			return types[type][base];
		} else {
			if (show_error) ::printf("Can't locate '%s':'%s'\n", type, base);
			return null;
		}
	}
	
	static function getslice(slice)
	{
		file.seek(slice.position);
		return file.readslice(slice.size);
	}
	
	function get(name, show_error = 1)
	{
		name = name.toupper();
		local pos = name.find(".");
		if (pos == -1) {
			if (show_error) ::printf("ERROR: File without extension '%s'\n", name);
			return null;
		}
		
		local slice = locate(name.slice(pos + 1, name.len()), name.slice(0, pos), show_error);
		if (slice == null) {
			if (show_error) ::printf("ERROR: Can't locate file '%s'\n", name);
			return null;
		}

		return getslice(slice);
	}

	function _get(name)
	{
		return get(name, 1);
	}
	
	function list(type)
	{
		local l = [];
		foreach (k, v in types[type.toupper()]) l.push(k);
		return l;
	}
	
	function print()
	{
		foreach (k, type in types) {
			::printf("'%s'\n", k);
			foreach (name, v in type) {
				::printf("  '%s'\n", name);
			}
		}
	}

	function iterator()
	{
		foreach (files in types) {
			foreach (file in files) {
				yield file;
			}
		}
		return null;
	}
}

class ARC_CONTAINER
{
	arc_list = null;
	
	constructor()
	{
		arc_list = [];
	}

	function add(arc_name)
	{
		arc_list.push(::ARC(arc_name));
	}

	function get(name, show_error = 1)
	{
		foreach (arc in arc_list) {
			local slice = arc.get(name, 0);
			if (slice != null) return slice;
		}

		if (show_error) {
			//::printf("ERROR: Can't locate file '%s'\n", name);
			throw(::format("Can't locate file '%s'", name));
		} else {
			return null;
		}
	}

	function _get(name)
	{
		return get(name, 1);
	}

	function iterator()
	{
		foreach (arc in arc_list) {
			foreach (file in arc.iterator()) {
				yield file;
			}
		}
		return null;
	}
}