package org.chaoneurogue.ld31;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tile.FlxTile;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxMath;
import flixel.util.FlxTimer;
import flixel.util.loaders.CachedGraphics;
import flash.geom.Rectangle;
import flash.geom.Point;
import openfl.display.BitmapData;
import openfl.system.System;
import org.chaoneurogue.characters.Enemy;
import org.chaoneurogue.characters.Player;
import org.chaoneurogue.ui.Intro;
import org.chaoneurogue.ui.Menu;
import org.chaoneurogue.utils.MyFlxTileMap;
import org.chaoneurogue.world.Entity;
import org.chaoneurogue.world.items.Goal;
import org.chaoneurogue.world.items.Key;
import org.chaoneurogue.world.items.LadderTop;
import org.chaoneurogue.world.items.Lock;
import org.chaoneurogue.world.World;
import org.chaoneurogue.world.ChangeDescriptor;


	enum FlowPhase
	{
		MenuDisplayed;
		Playing;
		Dialogue;
		Transition;
		Results;
	}
	
	enum MenuPhase
	{
		Disabled;
		IntroScreen;
		MenuScreen;
		PauseScreen;
	}
	

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	var phase:FlowPhase;
	var nextPhase:FlowPhase;
	var previous:FlowPhase;

	var background:FlxSprite;
	public var tiles:org.chaoneurogue.utils.MyFlxTileMap;
	public var stairs:org.chaoneurogue.utils.MyFlxTileMap;
	
	public var keys:FlxTypedGroup<Key>;
	public var locks:FlxTypedGroup<Lock>;
	public var enemies:FlxTypedGroup<Enemy>;
	public var ladders: FlxTypedGroup<LadderTop>;
	
	public var goal:Goal;
	public var player:Player;
	private var goalCount:Int = 0;
	
	var menu:Menu;
	var intro:Intro;
	
	var world:World;
	
	var startLevel:String;
	var currentLevel:String;
	var nextLevel:String;
	
	var fadeOutTime:Float = 0.5;
	var elapsedFadeOut:Float = -1;
	var fadeInTime:Float = 0.5;
	var elapsedFadeIn:Float = -1;
	
	var transitionTiles:FlxTypedGroup<FlxSprite>;
	var transitionChanges:Array<ChangeDescriptor>;
	
	var gameWon:Bool = false;
	var gameLost:Bool = false;
	
	var menuState:MenuPhase;
	var introTimer:FlxTimer;
	
	var viewGameOver:FlxSprite;
	var viewGameWon:FlxSprite;
	
	//var scene:FlxTypedGroup<FlxSprite>;
	
	/**
	 * Function that is called up when to state is created to set it up.
	 */
	override public function create():Void
	{
		super.create();
		
		phase = MenuDisplayed;
		nextPhase = null;
		previous = null;
		
		world = new World(["level1.tmx", "level2.tmx", "level3.tmx"]);
		startLevel  = "level1";
		currentLevel = startLevel;
		
		transitionTiles = new FlxTypedGroup<FlxSprite>();
		add(transitionTiles);
		transitionChanges = new Array<ChangeDescriptor>();
		
		buildLevel(startLevel);
		
		menuState = IntroScreen;
		
		intro = new Intro(0, 0, "assets/images/intro.png");
		centerUI(intro);
		add(intro);
		introTimer = new FlxTimer();
		introTimer.start(2 , onMenu);
		
		menu = new Menu(this, menuState);
		centerUI(menu);
		add(menu);
		
		menu.visible = false;
		menu.active = false;
		Entity.paused = true;
		
		viewGameOver = new FlxSprite(0, 0, "assets/images/gameover.png");
		centerUI(viewGameOver);
		viewGameWon = new FlxSprite(0, 0, "assets/images/gamewon.png");
		centerUI(viewGameWon);
	}
	
	private function centerUI(obj:FlxObject):Void
	{
		#if html5
			obj.x = (800- obj.width) * 0.5;
			obj.y = (640 - obj.height) * 0.5;		
		#else
			obj.x = (FlxG.width - obj.width) * 0.5;
			obj.y = (FlxG.height - obj.height) * 0.5;
		#end
	}

	/**
	 * Function that is called when this state is destroyed - you might want to
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		super.update();
		
		switch(phase)
		{
			case FlowPhase.MenuDisplayed:
			{
				if (menuState == IntroScreen)
				{
					if (FlxG.keys.justReleased.ANY || FlxG.mouse.justReleased)
					{
						FlxG.sound.play("assets/sounds/click.wav");
						onMenu(null);						
					}
				}
				else if (menuState == MenuScreen)
				{
					if (FlxG.keys.justReleased.P)
					{
						FlxG.sound.play("assets/sounds/click.wav");
						onPlay();
						player.say(0);
					}
					else if (FlxG.keys.justReleased.X)
					{
						FlxG.sound.play("assets/sounds/click.wav");						
						onExit();
					}
				}
				else if (menuState == PauseScreen)
				{
					if (FlxG.keys.justReleased.P)
					{
						FlxG.sound.play("assets/sounds/click.wav");										
						onPlay();
					}
					if (FlxG.keys.justReleased.E)
					{
						FlxG.sound.play("assets/sounds/click.wav");												
						onBackToMenu();
					}					
				}
			}
			case FlowPhase.Playing:
			{
				//if (FlxG.keys.anyJustPressed(["N"]))
				//{
					//onNextLevel();	
				//}	
				if (FlxG.keys.justReleased.P)
				{
					FlxG.sound.play("assets/sounds/click.wav");																	
					onPause();
				}
				//else if (FlxG.keys.anyJustReleased(["R"]))
				//{
					//onRestart();
				//}				
			}
			case FlowPhase.Dialogue:
			{
				
			}
			case FlowPhase.Transition:
			{
				updateTransition();				
			}
			case FlowPhase.Results:
			{
				if (FlxG.keys.justReleased.ANY || FlxG.mouse.justReleased)
				{
					FlxG.sound.play("assets/sounds/click.wav");																	
					onBackToMenu();						
				}
			}
		}
		
		if (nextPhase != null && nextPhase != phase)
		{
			changePhase(nextPhase);
		}
	}
	
	private function updateTransition():Void
	{
		var delta:Float = FlxG.elapsed;
		if (elapsedFadeOut >= 0)
		{
			elapsedFadeOut += delta;
			if (elapsedFadeOut >= fadeOutTime)
			{
				//Purge items:
				for (tile in transitionTiles)
				{
					remove(tile);
					tile.destroy();
				}
				transitionTiles.clear();
				
				//Clear objects
				remove(goal);
				goal.destroy();				
				goal = null;
				
				for (key in keys)
				{
					remove(key);
					key.destroy();
				}
				keys.clear();
				
				for (lock in locks)
				{
					remove(lock);
					lock.destroy();
				}
				locks.clear();
				
				for (enemy in enemies)
				{
					remove(enemy);
					enemy.destroy();
				}
				enemies.clear();
				
				for (ladder in ladders)
				{
					remove(ladder);
					ladder.destroy();
				}
				ladders.clear();
				
				elapsedFadeOut = -1.0;
				
				var sp:FlxSprite = null;
				
				for (change in transitionChanges)
				{
					sp = getSpriteFromTileset(change, 32, 32);
					if (sp != null)
					{
						add(sp);
						transitionTiles.add(sp);
					}
				}
				world.loadEntities(world.getNextLevel(currentLevel), this, ["Player"]);
				
				startTilesFadein(fadeInTime);
				startObjectsFadein(fadeInTime);
				
				elapsedFadeIn = 0.0;
			}			
		}
		else if (elapsedFadeIn >= 0)
		{
			elapsedFadeIn += delta;
			if (elapsedFadeIn >= fadeInTime)
			{
				for (change in transitionChanges)
				{
					if (change.layer == "Level")
						tiles.setTile(change.col, change.row, change.newValue);
					else if (change.layer == "Stairs")
						stairs.setTile(change.col, change.row, change.newValue);
				}
				for (tile in transitionTiles)
				{
					tile.destroy();
				}
				transitionTiles.clear();
				
				var next:String = world.getNextLevel(currentLevel);
				if (next != "")
				{
					currentLevel = next;
					
					FlxG.log.add('Changed level to $currentLevel');
				}
				player.onStartLevel();	
				elapsedFadeIn = -1.0;
				nextPhase = previous;
				previous = null;
			}
		}
	}
	
	private function changePhase(next:FlowPhase):Void
	{
		if (next == null) return;
		switch(next)
		{
			case FlowPhase.Playing:
			{
				
			}
			case FlowPhase.MenuDisplayed:
			{
				
			}			
			case FlowPhase.Dialogue:
			{
				
			}			
			case FlowPhase.Transition:
			{
				
			}			
			case FlowPhase.Results:
			{
			
			}			
		}
		phase = next;
	}
	
	private function buildLevel(level:String):Void
	{
		background = new FlxSprite(0, 0, "assets/images/bg.png");
		add(background);
		
		buildTilemap();
		
		if (keys == null) 
		{
			keys = new FlxTypedGroup<Key>();
			add(keys);
		}
		
		if (locks == null)
		{
			locks = new FlxTypedGroup <Lock>();
			add(locks);			
		}
		
		if (enemies == null)
		{
			enemies = new FlxTypedGroup<Enemy>();
			add(enemies);
		}
		
		if (ladders == null)
		{
			ladders = new FlxTypedGroup<LadderTop>();
			add(ladders);
		}
		
		world.loadEntities(currentLevel, this);
		//buildPlayer();
		//buildGoal();
		//buildKeys();
		//buildLocks();
				
	}
	
	private function buildTilemap():Void
	{
		tiles = new MyFlxTileMap();
		var tileArray:Array<Int> = world.getTiles(currentLevel, "Level");
		var img:String = world.getImage(currentLevel);
		var tileWidth:Int = world.getTileWidth(currentLevel);
		var tileHeight:Int = world.getTileHeight(currentLevel);
		
		tiles.widthInTiles = world.cols;
		tiles.heightInTiles = world.rows;
		tiles.loadMap(tileArray, img, tileWidth, tileHeight, 0, 1, 1, 3);
		
		tiles.setTileProperties(1, FlxObject.ANY);
		tiles.setTileProperties(2, FlxObject.NONE);
		
		add(tiles);
		
		stairs = new MyFlxTileMap();
		tileArray = world.getTiles(currentLevel, "Stairs");
		
		stairs.widthInTiles = world.cols;
		stairs.heightInTiles = world.rows;
		stairs.loadMap(tileArray, img, tileWidth, tileHeight, 0, 1, 1,3);
		
		stairs.setTileProperties(2, FlxObject.ANY);
		//stairs.setTileProperties(1, FlxObject.NONE);
		
		add(stairs);
	}
	
	public function setPlayer(player:Player):Void
	{
		this.player = player;
		add(player);
	}
	
	public function setGoal(goal:Goal):Void
	{
		this.goal = goal;
		add(goal);
	}
	
	public function addKey(key:Key):Void
	{
		keys.add(key);
	}
	
	public function addLock(lock:Lock):Void
	{
		locks.add(lock);
	}
	
	public function addEnemy(enemy:Enemy):Void
	{
		enemies.add(enemy);
	}
	
	public function addLadder(ladder:LadderTop):Void
	{
		ladders.add(ladder);
	}
	
	public function onGameWon(t:FlxTween):Void
	{
		FlxG.sound.play("assets/sounds/gamewon.wav");												
		add(viewGameWon);
		nextPhase = Results;
	}
	
	public function onNextLevel():Void
	{
		previous = phase;
		player.onNextLevel();		
			
		
		transitionChanges = world.getNextChanges(currentLevel, ["Level","Stairs"]);
		if (transitionChanges == null) 
		{
			player.say(3);
			previous = null; 
			gameWon = true;
			Entity.paused = true;
			
			goal.startFadeOut(0.8, onGameWon);
			return;
		}
		else
		{
			goalCount++;
			player.say(goalCount);
			FlxG.sound.play("assets/sounds/wrongorb.wav");															
		}
		
		var sprite:FlxSprite = null;
		for (change in transitionChanges)
		{
			if (change.layer == "Level")
			{
				sprite = tiles.tileToFlxSprite(change.col, change.row);
			}
			else if (change.layer == "Stairs")
			{
				sprite = stairs.tileToFlxSprite(change.col, change.row);
			}
			add(sprite);
			transitionTiles.add(sprite);
		}
		
		startTilesFadeout(fadeOutTime);
		startObjectsFadeout(fadeOutTime);
		elapsedFadeOut = 0.0;
		nextPhase = Transition;
	}
	private function startTilesFadeout(time:Float):Void
	{
		for (tile in transitionTiles)
		{
			tile.alpha = 1;
			tile.scale.set(1, 1);
			tile.origin.x = tile.width / 2;
			tile.origin.y = tile.height / 2;
			
			FlxTween.tween(tile, { alpha:0 }, time, { type:FlxTween.ONESHOT, ease:FlxEase.backOut } );
			FlxTween.tween(tile.scale, { x:0, y:0}, time, {type:FlxTween.ONESHOT, ease:FlxEase.backOut} );
		}
	}
	
	private function startObjectsFadeout(time:Float):Void
	{
		if (goal != null) 
		{
			goal.startFadeOut(time);
		}
		
		for (key in keys)
		{
			key.startFadeOut(time);
		}
		
		for (lock in locks)
		{
			lock.startFadeOut(time);
		}
		
		for (enemy in enemies)
		{
			enemy.startFadeOut(time);
		}
	}

	private function startTilesFadein(time:Float):Void
	{
		for (tile in transitionTiles)
		{
			tile.alpha = 0;
			tile.scale.set(0,0);
			tile.origin.x = tile.width / 2;
			tile.origin.y = tile.height / 2;
			
			FlxTween.tween(tile, { alpha:1 }, time, { type:FlxTween.ONESHOT, ease:FlxEase.backIn } );
			FlxTween.tween(tile.scale, { x:1, y:1} , time, {type:FlxTween.ONESHOT, ease:FlxEase.backIn} );
		}
	}
	
	private function startObjectsFadein(time:Float):Void
	{
		if (goal != null) 
		{
			goal.startFadeIn(time);
		}
		
		for (key in keys)
		{
			key.startFadeIn(time);
		}
		
		for (lock in locks)
		{
			lock.startFadeIn(time);
		}
		
		for (enemy in enemies)
		{
			enemy.startFadeIn(time);
		}
	}

	private function getSpriteFromTileset(changeDesc:ChangeDescriptor, tileWidth:Int, tileHeight:Int):FlxSprite
	{
		var oldValue:Int = tiles.getTile(changeDesc.col, changeDesc.row);
		if (changeDesc.layer == "Level")
		{
			tiles.setTile(changeDesc.col, changeDesc.row, changeDesc.newValue);
			return tiles.tileToFlxSprite(changeDesc.col, changeDesc.row, oldValue);
		}
		else if (changeDesc.layer == "Stairs")
		{
			stairs.setTile(changeDesc.col, changeDesc.row, changeDesc.newValue);
			return stairs.tileToFlxSprite(changeDesc.col, changeDesc.row, oldValue);						
		}

		return null;
	}

	public function onBackToMenu():Void
	{
		menu.visible = menu.active = false;
		onRestart();
		onIntro();
	}
	
	private function onRestart():Void
	{
		remove(menu);
		menu.destroy();
		
		player.shut();
		
		menu = new Menu(this, menuState);
		centerUI(menu);
		add(menu);
		
		goalCount = 0;
		
		if (gameWon)
		{
			remove(viewGameWon);
		}
		if (gameLost)
		{
			remove(viewGameOver);
		}
		gameWon = gameLost = false;
		
		
		if (transitionChanges != null)
		{
			transitionChanges.splice(0, transitionChanges.length);
		}
		transitionChanges = new Array<ChangeDescriptor>();
		
		remove(background);
		background.destroy();
		background = null;
		
		remove(tiles);
		tiles.destroy();
		tiles = null;
		
		remove(stairs);
		stairs.destroy();
		stairs = null;
		
		
		//Purge items:
		for (tile in transitionTiles)
		{
			remove(tile);
			tile.destroy();
		}
		transitionTiles.clear();
		
		remove(player);
		player.destroy();
		player = null;
		
		//Clear objects
		remove(goal);
		goal.destroy();				
		goal = null;
		
		for (key in keys)
		{
			remove(key);
			key.destroy();
		}
		keys.clear();
		
		for (lock in locks)
		{
			remove(lock);
			lock.destroy();
		}
		locks.clear();
		
		for (enemy in enemies)
		{
			remove(enemy);
			enemy.destroy();
		}
		enemies.clear();
		
		for (ladder in ladders)
		{
			remove(ladder);
			ladder.destroy();
		}
		ladders.clear();

		startLevel  = "level1";
		currentLevel = startLevel;
		buildLevel(currentLevel);
	}
	
	public function removeKey(k:Key):Void
	{
		keys.remove(k, true);
		remove(k);
		k.destroy();

	}
	
	public function removeLock(l:Lock):Void
	{
		locks.remove(l, true);
		remove(l);
		l.destroy();
	}	
	
	public function onPlayerDied():Void
	{
		//Game over
		remove(player);
		player.destroy();
		
		gameLost = true;
		Entity.paused = true;
		nextPhase = FlowPhase.Results;
		FlxG.sound.play("assets/sounds/gameover.wav");														
		add(viewGameOver);
	}
	
	public function onEnemyDied(e:Enemy):Void
	{
		remove(e);
		enemies.remove(e);
		e.destroy();
	}
	
	public function onPlay():Void
	{
		menuState = Disabled;
		FlxG.mouse.visible = false;
		intro.visible = false;
		intro.active = false;
		menu.visible = false;
		menu.active = false;
		Entity.paused = false;
		nextPhase = Playing;
		
	}
	
	public function onIntro():Void
	{
		intro.visible = true;
		intro.active = true;
		menu.visible = false;
		menu.active = false;
		FlxG.mouse.visible = false;		
		if (!Entity.paused) Entity.paused = true;
		introTimer.start(2, onMenu);
		
		nextPhase = MenuDisplayed;
		menuState = IntroScreen;
	}
	public function onMenu(timer:FlxTimer):Void
	{
		intro.visible = false;
		intro.active = false;
		menu.visible = true;
		menu.active = true;
		FlxG.mouse.visible = true;		
		if (!Entity.paused) Entity.paused = true;	
		introTimer.cancel();
		menuState = MenuScreen;
		menu.changeState(menuState);
	}
	
	public function onExit():Void
	{
		#if !html5
			System.exit(0);
		#end
	}
	
	public function onPause():Void
	{
		intro.visible = false;
		intro.active = false;
		FlxG.mouse.visible = true;		
		if (!Entity.paused) Entity.paused = true;	
		nextPhase = MenuDisplayed;
		menuState = PauseScreen;
		menu.active = menu.visible = true;
		menu.changeState(menuState);		
	}
}