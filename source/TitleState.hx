package;

import flixel.util.FlxDestroyUtil;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import io.newgrounds.NG;
import lime.app.Application;
import openfl.Assets;

// import polymod.Polymod;
using StringTools;

class TitleState extends MusicBeatState
{
	static var initialized:Bool = true;
	static public var soundExt:String = ".ogg";

	override public function create():Void
	{
		// Polymod.init({modRoot: "mods", dirs: ['introMod']});

		// DEBUG BULLSHIT

		super.create();
		FlxG.mouse.visible = false;

		FlxG.save.bind('data');

		Highscore.load();

		if (FlxG.save.data.weekUnlocked != null)
		{
			// FIX LATER!!!
			// WEEK UNLOCK PROGRESSION!!
			// StoryMenuState.weekUnlocked = FlxG.save.data.weekUnlocked;

			if (StoryMenuState.weekUnlocked.length < 4)
				StoryMenuState.weekUnlocked.insert(0, true);

			// QUICK PATCH OOPS!
			if (!StoryMenuState.weekUnlocked[0])
				StoryMenuState.weekUnlocked[0] = true;
		}

		KeyBinds.keyCheck();
		PlayerSettings.init();

		Main.fpsDisplay.visible = true;

		Main.playMusic();

		startIntro();
	}

	var logoBl:FlxSprite;
	// var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;
	var logoTween:FlxTween;
	var startTween:FlxTween;
	var bfSprite:FlxSprite;
	var bfTween:FlxTween;

	function startIntro()
	{
		Conductor.changeBPM(140);
		persistentUpdate = true;

		logoBl = new FlxSprite().loadGraphic(Paths.image('blocklogo'));
		logoBl.antialiasing = true;
		logoBl.scale.x = logoBl.scale.y = 0.5;
		logoBl.updateHitbox();
		logoBl.y = 20;
		logoBl.x = FlxG.width - logoBl.width - 20;

		var bgGrad:FlxSprite = new FlxSprite().loadGraphic(Paths.image('learn'));
		bgGrad.antialiasing = true;
		bgGrad.updateHitbox();

		add(bgGrad);
		add(logoBl);

		// titleText = new FlxSprite(100, FlxG.height * 0.8);
		// titleText.frames = Paths.getSparrowAtlas("titleEnter");
		// titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		// titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		// titleText.antialiasing = true;
		// titleText.animation.play('idle');
		// titleText.updateHitbox();
		// titleText.screenCenter(X);
		titleText = new FlxSprite().loadGraphic(Paths.image('start'));
		titleText.antialiasing = true;
		titleText.screenCenter(X);
		titleText.y = FlxG.height - titleText.height - 10;
		add(titleText);

		startTween = FlxTween.tween(titleText, {"alpha": 0.6}, 1, {type: PINGPONG});

		bfSprite = new FlxSprite().loadGraphic(Paths.image('KeyboardBF'));
		bfSprite.antialiasing = true;
		bfSprite.scale.x = bfSprite.scale.y = 0.9;
		bfSprite.updateHitbox();
		bfSprite.y = 30;
		bfSprite.x = 30;
		add(bfSprite);

		skipIntro();
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		if (initialized)
		{
			Conductor.songPosition = FlxG.sound.music.time;
			// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

			if (FlxG.keys.justPressed.F)
			{
				FlxG.fullscreen = !FlxG.fullscreen;
			}

			var pressedEnter:Bool = controls.ACCEPT || controls.PAUSE;

			if (pressedEnter && !transitioning && skippedIntro)
			{
				// titleText.animation.play('press');

				FlxG.camera.flash(FlxColor.WHITE, 1);
				FlxG.sound.play('assets/sounds/confirmMenu' + TitleState.soundExt, 0.7);

				transitioning = true;
				// FlxG.sound.music.stop();

				new FlxTimer().start(2, function(tmr:FlxTimer)
				{
					// Check if version is outdated
					FlxG.switchState(new MainMenuState());
				});
				// FlxG.sound.play('assets/music/titleShoot' + TitleState.soundExt, 0.7);
			}
		}

		super.update(elapsed);
	}

	override function beatHit()
	{
		super.beatHit();

		// logoBl.animation.play('bump', true);
		// danceLeft = !danceLeft;
		if (logoTween != null)
			logoTween.cancel();
		logoTween = FlxTween.tween(logoBl, {"scale.x": 0.5125, "scale.y": 0.5125}, Conductor.stepCrochet * 1 / 1000, {
			onComplete: function(_)
			{
				logoBl.scale.x = logoBl.scale.y = 0.5;
			}
		});

		if (bfTween != null)
			bfTween.cancel();
		bfTween = FlxTween.tween(bfSprite, {"scale.x": 0.9125, "scale.y": 0.9125}, Conductor.stepCrochet * 1 / 1000, {
			onComplete: function(_)
			{
				bfSprite.scale.x = bfSprite.scale.y = 0.9;
			}
		});

		// if (danceLeft)
		// 	gfDance.animation.play('danceRight', true);
		// else
		// 	gfDance.animation.play('danceLeft', true);

		FlxG.log.add(curBeat);
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			FlxG.camera.flash(FlxColor.WHITE, 1);
			PlayerSettings.player1.controls.loadKeyBinds();
			Config.configCheck();
			skippedIntro = true;
		}
	}

	override public function destroy()
	{
		FlxDestroyUtil.destroy(logoTween);
		FlxDestroyUtil.destroy(startTween);
		super.destroy();
	}
}
