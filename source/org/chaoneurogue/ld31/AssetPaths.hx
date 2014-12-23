package org.chaoneurogue.ld31;

@:build(flixel.system.FlxAssets.buildFileReferences("assets", true))
class AssetPaths { }

#if !html5
@:sound("assets/sounds/click.wav")
class ClickSound extends Sound;

@:sound("assets/sounds/collidelock.wav")
class CollideLockSound extends Sound;

@:sound("assets/sounds/gameover.wav")
class GameOverSound extends Sound;

@:sound("assets/sounds/gamewon.wav")
class GameWonSound extends Sound;

@:sound("assets/sounds/jump.wav")
class JumpSound extends Sound;

@:sound("assets/sounds/keypicked.wav")
class KeyPickedSound extends Sound;

@:sound("assets/sounds/lockpicked.wav")
class LockPickedSound extends Sound;

@:sound("assets/sounds/wrongorb.wav")
class WrongOrbSound extends Sound;
#end