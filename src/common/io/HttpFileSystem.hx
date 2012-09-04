package common.io;
import nme.errors.Error;
import nme.events.Event;
import nme.events.IOErrorEvent;
import nme.events.SecurityErrorEvent;
import nme.net.URLLoader;
import nme.net.URLLoaderDataFormat;
import nme.net.URLRequest;
import nme.utils.ByteArray;

/**
 * ...
 * @author soywiz
 */

class HttpFileSystem extends VirtualFileSystem
{
	var baseUrl:String;
	
	public function new(baseUrl:String) {
		this.baseUrl = baseUrl;
	}
	
	override public function openAsync(name:String, done:Stream -> Void):Void
	{
		var loader:URLLoader = new URLLoader();
		loader.dataFormat = URLLoaderDataFormat.BINARY;
		
		loader.addEventListener(Event.COMPLETE, function(e:Event):Void {
			done(cast(loader.data));
		});
		loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(e:Event):Void {
			done(null);
		});
		loader.addEventListener(IOErrorEvent.IO_ERROR, function(e:Event):Void {
			done(null);
		});
		
		loader.load(new URLRequest(baseUrl + '/' + name));
		throw(new Error("Not implemented VirtualFileSystem.openAsync"));
	}
	
	override public function existsAsync(name:String, done:Bool -> Void):Void {
		// TODO: Check HTTPStatusEvent.HTTP_STATUS
		done(true);
	}
}