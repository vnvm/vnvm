package vfs;
import flash.utils.Endian;
import common.EventListenerOnce;
import promhx.Promise;
import flash.errors.Error;
import flash.events.Event;
import flash.events.HTTPStatusEvent;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.net.URLRequestHeader;
import flash.net.URLRequestMethod;
import flash.utils.ByteArray;
import common.EventUtils;
import common.LangUtils;

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
	
	private function getAbsolutePath(name:String) {
		return ~/\/*$/.replace(baseUrl, '') + '/' + name;
	}
	
	override public function openAsync(name:String):Promise<Stream>
	{
		var loader:URLLoader = new URLLoader();
		var urlRequest:URLRequest = new URLRequest(getAbsolutePath(name));
		loader.dataFormat = URLLoaderDataFormat.BINARY;
		urlRequest.method = URLRequestMethod.GET;
		//urlRequest.req
		//new URLRequestHeader();
		
		var promise = new Promise<Stream>();
		//done = LangUtils.callOnce(done);

		var loaderEventListener = new EventListenerOnce(loader);

		loaderEventListener.addEventListener(Event.COMPLETE, function(e:Event):Void {
			loader.close();
			loader.data.endian = Endian.LITTLE_ENDIAN;
			promise.resolve(new BytesStream(loader.data));
		});
		loaderEventListener.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(e:SecurityErrorEvent):Void {
			var error:Error = new Error("SECURITY_ERROR: " + name + " # " + baseUrl);
			throw(error);
			loader.close();
			promise.reject(error);
		});
		loaderEventListener.addEventListener(IOErrorEvent.IO_ERROR, function(e:SecurityErrorEvent):Void {
			var error = new Error("IO_ERROR: " + name + " # " + baseUrl);
			throw(error);
			loader.close();
			promise.reject(error);
		});
		
		loader.load(urlRequest);
		//throw(new Error("Not implemented VirtualFileSystem.openAsync"));
		
		return promise;
	}
	
	override public function existsAsync(name:String):Promise<Bool>
	{
		var loader:URLLoader = new URLLoader();
		var urlRequest:URLRequest = new URLRequest(getAbsolutePath(name));
		loader.dataFormat = URLLoaderDataFormat.BINARY;
		//urlRequest.method = URLRequestMethod.HEAD;
		urlRequest.method = URLRequestMethod.GET;
		//done = LangUtils.callOnce(done);
		var promise = new Promise<Bool>();
		
		EventUtils.addEventListenerWeak(loader, Event.COMPLETE, function(e:Event):Void {
			loader.close();
			promise.resolve(true);
		});
		EventUtils.addEventListenerWeak(loader, "httpResponseStatus", function(e:HTTPStatusEvent):Void {
			loader.close();
			promise.resolve(true);
		});
		EventUtils.addEventListenerWeak(loader, SecurityErrorEvent.SECURITY_ERROR, function(e:Event):Void {
			loader.close();
			promise.resolve(false);
		});
		EventUtils.addEventListenerWeak(loader, IOErrorEvent.IO_ERROR, function(e:Event):Void {
			loader.close();
			promise.resolve(false);
		});
		
		loader.load(urlRequest);
		
		return promise;
	}
}