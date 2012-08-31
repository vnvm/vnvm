package common;
import nme.display.Sprite;
import nme.display.Stage;
import nme.events.Event;
import nme.geom.Rectangle;
import nme.Lib;

/**
 * ...
 * @author soywiz
 */

class GameScalerSprite extends Sprite
{
	public function new(width:Int, height:Int, gameSprite:Sprite) 
	{
		super();
		
		addChild(this.gameSprite = gameSprite);
		addChild(this.blackBorder = new Sprite());

		resize(null);
		Lib.current.stage.addEventListener(Event.RESIZE, resize);
	}
	
	var gameSprite:Sprite;
	var blackBorder:Sprite;
	var gameSpriteRectangle:Rectangle;

	private function resize(e) 
	{
		var stage:Stage = Lib.current.stage;
		
		var propX = stage.stageWidth / 640;
		var propY = stage.stageHeight / 480;
		var usedWidth, usedHeight;
		
		if (propX < propY) {
			gameSprite.scaleY = gameSprite.scaleX = propX;
		} else {
			gameSprite.scaleY = gameSprite.scaleX = propY;
		}
		
		usedWidth = 640 * gameSprite.scaleX;
		usedHeight = 480 * gameSprite.scaleY;

		gameSprite.x = Std.int((stage.stageWidth - usedWidth) / 2);
		gameSprite.y = Std.int((stage.stageHeight - usedHeight) / 2);
		
		gameSpriteRectangle = new Rectangle(gameSprite.x, gameSprite.y, usedWidth, usedHeight);
		
		{
			blackBorder.graphics.clear();
			GraphicUtils.drawSolidFilledRectWithBounds(blackBorder.graphics, 0, 0, gameSpriteRectangle.left, stage.stageHeight);
			GraphicUtils.drawSolidFilledRectWithBounds(blackBorder.graphics, gameSpriteRectangle.right, 0, stage.stageWidth, stage.stageHeight);

			GraphicUtils.drawSolidFilledRectWithBounds(blackBorder.graphics, 0, 0, stage.stageWidth, gameSpriteRectangle.top);
			GraphicUtils.drawSolidFilledRectWithBounds(blackBorder.graphics, 0, gameSpriteRectangle.bottom, stage.stageWidth, stage.stageHeight);

			//GraphicUtils.drawSolidFilledRect(blackBorder.graphics, 0, -this.y, 640, this.y / scaleY);
			//GraphicUtils.drawSolidFilledRect(blackBorder.graphics, 0, 480, 640, this.y / scaleY);
		}
	}
}