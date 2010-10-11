class SG
{
	static function get(s)
	{
		local bmp = Bitmap.fromStream(LZ.decode(s));
		//bmp.setColorKey(0);
		return bmp;
	}
}