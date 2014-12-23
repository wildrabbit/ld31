package org.chaoneurogue.utils;

import flixel.group.FlxTypedGroup;
import flixel.tile.FlxTile;
import flixel.tile.FlxTilemap;

/**
 * ...
 * @author ...
 */
class MyFlxTileMap extends FlxTilemap
{

	public function new() 
	{
		super();	
	}
	
	public function getTileObjects():Array<FlxTile>
	{
		return _tileObjects;
	}
	
	public function getStairs(g:FlxTypedGroup<FlxTile>):Void
	{

		for (id in _data)
		{
			if (id== 2)
			{
			}
		}		
	}
	
}