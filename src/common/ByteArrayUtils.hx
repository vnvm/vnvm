package common;

import nme.utils.ByteArray;

/**
 * ...
 * @author 
 */

class ByteArrayUtils 
{
	static public function readStringz(data:ByteArray, ?count:Int):String {
		if (count == null) {
			var v:Int;
			var str:String = "";
			while ((v = data.readByte()) != 0) {
				str += String.fromCharCode(v);
			}
			return str;
		} else {
			var string:String = data.readUTFBytes(count);
			var zeroIndex:Int = string.indexOf(String.fromCharCode(0));
			
			return (zeroIndex == -1) ? string : string.substr(0, zeroIndex);
			//return string;
		}
	}

}