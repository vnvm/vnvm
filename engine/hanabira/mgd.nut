class MGD
{
	image = null;

	constructor(stream)
	{
		stream.seek(0x5C);
		local pnglen = stream.readn('i');
		this.image = Bitmap.fromStream(stream.readslice(pnglen));
	}
	
	function drawTo(dest, x = 0, y = 0)
	{
		dest.drawBitmap(this.image, x, y);
	}
}