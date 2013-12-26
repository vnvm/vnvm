package engines.will;

import flash.utils.ByteArray;
import promhx.Promise;

interface IScene
{
	function soundPlayStopAsync(channelName:String, name:String, fadeInOutMs:Int):Promise<Dynamic>;
	function getBtyeArrayAsync(name:String):Promise<ByteArray>;
	function setTransitionMaskAsync(name:String):Promise<Dynamic>;

	function getLayerWithName(name:String):GameLayer;

	function performTransitionAsync(kind:Int, time:Int):Promise<Dynamic>;

	function setText(text:String):Void;

	function animLoadAsync(name:String):Promise<Dynamic>;
	function tableLoadAsync(name:String):Promise<Dynamic>;
}