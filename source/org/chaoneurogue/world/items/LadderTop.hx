package org.chaoneurogue.world.items;

import flixel.addons.editors.tiled.TiledObject;
import flixel.FlxObject;
import flixel.util.FlxColor;
import org.chaoneurogue.ld31.PlayState;
import org.chaoneurogue.world.Entity;

/**
 * ...
 * @author ith1ldin
 */
class LadderTop extends Entity
{

	public function new(X:Float=0, Y:Float=0, ?SimpleGraphic:Dynamic) 
	{
		super(X, Y, SimpleGraphic);		
		allowCollisions = FlxObject.CEILING;
		immovable = true;
	}
	
	override public function load(obj:TiledObject, game:PlayState):Void
	{
		tiledObj = obj;
		name = obj.name;
		this.game = game;
		
		makeGraphic(obj.width, obj.height, FlxColor.TRANSPARENT);
		updateFrameData();
		setPosition(obj.x, obj.y);		
		resolveWorld();
	}
	
	override private function resolveWorld():Void
	{
		game.addLadder(this);
	}	
		
}