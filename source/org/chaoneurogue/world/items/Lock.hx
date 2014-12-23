package org.chaoneurogue.world.items;

import org.chaoneurogue.ld31.PlayState;

/**
 * ...
 * @author ith1ldin
 */
class Lock extends Entity
{
	public function new(X:Float=0, Y:Float=0, ?SimpleGraphic:Dynamic) 
	{
		super(X, Y, SimpleGraphic);
		immovable = true;
	}
	override private function resolveWorld():Void
	{
		game.addLock(this);
	}	
}