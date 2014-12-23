package org.chaoneurogue.characters;

import flixel.addons.editors.tiled.TiledObject;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import org.chaoneurogue.ld31.PlayState;
import org.chaoneurogue.world.Entity;
import org.chaoneurogue.world.World;

/**
 * ...
 * @author ith1ldin
 */
class Enemy extends Entity
{
	var speed:Float = 200;
	
	public function new(X:Float=0, Y:Float=0, ?SimpleGraphic:Dynamic) 
	{
		super(X, Y, SimpleGraphic);
		acceleration.y = Entity.gravity;
	}
	
	override public function update():Void
	{
		if (Entity.paused) return;
		super.update();
		
		updateCollisions();	

	}	
	
	override private function resolveWorld():Void
	{
		game.addEnemy(this);
	}	
	
	override public function load(obj:TiledObject, game:PlayState):Void
	{
		super.load(obj, game);
		
		facing = FlxObject.LEFT;
		if (tiledObj.flippedHorizontally)
		{
			facing = FlxObject.RIGHT;
		}
		
		setFacingFlip(FlxObject.LEFT, false, false);
		setFacingFlip(FlxObject.RIGHT, true, false);
		
		speed = Std.parseFloat(tiledObj.custom.get("speed"));		
		velocity.x = (facing == FlxObject.RIGHT) ? speed : -speed;
	}
	
	
	override public function onNextLevel():Void
	{
		velocity.x = 0;
		solid = false;
		immovable = true;
	}
	
	override public function updateCollisions():Void
	{
		var touching:Bool = FlxG.collide(this, game.tiles, onWallCollision);
		if (!touching)
		{
			reverseDirection();
		}
		FlxG.collide(this, game.locks, onWallCollision);
	}
	
	private function reverseDirection():Void
	{
		if (facing == FlxObject.RIGHT)
		{
			facing = FlxObject.LEFT;
			this.velocity.x = -speed;
		}
		else if (facing == FlxObject.LEFT)
		{
			facing = FlxObject.RIGHT;
			this.velocity.x = speed;
		}
	}
	
	private function onWallCollision(o1:FlxObject, o2:FlxObject):Void
	{
		if (this.isTouching(FlxObject.LEFT)) {
			facing = FlxObject.RIGHT;
			this.velocity.x = speed;
		}
		else if (this.isTouching(FlxObject.RIGHT))
		{
			facing = FlxObject.LEFT;
			this.velocity.x = -speed;
		}
	}
	
	override public function die():Void
	{
		super.die();
		FlxTween.tween(this, { alpha:0 }, 0.4, { type:FlxTween.ONESHOT, ease:FlxEase.backOut } );
		FlxTween.tween(this.scale, { x:0, y:0}, 0.4, {type:FlxTween.ONESHOT, ease:FlxEase.backOut, complete:onDied} );
	}
	
	private function onDied(t:FlxTween):Void
	{
		game.onEnemyDied(this);
	}
}