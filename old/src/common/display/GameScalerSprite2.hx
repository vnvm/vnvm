package common.display;
import haxe.Log;
import reflash.display.HtmlColors;
import reflash.display.Quad2;
import reflash.display.DisplayObject2;
import reflash.display.Sprite2;
import lang.MathEx;
import common.imaging.GraphicUtils;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.geom.Rectangle;
import flash.Lib;

/**
 * ...
 * @author soywiz
 */

class GameScalerSprite2 extends Sprite2
{
	var scalerWidth:Int;
	var scalerHeight:Int;
	
	public function new(width:Int, height:Int, gameSprite:DisplayObject2)
	{
		super();
		
		this.scalerWidth = width;
		this.scalerHeight = height;
		
		addChild(this.gameSprite = gameSprite);
		addChild(this.blackBorder = new Sprite2());

		resize(null);
		Lib.current.stage.addEventListener(Event.RESIZE, resize);
	}
	
	var gameSprite:DisplayObject2;
	var blackBorder:Sprite2;
	var gameSpriteRectangle:Rectangle;

	private function resize(e) 
	{
		var stage:Stage = Lib.current.stage;
		
		var propX = stage.stageWidth / scalerWidth;
		var propY = stage.stageHeight / scalerHeight;
		var usedWidth, usedHeight;
		
		if (propX < propY) {
			gameSprite.scaleY = gameSprite.scaleX = propX;
		} else {
			gameSprite.scaleY = gameSprite.scaleX = propY;
		}
		
		usedWidth = scalerWidth * gameSprite.scaleX;
		usedHeight = scalerHeight * gameSprite.scaleY;

		gameSprite.x = MathEx.int_div(Std.int(stage.stageWidth - usedWidth), 2);
		gameSprite.y = MathEx.int_div(Std.int(stage.stageHeight - usedHeight), 2);
		
		gameSpriteRectangle = new Rectangle(gameSprite.x, gameSprite.y, usedWidth, usedHeight);
		

		{
			blackBorder.removeChildren();
			blackBorder.addChild(new Quad2(0, 0, HtmlColors.black).setPosition(0, 0).setSize(gameSpriteRectangle.left, stage.stageHeight));
			blackBorder.addChild(new Quad2(0, 0, HtmlColors.black).setPosition(gameSpriteRectangle.right, 0).setSize(stage.stageWidth, stage.stageHeight));

			blackBorder.addChild(new Quad2(0, 0, HtmlColors.black).setPosition(0, 0).setSize(stage.stageWidth, gameSpriteRectangle.top));
			blackBorder.addChild(new Quad2(0, 0, HtmlColors.black).setPosition(0, gameSpriteRectangle.bottom).setSize(stage.stageWidth, stage.stageHeight));
		}
	}
}