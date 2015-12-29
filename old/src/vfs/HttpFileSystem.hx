package vfs;
import lang.promise.Deferred;
import lang.promise.IPromise;
import lang.promise.Promise;
import flash.utils.Endian;
import common.event.EventListenerOnce;
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
import common.event.EventUtils;
import lang.LangUtils;

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
	
	override public function openAsync(name:String):IPromise<Stream>
	{
		var loader:URLLoader = new URLLoader();
		var urlRequest:URLRequest = new URLRequest(getAbsolutePath(name));
		loader.dataFormat = URLLoaderDataFormat.BINARY;
		urlRequest.method = URLRequestMethod.GET;
		//urlRequest.req
		//new URLRequestHeader();
		
		var deferred = new Deferred<Stream>();
		//done = LangUtils.callOnce(done);

		var loaderEventListener = new EventListenerOnce(loader);

		loaderEventListener.addEventListener(Event.COMPLETE, function(e:Event):Void {
			loader.close();
			loader.data.endian = Endian.LITTLE_ENDIAN;
			deferred.resolve(new BytesStream(loader.data));
		});
		loaderEventListener.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(e:SecurityErrorEvent):Void {
			var error:Error = new Error("SECURITY_ERROR: " + name + " # " + baseUrl);
			throw(error);
			loader.close();
			deferred.reject(error);
		});
		loaderEventListener.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):Void {
			var error = new Error("IO_ERROR: " + name + " # " + baseUrl);
			throw(error);
			loader.close();
			deferred.reject(error);
		});
		
		loader.load(urlRequest);
		//throw(new Error("Not implemented VirtualFileSystem.openAsync"));
		
		return deferred.promise;
	}
	
	override public function existsAsync(name:String):IPromise<Bool>
	{
		var loader:URLLoader = new URLLoader();
		var urlRequest:URLRequest = new URLRequest(getAbsolutePath(name));
		loader.dataFormat = URLLoaderDataFormat.BINARY;
		//urlRequest.method = URLRequestMethod.HEAD;
		urlRequest.method = URLRequestMethod.GET;
		//done = LangUtils.callOnce(done);
		var deferred = new Deferred<Bool>();
		
		EventUtils.addEventListenerWeak(loader, Event.COMPLETE, function(e:Event):Void {
			loader.close();
			deferred.resolve(true);
		});
		EventUtils.addEventListenerWeak(loader, "httpResponseStatus", function(e:HTTPStatusEvent):Void {
			loader.close();
			deferred.resolve(true);
		});
		EventUtils.addEventListenerWeak(loader, SecurityErrorEvent.SECURITY_ERROR, function(e:Event):Void {
			loader.close();
			deferred.resolve(false);
		});
		EventUtils.addEventListenerWeak(loader, IOErrorEvent.IO_ERROR, function(e:Event):Void {
			loader.close();
			deferred.resolve(false);
		});
		
		loader.load(urlRequest);
		
		return deferred.promise;
	}
}