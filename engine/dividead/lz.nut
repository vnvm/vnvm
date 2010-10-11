class LZ
{
	static function decode(s)
	{
		local h = {
			magic = s.readstringz(2),
			csize = s.readn('i'),
			usize = s.readn('i'),
		};
		if (h.magic != "LZ") throw("Invalid LZ stream");
		local blob_out = ::lz_decode(
			s.readslice(h.csize),
			h.usize,
			{ // Decompression information.
				bufsize  = 0x1000, // Ringbuffer size.
				opsize   = 1,      // Size of the operation in bytes (1 byte)
				writepos = 0xFEE,  // Initial position for writting. (Position 1)
				init     = 0,      // Initial status of the buffer.
				comp_bit = 0,      // Bit 0/1 used for compressed.
				bit_count_add = 3,
				special = "dividead",
				bits     = ["position", 12, "count", 4] // Disposition of the bits in a compressed block.
				//debug    = 1,
				debug    = 0,
			}
		);
		return blob_out;
	}
}