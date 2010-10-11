class PAK
{
	file = null;
	files = {};
	
	constructor(name)
	{
		this.file = ::file(name, "rb");
		parse_header();
	}
	
	function parse_header()
	{
		local slice = file.readslice(file.readn('w'));
		local names = [], vpos = [];
		while (!slice.eos())
		{
			names.push(slice.readstringz(0xC));
			vpos.push(slice.readn('i'));
		}
		for (local n = 0, len = names.len() - 1; n < len; n++)
		{
			files[names[n]] <- {pos=vpos[n], next=vpos[n + 1]};
		}
	}
	
	function getslice(slice)
	{
		file.seek(slice.pos);
		return file.readslice(slice.next - slice.pos);
	}
	
	function _get(name)
	{
		return getslice(files[name]);
	}
	
	function save(name)
	{
		saveblob(name, this[name]);
	}
}