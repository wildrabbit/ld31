package org.chaoneurogue.ui;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.ui.FlxButton;
import org.chaoneurogue.ld31.PlayState;
import org.chaoneurogue.ld31.PlayState.MenuPhase;

/**
 * ...
 * @author ith1ldin
 */
class Menu extends FlxSpriteGroup
{
	var menuState:MenuPhase;
	var game:PlayState;
	
	var bg:FlxSprite;
	var play:FlxButton;
	var restart:FlxButton;
	var back:FlxButton;
	var menu:FlxButton;
	var mute:FlxButton;
	var quitButton:FlxButton;
	var info:FlxSprite;
	
	public function new(game:PlayState, menuState:MenuPhase, ?X:Float = 0, ?Y:Float = 0, ?MaxSize:Int = 0):Void
	{
		super(X, Y, MaxSize);
		this.game = game;
		
		bg = new FlxSprite(0, 0, "assets/images/menu_bg.png");
		add(bg);
		
		play = new FlxButton(32, 32, "", onPlayClick);
		play.loadGraphic("assets/images/btn_play.png");
		add(play);
		
		menu = new FlxButton(0, 0, "", onMenuClick);
		menu.loadGraphic("assets/images/btn_menu.png");
		
		mute = new FlxButton(32, 128, "", onToggleSoundClick);
		mute.loadGraphic("assets/images/btn_mute.png");
//		add(mute);
		
		#if !html5
		quitButton = new FlxButton(0, 0 /*224*/, "", onQuitClick);
		quitButton.loadGraphic("assets/images/btn_exit.png");
		#end
		
		info = new FlxSprite(bg.width - 172, 304, "assets/images/info.png");
		add(info);
		
		changeState(menuState);
	}
	
	public function changeState(newState:MenuPhase):Void
	{
		//Rebuild buttons
		menuState = newState;
		if (menuState == PauseScreen) 
		{ 
			menu.setPosition(32, 128);
			add(menu); 
			remove(quitButton); 
		}
		if (menuState == MenuScreen)
		{
			quitButton.setPosition(32, 128);
			add(quitButton);		
			remove(menu);
		}
		
	}
	
	public function onPlayClick():Void
	{
		game.onPlay();
		FlxG.sound.play("assets/sounds/click.wav");
	}
	
	public function onToggleSoundClick():Void
	{
		FlxG.sound.muted = !FlxG.sound.muted;
	}
	
	public function onQuitClick():Void
	{
		FlxG.sound.play("assets/sounds/click.wav");
		game.onExit();
	}
	
	public function onMenuClick():Void
	{
		FlxG.sound.play("assets/sounds/click.wav");
		game.onBackToMenu();
	}
}