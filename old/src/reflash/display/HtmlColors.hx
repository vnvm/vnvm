package reflash.display;

class HtmlColors
{
	static public var black(get, never):Color2;
	static public var white(get, never):Color2;
	static public var red(get, never):Color2;
	static public var green(get, never):Color2;
	static public var blue(get, never):Color2;
	static public var transparent(get, never):Color2;

	static private function get_black():Color2 { return Color2.create(0, 0, 0, 1); }
	static private function get_white():Color2 { return Color2.create(1, 1, 1, 1); }
	static private function get_red():Color2 { return Color2.create(1, 0, 0, 1); }
	static private function get_green():Color2 { return Color2.create(0, 1, 0, 1); }
	static private function get_blue():Color2 { return Color2.create(0, 0, 1, 1); }
	static private function get_transparent():Color2 { return Color2.create(0, 0, 0, 0); }
}
