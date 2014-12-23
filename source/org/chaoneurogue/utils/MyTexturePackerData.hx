package org.chaoneurogue.utils;

import flixel.util.loaders.TexturePackerData;
import openfl.geom.Rectangle;

/**
 * ...
 * @author ith1ldin
 */
class MyTexturePackerData extends TexturePackerData
{

	public function new(Description:String, AssetName:String) 
	{
		super(Description, AssetName);
		
	}
	
	public function getFrameRectangle(name:String):Rectangle
	{
		for (frame in this.frames)
		{
			if (frame.name == name)
			{
				return frame.frame;
			}
		}		
		return null;
	}
}