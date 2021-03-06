package engines.will;

import reflash.display2.Milliseconds;
import reflash.display2.Seconds;
import reflash.display.DisplayObjectContainer2;
import reflash.display.DisplayObject2;
import vfs.VirtualFileSystem;
import lang.promise.IPromise;
import engines.will.display.IGameElementsLayer;
import engines.will.display.GameElementsLayer;
import reflash.display.Sprite2;
import flash.geom.Point;
import flash.utils.ByteArray;

interface IScene
{
	function getFileSystem():VirtualFileSystem;
	function getGameSprite():DisplayObjectContainer2;

	function isSkiping():Bool;

	function getMaskValueAt(point:Point):Int;
	function getMousePosition():Point;

	function soundPlayStopAsync(channelName:String, name:String, fadeInOutMs:Int):IPromise<Dynamic>;
	function getBtyeArrayAsync(name:String):IPromise<ByteArray>;
	function setTransitionMaskAsync(name:String):IPromise<Dynamic>;

	function getLayerWithName(name:String):IGameElementsLayer;

	function performTransitionAsync(kind:Int, time:Milliseconds):IPromise<Dynamic>;

	function setTextAsync(text:String, title:String, timePerCharacter:Seconds):IPromise<Dynamic>;
	function setTextSize(size:Int):Void;

	function animLoadAsync(name:String):IPromise<Dynamic>;
	function tableLoadAsync(name:String):IPromise<Dynamic>;

	function setAnimObjectVisibility(index:Int, visible:Bool):IPromise<Dynamic>;
	function setDirectMode(directMode:Bool):Void;
	function isEnabledKind(kind:Int):Bool;
}