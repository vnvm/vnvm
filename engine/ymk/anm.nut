/*
struct ANM_ENTRY {
	ushort data[402];
}

struct ANM {
	char file_name[9];
	ANM_ENTRY entries[100];
}
*/
class ANM
{
	// Struct
	wip_name = null;
	entries = null;

	// Local
	wip = null;
	active = null;

	constructor()
	{
		this.wip_name = null;
		this.entries = []; for (local n = 0; n < 100; n++) this.entries.push(array(402, 0));
		this.active = array(0x100, 0);
	}
	
	function load(name)
	{
		//printf("Reading... '%s.ANM'\n", name);
		this.read(::arc[name + ".ANM"]);
	}
	
	function read(stream)
	{
		// Struct
		this.wip_name = stream.readstringz(9);
		for (local y = 0; y < this.entries.len(); y++)
		{
			for (local x = 0; x < this.entries[y].len(); x++)
			{
				this.entries[y][x] = stream.readn('s');
			}
		}

		// Local
		this.wip = resman.get_image(this.wip_name);
		this.active = array(0x100, 0);
	}
	
	function active_set(index, set)
	{
		this.active[index] = set;
	}
	
	function drawTo(buffer)
	{
		if (this.wip == null) return;

		this.wip.drawTo(buffer, 0);
		for (local n = 0; n < 100; n++) {
			if (this.active[n]) {
				try {
					this.wip.drawTo(buffer, n + 1);
				} catch (e) {
				}
			}
		}
	}
	
	function print()
	{
		printf("ANM:\n");
		printf("  file_name: '%s'\n", this.wip_name);
		printf("  entries  : ...\n");
	}
}