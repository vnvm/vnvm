package common;

/**
 * ...
 * @author soywiz
 */

class PathUtils 
{
	static public function addExtensionIfMissing(name:String, defaultExtension:String):String {
		if (name.indexOf('.') < 0)  name += '.' + defaultExtension;
		return name;
	}
}