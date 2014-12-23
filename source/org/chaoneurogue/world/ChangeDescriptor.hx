package org.chaoneurogue.world;

/**
 * ...
 * @author ith1ldin
 */
class ChangeDescriptor
{
	public var col:Int;
	public var row:Int;
	public var newValue:Int;
	public var layer:String;
	
	public function new(layer:String, row:Int, col:Int, newValue:Int) 
	{
		this.row = row;
		this.col = col;
		this.layer = layer;
		this.newValue = newValue;
	}
	
}