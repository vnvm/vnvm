package engines.brave.sprites.map;
import common.tween.Easing;
import common.tween.Tween;
import common.LangUtils;
import common.MathEx;
import common.SpriteUtils;
import common.GameInput;
import common.Keys;
import engines.brave.map.GameMap;
import haxe.Log;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.system.System;

/**
 * ...
 * @author 
 */

private class RowSprite {
	public var y:Int;
	public var sprite:Sprite;
	
	public function new(y:Int, sprite:Sprite) {
		this.y = y;
		this.sprite = sprite;
	}
}

class MapSprite extends Sprite
{
	public var map:GameMap;
	public var characters:Map<Int, Character>;
	public var cameraX:Float = 0;
	public var cameraY:Float = 0;

	public var tilesWidth:Int = Std.int((640 / 40) + 2);
	public var tilesHeight:Int = Std.int((480 / 40) + 2 + 4);
	
	private var backgroundSprite:Sprite;
	private var foregroundSprite:Sprite;
	private var rowSprites:Array<RowSprite>;

	public function new() 
	{
		super();
		
		addChild(backgroundSprite = new Sprite());
		addChild(foregroundSprite = new Sprite());

		rowSprites = LangUtils.createArray(function() { return new RowSprite(0, new Sprite()); }, tilesHeight);

		this.characters = new Map<Int, Character>();

		this.addEventListener(Event.ADDED_TO_STAGE, function(e:Event) {
			this.stage.addEventListener(Event.ENTER_FRAME, function(e:Event) {
				updateCamera();
			});
		});
	}
	
	public function addCharacter(character:Character):Void {
		this.characters.set(character.id, character);
		if (character.id == 0) {
			followCharacter(character);
		}
	}
	
	public function setMap(map:GameMap):Void {
		this.map = map;
		this.characters = new Map<Int, Character>();
		updateCamera();
	}

	public function setCameraTo(destX:Float, destY:Float):Void {
		this.cameraX = destX;
		this.cameraY = destY;
	}

	public function moveCameraTo(destX:Float, destY:Float, time:Float, ?done:Void -> Void):Void {
		destX = MathEx.clamp(destX, 0, map.width * 40 - 640);
		destY = MathEx.clamp(destY, 0, map.height * 40 - 480);

		Tween.forTime(time)
			.interpolateTo(this, { cameraX : destX, cameraY : destY }, Easing.easeInOutQuad)
			.animateAsync().then(function(?e) {
				done();
			})
		;
	}
	
	private var followingCharacter:Character;
	
	public function followCharacter(character:Character):Void {
		this.followingCharacter = character;
	}
	
	public function enableMoveWithKeyboard():Void {
		var cameraVelX:Float = 0;
		var cameraVelY:Float = 0;
		
		var multiplier:Float = 60 / this.stage.frameRate;
		
		var inc:Float = 0.7 * (multiplier * multiplier);
		var mul:Float = 0.94 / Math.sqrt(Math.sqrt(multiplier));
		
		this.stage.addEventListener(Event.ENTER_FRAME, function(e:Event) {
			if (GameInput.isPressing(Keys.Left)) cameraVelX -= inc;
			if (GameInput.isPressing(Keys.Up)) cameraVelY -= inc;
			if (GameInput.isPressing(Keys.Right)) cameraVelX += inc;
			if (GameInput.isPressing(Keys.Down)) cameraVelY += inc;
			
			cameraX += cameraVelX;
			cameraY += cameraVelY;
			
			cameraVelX *= mul;
			cameraVelY *= mul;
		});
	}
	
	public function updateCamera():Void {
		if (map == null) return;
		if (!visible) return;
		
		if (followingCharacter != null) {
			var targetX = followingCharacter.x - 640 / 2;
			var targetY = followingCharacter.y - 480 / 2;
			
			cameraX = (cameraX + targetX) / 2;
			cameraY = (cameraY + targetY) / 2;
		}
		
		cameraX = MathEx.clamp(cameraX, 0, map.width * 40 - 640);
		cameraY = MathEx.clamp(cameraY, 0, map.height * 40 - 480 - 40);

		var miniDispX:Int = Std.int(cameraX) % 40;
		var miniDispY:Int = Std.int(cameraY) % 40;

		var tileX:Int = Std.int(cameraX / 40);
		var tileY:Int = Std.int(cameraY / 40);

		backgroundSprite.graphics.clear();
		this.map.drawLayerTo(backgroundSprite.graphics, 0, -miniDispX, -miniDispY, tileX, tileY, tilesWidth, tilesHeight);
		
		for (row in 0 ... tilesHeight) {
			rowSprites[row].y = (tileY + row) * 40;
			rowSprites[row].sprite.graphics.clear();
			this.map.drawLayerTo(rowSprites[row].sprite.graphics, 1, -miniDispX, -miniDispY + row * 40, tileX, tileY + row, tilesWidth, 1);
		}
		
		//System.gc();
		
		reorderEntities();
	}
	
	public function reorderEntities():Void {
		SpriteUtils.extractSpriteChilds(foregroundSprite);
		//for (row in 0...rowSprites.length) foregroundSprite.addChildAt(rowSprites[row], 0);
		
		var charactersSorted:Array<Character> = Lambda.array(characters);
		charactersSorted.sort(function(a:Character, b:Character):Int {
			return a.y - b.y;
		});
		
		for (row in 0...rowSprites.length) {
			var rowSprite = rowSprites[row];
			for (character in charactersSorted) {
				if ((character.y >= rowSprite.y - 40) && (character.y < rowSprite.y)) {
					var sprite:Sprite = character.sprite;
					sprite.x = character.x - cameraX;
					sprite.y = character.y - cameraY;
					character.updateSprite();
					foregroundSprite.addChild(sprite);
				}
			}
			foregroundSprite.addChild(rowSprite.sprite);
		}
	}
}