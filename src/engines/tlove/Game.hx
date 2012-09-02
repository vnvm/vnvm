package engines.tlove;

import common.io.Stream;
import common.io.VirtualFileSystem;
import nme.utils.ByteArray;

/**
 * ...
 * @author soywiz
 */

class Game 
{
	public var midi:PAK;
	public var mrs:PAK;
	public var date:PAK;
	public var eff:PAK;

	private function new() 
	{
		
	}
	
	static public function initFromFileSystemAsync(fs:VirtualFileSystem, done:Game -> Void):Void {
		var game:Game = new Game();
		
		fs.openBatchAsync(["MIDI", "MRS", "DATE", "EFF"], function(midiStream:Stream, mrsStream:Stream, dateStream:Stream, effStream:Stream):Void {
			PAK.newPakAsync(midiStream, function(midi:PAK) {
			PAK.newPakAsync(mrsStream, function(mrs:PAK) {
			PAK.newPakAsync(dateStream, function(date:PAK) {
			PAK.newPakAsync(effStream, function(eff:PAK) {
				game.midi = midi;
				game.mrs = mrs;
				game.date = date;
				game.eff = eff;
				
				done(game);
			});
			});
			});
			});
		});
	}
}