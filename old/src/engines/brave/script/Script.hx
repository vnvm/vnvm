package engines.brave.script;
import engines.brave.BraveAssets;
import engines.brave.formats.Decrypt;
import engines.brave.GameState;
import haxe.Log;
import haxe.rtti.Meta;
import openfl.Assets;
import flash.errors.Error;
import flash.utils.ByteArray;
import flash.utils.Endian;

/**
 * ...
 * @author 
 */

class Script 
{
	public var name:String;
	public var data:ByteArray;
	
	private function new() 
	{
	}

	static public function getScriptWithNameAsync(name:String, done:Script -> Void):Void {
		BraveAssets.getBytesAsync('scenario/${name}.dat').then(function(bytes:ByteArray) {
			done(getScriptWithByteArray(name, Decrypt.decryptDataWithKey(bytes, Decrypt.key23)));
		});
	}

	static public function getScriptWithByteArray(name:String, data:ByteArray):Script {
		var script:Script = new Script();
		script.name = name;
		script.data = data;
		script.data.endian = Endian.LITTLE_ENDIAN;
		script.data.position = 8;
		return script;
	}
}