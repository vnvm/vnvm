package engines.brave;

import reflash.display2.View;
import common.display.GameScalerSprite;
import common.imaging.GraphicUtils;
import vfs.SubVirtualFileSystem;
import vfs.VirtualFileSystem;
import engines.brave.BraveAssets;
import engines.brave.formats.BraveImage;
import common.input.GameInput;
import engines.brave.GameState;
import engines.brave.map.GameMap;
import engines.brave.script.Script;
import engines.brave.script.ScriptReader;
import engines.brave.script.ScriptThread;
import engines.brave.sound.SoundPack;
import engines.brave.sprites.GameSprite;
import engines.brave.sprites.map.Character;
import engines.brave.sprites.map.MapSprite;
import haxe.Timer;
import flash.geom.Rectangle;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundLoaderContext;
import haxe.Log;
import openfl.Assets;
import flash.display.Stage;
import flash.display.Bitmap;
import flash.display.PixelSnapping;
import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;
import flash.media.SoundTransform;

/**
 * ...
 * @author soywiz
 */

class EngineMain extends View
{
	
	public function new(fs:VirtualFileSystem, script:String) 
	{
		super();
		
		BraveAssets.fs = SubVirtualFileSystem.fromSubPath(fs, "brave");
		
		init0(script);
	}
	
	var gameSpriteRectangle:Rectangle;
	var gameSprite:GameSprite;
	var blackBorder:Sprite;
	
	var initialized:Bool = false;
	
	private function init0(script:String) {
		if (!initialized) {
			gameSprite = new GameSprite();
			blackBorder = new Sprite();
			addChild(new GameScalerSprite(640, 480, gameSprite));
			addChild(blackBorder);

		}
		if (!initialized) {
			initialized = true;
			init(script);
		}
	}
	
	private function init(script:String):Void
	{
		if (script == null) script = 'start';
		
#if flash
		Log.setColor(0xFF0000);
#end
		
		/*
		var faceId = 57;
		BraveLog.trace(StringEx.sprintf("Z_%02d_%02d", [Std.int(faceId / 100), Std.int(faceId % 100)]));
		*/
		
		//new ScriptReader(Script.getScriptWithName("op")).readAllInstructions();
		
		if (false) {
			GameMap.loadFromNameAsync("a_wood0", function(woods:GameMap):Void {
				var mapSprite:MapSprite = new MapSprite(this);
				addChild(mapSprite);
				mapSprite.setMap(woods);
				var character:Character = new Character(gameSprite, mapSprite, 0, "C_RUDY", 20 * 40, 71 * 40);
				character.loadImageAsync(function() {
					mapSprite.addCharacter(character);
				});
			});
		} else {
			var startScriptName:String = script;
			//var startScriptName:String = "op";
			//var startScriptName:String = "op_2";
			//var startScriptName:String = "a_bar";
			//var startScriptName:String = "end_3";
			//var startScriptName:String = "e_m20";
			//var startScriptName:String = "e_k99";
			//var startScriptName:String = "e_m99";
			var gameState:GameState = new GameState(gameSprite);
			Script.getScriptWithNameAsync(startScriptName, function(script:Script) {
				var scriptThread:ScriptThread = gameState.spawnThreadWithScript(script);
				scriptThread.executeAsync();
			});
		}
	}

	/*
	static public function main() 
	{
		var stage = Lib.current.stage;
		stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		stage.align = flash.display.StageAlign.TOP_LEFT;
		
		Lib.current.addChild(new Main());
	}
	*/
}
