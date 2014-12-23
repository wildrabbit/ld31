package org.chaoneurogue.world.items;

import flixel.addons.editors.tiled.TiledObject;
import org.chaoneurogue.world.Entity;
import org.chaoneurogue.ld31.PlayState;
/**
 * ...
 * @author ith1ldin
 */
class Key extends Entity
{
	public var lockName:String = null;
	public function new(X:Float=0, Y:Float=0, ?SimpleGraphic:Dynamic) 
	{
		super(X, Y, SimpleGraphic);
	}
	
	override public function load(obj:TiledObject, game:PlayState):Void
	{
		super.load(obj, game);
		lockName = tiledObj.custom.get("lock");
	}
	
	override private function resolveWorld():Void
	{
		game.addKey(this);
	}	
}