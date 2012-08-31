class PAK
{
	stream = null;
	files = null;

	constructor(name)
	{
		
		this.parse(file(name, "rb"));
	}

	function parse(stream)
	{
		this.files = {};
		this.stream = stream;

		local magic = stream.readstringz(8);
		if (magic != "FJSYS") throw("Not a Hanabira's FJSYS file");

		local file_start_ptr  = stream.readn('i');
		local unknown         = stream.readn('i');
		local number_of_files = stream.readn('i');
		local files = [];
		
		stream.seek(0x54, 'b');
		for (local n = 0; n < number_of_files; n++) {
			files.push({
				namez_ptr   = stream.readn('i'),
				file_len    = stream.readn('i'),
				file_ptr    = stream.readn('i'),
				dummy       = stream.readn('i'),
			});
		}
		local namez_start_ptr = stream.tell();
		foreach (file in files) {
			stream.seek(namez_start_ptr + file.namez_ptr);
			file.name <- stream.readstringz(-1).toupper();
			
			this.files[file.name] <- {
				start  = file.file_ptr,
				length = file.file_len,
			};
			
			/*
			stream.seek(file_start_ptr + file.file_ptr);
			file.data <- stream.readslice(file.file_len);
			printf("%s\n", object_to_string(file));
			*/
		}
	}
	
	static function get(name)
	{
		name = name.toupper();
		local slice = this.files[name];
		//printf("Reading: %08X-%08X\n", slice.start, slice.length);
		this.stream.seek(slice.start);
		//if (blob) return this.stream.readblob(slice.length);
		return this.stream.readslice(slice.length);
	}
}