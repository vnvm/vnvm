package engines.brave;

import reflash.display2.Seconds;
import reflash.display2.Milliseconds;
import reflash.display2.Easing;
import lang.MathEx;
import common.script.ScriptOpcodes;
import common.display.SpriteUtils;
import common.StageReference;
import engines.brave.map.GameMap;
import engines.brave.script.Script;
import engines.brave.script.ScriptInstructions;
import engines.brave.script.ScriptThread;
import engines.brave.script.Variable;
import engines.brave.sprites.GameSprite;
import engines.brave.sprites.map.Character;
import haxe.Timer;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.PixelSnapping;
import flash.errors.Error;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.media.SoundChannel;
import flash.Memory;
import flash.utils.ByteArray;

/**
 * ...
 * @author 
 */

class GameState 
{
	public var variables:Array<Variable>;
	public var rootClip:GameSprite;
	public var musicChannel:SoundChannel;
	public var scriptOpcodes:ScriptOpcodes;
	
	public function new(rootClip:GameSprite) 
	{
		this.scriptOpcodes = ScriptOpcodes.createWithClass(ScriptInstructions);
		this.rootClip = rootClip;
		this.rootClip.mapSprite.visible = false;
		this.variables = new Array<Variable>();
		for (n in 0 ... 10000) this.variables.push(new Variable(0));
		StageReference.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		StageReference.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		keyPress = new Map<Int, Void>();
	}
	
	static var keyPress:Map<Int, Void>;
	//static var pressingControl:Bool = false;
	
	public function onKeyDown(e:KeyboardEvent):Void {
		//pressingControl = e.ctrlKey;
		keyPress.set(e.keyCode, null);
		//BraveLog.trace(e.keyCode);
	}

	public function onKeyUp(e:KeyboardEvent):Void {
		//pressingControl = e.ctrlKey;
		keyPress.remove(e.keyCode);
	}

	public function spawnThreadWithScript(script:Script):ScriptThread {
		var scriptThread:ScriptThread = new ScriptThread(this);
		scriptThread.setScript(script);
		return scriptThread;
	}
	
	public function setMapAsync(mapName:String, done:Void -> Void):Void {
		GameMap.loadFromNameAsync(mapName, function(map:GameMap) {
			rootClip.mapSprite.setMap(map);
			done();
		});
	}

	public function getAllCharacters():Iterator<Character> {
		if (rootClip == null) throw(new Error("rootClip is null"));
		if (rootClip.mapSprite == null) throw(new Error("rootClip.mapSprite is null"));
		if (rootClip.mapSprite.characters == null) throw(new Error("rootClip.mapSprite.characters is null"));
		return rootClip.mapSprite.characters.iterator();
	}

	public function getCharacter(charaId:Int):Character {
		var chara:Character = rootClip.mapSprite.characters.get(charaId);
		if (chara == null) throw(new Error('Can\'t get character with id=${charaId}'));
		return chara;
	}

	public function charaSpawnAsync(charaId:Int, face:Int, unk:Int, x:Int, y:Int, direction:Int, done:Void -> Void):Void {
		var partName:String = switch (charaId) {
			case 0: "C_RUDY";
			case 1: "C_SCHELL";
			case 3: "C_ALICIA";
			default: "C_GOBL01";
		};
		var character = new Character(rootClip, rootClip.mapSprite, charaId, partName, x * 40, y * 40, direction);
		character.loadImageAsync(function() {
			rootClip.mapSprite.addCharacter(character);
			done();
		});
	}
	
	public function waitClickOrKeyPress(done:Void -> Void):Void {
		if (keyPress.exists(17)) {
			rootClip.waitAsync(new Milliseconds(1)).then(function(?e){ done(); });
			return;
		}
		var onClick = null;
		onClick = function(e) {
			StageReference.stage.removeEventListener(MouseEvent.CLICK, onClick);
			StageReference.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onClick);

			rootClip.waitAsync(new Milliseconds(1)).then(function(e) {
				done();
			});
		};
		StageReference.stage.addEventListener(MouseEvent.CLICK, onClick);
		StageReference.stage.addEventListener(KeyboardEvent.KEY_DOWN, onClick);
	}
	
	public function setBackgroundColor(color:Int):Void {
		rootClip.backgroundBack.visible = true;
		
		SpriteUtils.extractSpriteChilds(rootClip.backgroundBack);
		rootClip.backgroundBack.addChild(SpriteUtils.createSolidRect(color));
	}

	@:noStack public function setBackgroundEffect(effectType:Int):Void
	{
		var out:BitmapData = new BitmapData(640, 480);
		
		rootClip.backgroundBack.visible = true;
		
		out.draw(rootClip.backgroundBack);
		
		//rootClip.backgroundBack
		var pixels:ByteArray = out.getPixels(out.rect);
		
		pixels.position = 0;
		
		Memory.select(pixels);
		
		var offset:Int = 0;
		for (n in 0 ... Std.int(pixels.length / 4))
		{
			var grey:Int = MathEx.int_div((pixels[offset + 1] + pixels[offset + 2] + pixels[offset + 3]), 3);
			
			Memory.setByte(offset + 0, 0xFF);
			Memory.setByte(offset + 1, MathEx.int_div(grey * 100, 100));
			Memory.setByte(offset + 2, MathEx.int_div(grey * 80, 100));
			Memory.setByte(offset + 3, MathEx.int_div(grey * 60, 100));
			
			offset += 4;
		}
		
		out.setPixels(out.rect, pixels);
		
		SpriteUtils.removeSpriteChilds(rootClip.backgroundBack);
		rootClip.backgroundBack.addChild(new Bitmap(out, PixelSnapping.AUTO, true));
	}

	public function setBackgroundImageAsync(imageName:String, done:Void -> Void):Void {
		rootClip.background.alpha = 1;
		
		rootClip.backgroundBack.visible = true;
		
		SpriteUtils.extractSpriteChilds(rootClip.backgroundBack);
		BraveAssets.getBitmapAsync(imageName).then(function(image:Bitmap) {
			if (image != null) {
				rootClip.backgroundBack.addChild(image);
				done();
			} else {
				throw(new Error('Can\'t load image \'$imageName\''));
			}
		});
	}
	
	public function transition(done:Void -> Void, type:Int):Void {
		//rootClip.backgroundFront.alpha
		var time = new Seconds(0.5);
		
		rootClip.mapSprite.visible = false;
		rootClip.backgroundBack.visible = true;
		
		//rootClip.backgroundBack.transform.colorTransform = new ColorTransform(1, 0.6, 0.3, 1.0, 0, 0, 0, 0);

		rootClip.interpolateAsync(rootClip.backgroundFront, time, { alpha : 0 }, Easing.easeInOutQuad).then(function(e) {
			rootClip.backgroundFront.alpha = 1;
			SpriteUtils.swapSpriteChildren(rootClip.backgroundFront, rootClip.backgroundBack);
			done();
		});
	}
	
	public function fadeToMap(done:Void -> Void, time:Int):Void {
		var time = new Seconds(0.5);
		
		rootClip.mapSprite.visible = true;
		rootClip.backgroundBack.visible = false;

		rootClip.interpolateAsync(rootClip.background, time, { alpha : 0 }, Easing.easeInOutQuad).then(function(e) {
			done();
		});
	}
}