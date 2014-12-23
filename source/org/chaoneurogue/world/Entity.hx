package org.chaoneurogue.world;

import flixel.addons.editors.tiled.TiledObject;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.geom.Rectangle;
import org.chaoneurogue.ld31.PlayState;
import org.chaoneurogue.utils.MyTexturePackerData;

/**
 * ...
 * @author ith1ldin
 */
class Entity extends FlxSprite
{
	public static var gravity:Float = 420;
	public static var paused:Bool = false;
	
	var tiledObj: TiledObject = null;
	var game:PlayState = null;
	var packerData:MyTexturePackerData = null;
	var name:String = "";
	
	var disabled:Bool = false;
	
	
	public function new(X:Float=0, Y:Float=0, ?SimpleGraphic:Dynamic) 
	{
		super(X, Y, SimpleGraphic);
	}
	
	override public function update():Void
	{
		if (Entity.paused) return;
		if (disabled) return;
		super.update();
	}
	
	public function load(obj:TiledObject, game:PlayState):Void
	{
		tiledObj = obj;
		name = obj.name;
		this.game = game;
		
		if (obj.custom.contains("atlas"))
		{
			var srcStr:String = "assets/images/" + obj.custom.get("atlas") ;
			packerData = new MyTexturePackerData(srcStr + ".json", srcStr + ".png");
			loadGraphicFromTexture(packerData, false, obj.custom.get("key"));
		
			var r:Rectangle = packerData.getFrameRectangle(obj.custom.get("key"));
			width = r.width;
			height = r.height;
			offset.set( - ((r.width - frameWidth) * 0.5), - ((r.height- frameHeight) * 0.5));
			centerOrigin();
		}	
		
		setPosition(obj.x, obj.y - height);		
		resolveWorld();
	}
	
	private function resolveWorld():Void
	{		
		
	}
	
	public function startFadeIn(time:Float, ?callback:FlxTween -> Void):Void
	{
		alpha = 0;
		if (callback != null)
		{
			FlxTween.tween(this, { alpha:1 }, time, { type:FlxTween.ONESHOT, ease:FlxEase.backIn, complete:callback} );			
		}
		else 
		{
			FlxTween.tween(this, { alpha:1 }, time, { type:FlxTween.ONESHOT, ease:FlxEase.backIn} );
		}
		
		
		scale.set();
		FlxTween.tween(scale, { x:1, y:1 }, time, { type:FlxTween.ONESHOT, ease:FlxEase.backIn} );
	}
	
	public function startFadeOut(time:Float, ?callback:FlxTween -> Void):Void
	{
		alpha = 1;
		if (callback != null)
		{
			FlxTween.tween(this, { alpha:0 }, time, { type:FlxTween.ONESHOT, ease:FlxEase.backOut, complete:callback} );			
		}
		else 
		{
			FlxTween.tween(this, { alpha:0 }, time, { type:FlxTween.ONESHOT, ease:FlxEase.backOut} );
		}
				
		scale.set(1,1);
		FlxTween.tween(scale, { x:0, y:0 }, time, { type:FlxTween.ONESHOT, ease:FlxEase.backOut} );
	}
	public function updateCollisions():Void
	{
		
	}
	
	public function onNextLevel():Void
	{
		
	}
	
	public function onStartLevel():Void
	{
		
	}
	
	public function onDie():Void
	{
		
	}

	public function setDisabled(value:Bool):Void
	{
		if (value)
		{
			velocity.x = velocity.y = 0;
			acceleration.x = acceleration.y = 0;
			drag.x = drag.y = 0;
		}
		else
		{
			acceleration.y = gravity;
			drag.set(Std.parseFloat(tiledObj.custom.get("dragX")), Std.parseFloat(tiledObj.custom.get("dragX"))); 
		}
		solid = !value;
		immovable = value;
		disabled = value;
	}
		
	public function die():Void
	{
		setDisabled(true);
	}
}