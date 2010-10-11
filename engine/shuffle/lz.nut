class LZ
{
	static function decode(s)
	{
		local h = {
			magic = s.readstringz(4),
			len_u = s.readn('i'),
			len_c = s.readn('i'),
			pad   = s.readn('i'),
		};
		if (h.magic != "  ZL") throw("Not a LZ stream ('" + h.magic + "')");
		return ::lz_decode(s.readslice(h.len_c), h.len_u, { special = "shuffle" });
	}
}