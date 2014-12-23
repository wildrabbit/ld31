package org.chaoneurogue.world.items;
import flixel.addons.editors.tiled.TiledObject;
import flixel.FlxSprite;
import org.chaoneurogue.ld31.PlayState;
import org.chaoneurogue.world.Entity;

/**
 * ...
 * @author ith1ldin
 */
class Goal extends Entity
{

	public function new(X:Float=0, Y:Float=0, ?SimpleGraphic:Dynamic) 
	{
		super(X, Y, SimpleGraphic);
	}	
	override private function resolveWorld():Void
	{
		game.setGoal(this);
	}	
}