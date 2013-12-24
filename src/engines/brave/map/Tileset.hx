package engines.brave.map;
import engines.brave.BraveAssets;
import engines.brave.cgdb.CgDbEntry;
import flash.display.BitmapData;

/**
 * ...
 * @author 
 */

class Tileset 
{
	public var partId:Int;
	public var name:String;
	public var bitmapData:BitmapData;
	public var cgDbEntry:CgDbEntry;

	public function new(partId:Int, name:String)
	{
		this.partId = partId;
		this.name = name;
	}
	
	public function loadDataAsync(done:Void -> Void):Void {
		if ((partId >= 0) && (name != "")) {
			BraveAssets.getBitmapDataAsync(name).then(function(bitmapData:BitmapData) {
				this.bitmapData = bitmapData;
				BraveAssets.getCgDbEntryAsync(name).then(function(cgDbEntry:CgDbEntry) {
					this.cgDbEntry = cgDbEntry;
					done();
				});
			});
		} else {
			done();
		}
	}
}