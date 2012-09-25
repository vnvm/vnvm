package engines.ethornell;

/**
 * ...
 * @author soywiz
 */

// Class to have read access to ARC files.
class ARC {
	Stream s;
	Stream sd;
	Entry[] table;
	Entry*[char[]] table_lookup;
	
	// Entry for the header.
	struct Entry {
		ubyte[0x10] _name; // Stringz with the name of the file.
		uint start, len;   // Slice of the file.
		ARC arc;           // Use a slice of the unused area to save a reference to the ARC parent.
		ubyte[8 - arc.sizeof] __pad; // Unused area.

		// Obtaining the processed name as a char[].
		char[] name() { return cast(char[])_name[0..strlen(cast(char *)_name.ptr)]; }
		char[] toString() { return format("%-16s (%08X-%08X)", name, start, len); }

		// Open a read-only stream for the file.
		Stream open() { return arc.open(*this); }
		
		// Method to save this entry to a file.
		void save(char[] name = null) {
			if (name == null) name = this.name;
			scope s = new BufferedFile(name, FileMode.OutNew);
			s.copyFrom(open);
			s.close();
		}

		// Defines the explicit cast to Stream.
		Stream opCast() { return open; }
	}

	// Check the struct to have the expected size.
	static assert(Entry.sizeof == 0x20, "Invalid size for ARC.Entry");

	// Open a ARC using an stream.
	this(Stream s, char[] name = "unknwon") {
		this.s = s;

		// Check the magic.
		assert(s.readString(12) == "PackFile    ", format("It doesn't seems to be an ARC file ('%s')", name));

		// Read the size.
		uint table_length; s.read(table_length);
		
		// Read the table itself.
		table.length = table_length; s.readExact(table.ptr, table.length * table[0].sizeof);

		// Stre a SliceStream starting with the data part.
		sd = new SliceStream(s, s.position);

		// Iterates over all the entries, creating references to this class, and creating a lookup table.
		for (int n = 0; n < table.length; n++) {
			table_lookup[table[n].name] = &table[n];
			table[n].arc = this;
		}
	}
	
	private function this() {
		
	}
	
	static public function createFromStream():ARC {
		
	}

	// Open an ARC using a file name.
	this(char[] name) { this(new BufferedFile(name), name); }
	
	// Shortcut for instantiating the class.
	static ARC opCall(Stream s   ) { return new ARC(s   ); }
	static ARC opCall(char[] name) { return new ARC(name); }

	// Gets a read-only stream for a entry.
	Stream open(Entry e) { return new SliceStream(sd, e.start, e.start + e.len); }

	// Defines an iterator for this class.
	int opApply(int delegate(ref Entry) dg) {
		for (int i = 0, result = void; i < table.length; i++) if ((result = dg(table[i])) != 0) return result;
		return 0;
	}

	// Defines an array accessor to obtain an entry file.
	Entry opIndex(char[] name) {
		if ((name in table_lookup) is null) throw(new Exception(format("Unknown index '%s'", name)));
		return *table_lookup[name];
	}
}