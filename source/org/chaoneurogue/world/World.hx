package org.chaoneurogue.world;
import flixel.addons.editors.tiled.TiledLayer;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObjectGroup;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledTileSet;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.group.FlxTypedGroup;
import haxe.ds.Vector;
import haxe.io.Path;
import openfl.utils.Dictionary;
import org.chaoneurogue.characters.Enemy;
import org.chaoneurogue.characters.Player;
import org.chaoneurogue.ld31.PlayState;
import org.chaoneurogue.world.items.Goal;
import org.chaoneurogue.world.items.Key;
import org.chaoneurogue.world.items.Lock;

/**
 * ...
 * @author ith1ldin
 */
typedef LayerChangeTable = Map<String, Array<ChangeDescriptor>>;

class World
{
	public var rows:Int = 20;
	public var cols:Int = 25;
	
	var sequence: Vector<String>;
	
	var changeLists:Map<String,LayerChangeTable>;
	
	var mapData:Array<TiledMap>;
	
	var TILESET(default, never):String = "level";
	
	public function getRow(idx:Int):Int
	{
		if (idx < 0 || idx >= rows * cols) return -1;
		else return Math.floor(idx / cols);
	}
	
	public function getCol(idx:Int):Int
	{
		if (idx < 0 || idx >= rows * cols) return -1;
		else return Math.floor(idx % cols);
	}

	
	public function new(levelList:Array<String>) 
	{
		sequence = new Vector<String>(levelList.length);
		mapData = new Array<TiledMap>();
		
		var idx:Int = 0;
		for (item in levelList)
		{
			sequence[idx] = item.substring(0, item.indexOf(".tmx"));
			mapData.push(new TiledMap("assets/data/" + item));			
			idx++;
		}
		
		generateChangelists();
	}
	
	private function generateChangelists():Void
	{
		changeLists = new Map<String, LayerChangeTable>();
		
		var idx:Int = 0;
		var cur:TiledMap = null;
		var next:TiledMap = null;
		while (idx < sequence.length - 1)
		{
			cur = mapData[idx];
			next = mapData[idx + 1];
			changeLists[sequence[idx]] = getChangeLists(cur, next, ["Level", "Stairs"], ["Items"]);
			idx++;
		}
	}
	
	private function getChangeLists(cur:TiledMap, next:TiledMap, layerNames:Array<String>, objectGroupNames:Array<String>):LayerChangeTable
	{
		var levelChanges:LayerChangeTable = new LayerChangeTable();
		var layer1:TiledLayer;
		var layer2:TiledLayer;
		
		var numTiles1:Int;
		var numTiles2:Int;
		for (name in layerNames)
		{
			levelChanges[name] = new Array<ChangeDescriptor>();
			layer1 = cur.getLayer(name);
			layer2 = next.getLayer(name);
			
			if (layer1 == null || layer2 == null) continue;
			if (layer1.width != layer2.width || layer1.height != layer2.height) continue;
			numTiles1 = layer1.tileArray.length;
			numTiles2 = layer2.tileArray.length;
			if (numTiles1 != numTiles2) continue;
			
			var idx:Int = 0;
			while (idx < numTiles1)
			{
				if (layer1.tileArray[idx] != layer2.tileArray[idx])
				{
					levelChanges[name].push(new ChangeDescriptor(name, getRow(idx), getCol(idx), layer2.tileArray[idx]));
				}
				idx++;
			}
		}
		
		return levelChanges;
	}

	public function getIndex(mapId:String):Int
	{
		var i:Int = 0;
		while (i < sequence.length)
		{
			if (sequence[i] == mapId)
			{
				return i;
			}
			i++;
		}
		return -1;
	}
		
	public function getTiles(mapId:String, layerId:String):Array<Int>
	{
		var mapIdx:Int = getIndex(mapId);
		if (mapIdx == -1) return null;
		
		return mapData[mapIdx].getLayer(layerId).tileArray;
	}
	
	public function getImage(mapId:String):String
	{
		var mapIdx:Int = getIndex(mapId);
		if (mapIdx == -1) return null;		
		
		var tileSet:TiledTileSet = mapData[mapIdx].getTileSet(TILESET);
		var imagePath = new Path(tileSet.imageSource);
		var processedPath = "assets/images/" + imagePath.file + "." + imagePath.ext;
		
		return processedPath;
	}
	
	public function getTileWidth(mapId:String):Int
	{
		var mapIdx:Int = getIndex(mapId);
		if (mapIdx == -1) return 32;		
		
		var tileSet:TiledTileSet = mapData[mapIdx].getTileSet(TILESET);
		return tileSet.tileWidth;	
	}
	
	public function getTileHeight(mapId:String):Int
	{
		var mapIdx:Int = getIndex(mapId);
		if (mapIdx == -1) return 32;		
		
		var tileSet:TiledTileSet = mapData[mapIdx].getTileSet(TILESET);
		return tileSet.tileHeight;	
	}
	
	public function getNextChanges(mapId:String, layers:Array<String>):Array<ChangeDescriptor>
	{
		if (!changeLists.exists(mapId)) return null;

		var changeResults:Array<ChangeDescriptor> = new Array<ChangeDescriptor>();		
		for (name in layers)
		{
			if (changeLists[mapId].exists(name))
			{
				changeResults = changeResults.concat(changeLists[mapId][name]);
			}
		}
		return changeResults;
	}
	
	public function getNextLevel(mapId:String):String
	{	
		var idx:Int = getIndex(mapId);
		if (idx >= 0 && idx < sequence.length - 1)
		{
			return sequence[idx + 1];
		}
		return "";
	}
	 
	public function loadEntities(level:String, game:PlayState, ?ignore:Array<String>):Void
	{
		var mapIdx:Int = getIndex(level);
		if (mapIdx == -1) return;
		
		
		var types:Array<String> = ["Player", "Key", "Lock", "Goal", "Enemy", "LadderTop"];
		var classes:Array<String> = ["org.chaoneurogue.characters.Player", "org.chaoneurogue.world.items.Key", "org.chaoneurogue.world.items.Lock", "org.chaoneurogue.world.items.Goal", "org.chaoneurogue.characters.Enemy", "org.chaoneurogue.world.items.LadderTop"];
		
		var objects:Array<TiledObject> = mapData[mapIdx].getObjectGroup("Items").objects;
		var classInstance:Entity;
		var i:Int = 0;
		var c:Class<Dynamic>;
		for (obj in objects)
		{
			i = 0;
			while ( i < types.length)
			{
				if ((ignore == null || ignore.indexOf(obj.type) == -1) && obj.type == types[i])
				{
					c = Type.resolveClass(classes[i]);
					classInstance = Type.createInstance(c, []);
					classInstance.load(obj, game);
					break;
				}
				i++;
			}			
		}
	}
}