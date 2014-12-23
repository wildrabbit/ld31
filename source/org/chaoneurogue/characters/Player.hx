package org.chaoneurogue.characters;

import flixel.addons.editors.tiled.TiledObject;
import flixel.effects.FlxSpriteFilter;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.tile.FlxTile;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import openfl.geom.Point;
import org.chaoneurogue.world.Entity;
import org.chaoneurogue.world.items.Goal;
import org.chaoneurogue.world.items.Key;
import org.chaoneurogue.world.items.LadderTop;
import org.chaoneurogue.world.items.Lock;
import org.chaoneurogue.world.World;
import org.chaoneurogue.ld31.PlayState;
/**
 * ...
 * @author ith1ldin
 */
class Player extends Entity
{
	var sayAssets = ["assets/images/say_keys.png", "assets/images/say_huh.png", "assets/images/say_wtf.png", "assets/images/say_yay.png"];
	var saySprite:FlxSprite;
	var up:Bool = false;
	var down:Bool = false;
	var left:Bool = false;
	var right:Bool = false;
	var jump:Bool	= false;
	var activate:Bool = false; //Probably reuse "up".
	
	var soundlock:Bool = false;
	var soundTimer:FlxTimer = new FlxTimer();	
	
	var jumping:Bool = false;
	var ladderState:Bool = false;
	
	var speed:Float = 200;
	var jumpImpulse:Float = -240;

	var keyLocksPicked:Array<String> = new Array<String>();
	
	public var onStairs:Bool = false;
	
	var sayTimer:FlxTimer = new FlxTimer();
	
	public function new(X:Float=0, Y:Float=0, ?SimpleGraphic:Dynamic) 
	{
		super(X, Y, SimpleGraphic);
	}
	
	override public function load(obj:TiledObject, game:PlayState):Void
	{
		super.load(obj, game);
		
		facing = FlxObject.RIGHT;
		if (tiledObj.flippedHorizontally)
		{
			facing = FlxObject.LEFT;
		}
		
		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);
		
		acceleration.y = 420;
		speed = Std.parseFloat(tiledObj.custom.get("speed"));
		drag.set(Std.parseFloat(tiledObj.custom.get("dragX")), Std.parseFloat(tiledObj.custom.get("dragX")));
	}
	
	override public function update():Void
	{
		if (Entity.paused) return;
		super.update();
		
		if (saySprite != null) 
		{
			saySprite.setPosition(x + _halfWidth, y - height);
		}
		
		updateCollisions();
		
		up = FlxG.keys.anyPressed(["UP", "W"]);
		down = FlxG.keys.anyPressed(["DOWN", "S"]);
		left = FlxG.keys.anyPressed(["LEFT", "A"]);
		right = FlxG.keys.anyPressed(["RIGHT", "D"]);
		jump = FlxG.keys.anyJustPressed(["SPACE"]);
		
		if (up && down)
			up = down = false;
		if (left && right)
			left = right = false;

		movement();
	}
	
	private function movement():Void
	{
		if (left || right)
		{
			velocity.x = speed * (left ? -1 : 1);
			//velocity.y = tiledObj.custom.get("speed");			
			if (left)
			{
				facing = FlxObject.LEFT;
			}
			else facing = FlxObject.RIGHT;		
		}
		else velocity.x = 0;

		if (ladderState)
		{
			if (up)
			{
				velocity.y = -speed;
			}
			else if (down)
			{
				velocity.y = speed;
			}				
		}
		else
		{
			if (jump && velocity.y == 0)
			{
				velocity.y = jumpImpulse;
				jumping = true;
				FlxG.sound.play("assets/sounds/jump.wav");																
			}				
		}
		
		if (onStairs)
		{
			if (!ladderState && (up || down))
			{
				acceleration.y = 0;
				velocity.y = speed * (up ? -1 : 1);
				ladderState = true;						
			}
		}	
		else
		{
			if (ladderState)
			{
				ladderState = false;
				acceleration.y = Entity.gravity;
				velocity.y = 0;				
			}
		}		
	}
	
	override private function resolveWorld():Void
	{
		game.setPlayer(this);
	}
	
	override public function updateCollisions():Void
	{
		super.updateCollisions();

		FlxG.collide(this, game.tiles);
		
		// Stairs collisions
		var wasOnStairs:Bool = onStairs;
		onStairs = game.stairs.overlapsWithCallback(this, onOverlap);
				
		// Key collisions
		FlxG.overlap(this, game.keys, onKeyPicked);
		// Lock collisions
		FlxG.overlap(this, game.locks, onLockCollision);
		
		FlxG.overlap(this, game.goal, onGoalCollision);
		
		FlxG.overlap(this, game.ladders, onLadderCollision, processLadderCollision);		
		
		FlxG.overlap(this, game.enemies, onEnemyCollision);
	}
	
	private function onLadderCollision(o1:FlxObject, o2:FlxObject):Void
	{			
	}
	
	private function processLadderCollision(o1:FlxObject, o2:FlxObject):Bool
	{
		var l:LadderTop = cast(o2, LadderTop);
		if (FlxG.keys.anyPressed(["S", "DOWN"]))
		{
			acceleration.y = 0;
			velocity.y = speed;
			return false;
		}
		else
		{
			return FlxObject.separate(o1, o2);
		}
	}
	
	private function onKeyPicked(o1:FlxObject, o2:FlxObject):Void
	{
		var k:Key = cast(o2, Key);
		if (k != null)
		{
			if (keyLocksPicked.indexOf(k.lockName) == -1)
			{
				keyLocksPicked.push(k.lockName);
				FlxG.sound.play("assets/sounds/keypicked.wav");																
			}
			game.removeKey(k);

		}
	}
	
	private function onLockCollision(o1:FlxObject, o2:FlxObject):Void
	{
		var l:Lock= cast(o2, Lock);
		if (l != null)
		{
			var i:Int = keyLocksPicked.indexOf(l.name) ;
			if (i != -1)
			{
				keyLocksPicked.splice(i, 1);
				game.removeLock(l);
				FlxG.sound.play("assets/sounds/lockpicked.wav");												
				
			}
			else 
			{
				FlxObject.separate(l, this);
				if (!soundlock)
				{					
					FlxG.sound.play("assets/sounds/collidelock.wav");												
					soundlock = true;
					soundTimer.start(0.5, onSoundTimer);
				}
				
			}
		}
	}
	private function onSoundTimer(t:FlxTimer):Void
	{
		soundlock = false;
		soundTimer.cancel();
	}
	
	private function onGoalCollision(o1:FlxObject, o2:FlxObject):Void
	{
		var g:Goal = cast(o2, Goal);
		if (g != null)
		{			
			game.onNextLevel();
		}
	}
	
	private function doFlxGOverlap(o1:FlxObject, o2:FlxObject):Bool
	{
		return false;
	}
	
	private function onOverlap(v1:FlxObject, v2:FlxObject):Bool
	{
		var tile:FlxTile = cast(v1, FlxTile);
		if (tile != null && tile.index == 2)
		{
			var overlapFound:Bool = ((x + width) > tile.x)  && (x < (tile.x + tile.width)) && 
			   ((y + height) > tile.y) && (y < (tile.y + tile.height));
			return overlapFound;
		}
		return false;
	}
	
	override public function onNextLevel():Void
	{
		setDisabled(true);
	}
	
	override public function onStartLevel():Void
	{
		setDisabled(false);
	}
	
	private function onEnemyCollision(o1:FlxObject, o2:FlxObject):Void
	{
		var e:Enemy = cast(o2, Enemy);
		if (e == null) return;
		
		if (o2.y - o1.y > 5 && (Math.abs(o2.x - o1.x) < o2.width * 0.85))
		{
			e.die();
		}
		else
		{
			die();
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
		game.onPlayerDied();
	}
	
	public function say(id:Int):Void
	{
		saySprite = new FlxSprite(x + _halfWidth, y - height, sayAssets[id]);
		sayTimer.start(1, onSayFinished);
		game.add(saySprite);
		
	}
	public function onSayFinished(tween:FlxTimer):Void
	{
		sayTimer.cancel();
		game.remove(saySprite);
		saySprite.destroy();
		saySprite = null;
	}
	
	public function shut():Void
	{
		if (saySprite != null)
		{
			sayTimer.cancel();
			game.remove(saySprite);
			saySprite.destroy();
			saySprite = null;
		}
	}

}