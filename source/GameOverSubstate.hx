package;

import flixel.util.FlxDestroyUtil;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class GameOverSubstate extends MusicBeatSubstate
{
	// var bf:Boyfriend;
	var char:Character;
	var camFollow:FlxObject;

	// var stageSuffix:String = "";
	var noDeathAnim:Bool;
	var red = 28;
	var green = 96;
	var blue = 255;

	var deathTimer:FlxTimer = new FlxTimer();

	public function new(daChar:Character)
	{
		// var daStage = PlayState.curStage;
		// var daBf:String = '';
		// switch (daStage)
		// {
		// 	case 'school':
		// 		stageSuffix = '-pixel';
		// 		daBf = 'bf-pixel-dead';
		// 	case 'schoolEvil':
		// 		stageSuffix = '-pixel';
		// 		daBf = 'bf-pixel-dead';
		// 	default:
		// 		daBf = 'bf';
		// }

		char = daChar;

		super();

		Conductor.songPosition = 0;

		// bf = new Boyfriend(x, y, daBf);
		// add(bf);

		add(daChar);

		// camFollow = new FlxObject(camX, camY, 1, 1);
		// add(camFollow);
		// // FlxTween.tween(camFollow, {x: bf.getGraphicMidpoint().x, y: bf.getGraphicMidpoint().y}, 3, {ease: FlxEase.quintOut, startDelay: 0.5});
		// FlxTween.tween(camFollow, {x: daChar.getGraphicMidpoint().x, y: daChar.getGraphicMidpoint().y}, 3, {ease: FlxEase.quintOut, startDelay: 0.5});

		camFollow = new FlxObject(FlxG.camera.target == null ? 0 : FlxG.camera.target.x, FlxG.camera.target == null ? 0 : FlxG.camera.target.y, 1, 1);
		add(camFollow);
		FlxTween.tween(camFollow, {x: char.x + char.initWidth/2, y: char.y + char.height/2}, 3, {ease: FlxEase.quintOut, startDelay: 0.5});

		FlxG.sound.play('assets/sounds/fnf_loss_sfx' + TitleState.soundExt);
		Conductor.changeBPM(100);

		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		FlxG.camera.follow(camFollow, LOCKON, 0.01);

		// bf.playAnim('firstDeath');

		if (char.animation.getByName('firstDeath') != null)
		{
			noDeathAnim = false;
			char.playAnim('firstDeath');
		}
		else
		{
			noDeathAnim = true;
			char.animation.pause();
		}

		deathTimer.start(2.375, function(_)
		{
			FlxG.sound.playMusic('assets/music/gameOver' + TitleState.soundExt);
		});
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (noDeathAnim && char != null)
			char.setColorTransform(0, 0, 0, 1, red, green, blue);

		FlxG.camera.follow(camFollow, LOCKON);

		if (controls.ACCEPT)
		{
			endBullshit();
		}

		if (controls.BACK)
		{
			FlxG.sound.music.stop();

			if (PlayState.isStoryMode)
				FlxG.switchState(new MainMenuState());
			else
				FlxG.switchState(new FreeplayState());
		}

		// if (char.animation.getByName('firstDeath') != null
		// 	&& char.animation.curAnim.name == 'firstDeath'
		// 	&& char.animation.curAnim.finished)
		// {
		// 	FlxG.sound.playMusic('assets/music/gameOver' + TitleState.soundExt);
		// }

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
	}

	override function beatHit()
	{
		super.beatHit();

		FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			FlxDestroyUtil.destroy(deathTimer);
			FlxG.sound.music.stop();
			FlxG.sound.play('assets/music/gameOverEnd' + TitleState.soundExt);

			if (char.animation.getByName('deathConfirm') != null)
				char.playAnim('deathConfirm', true);
			if (noDeathAnim)
			{
				FlxTween.tween(this, {'red': 255, 'blue': 255, 'green': 255}, 0.08);
			}

			new FlxTimer().start(0.4, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 1.2, false, function()
				{
					FlxG.switchState(new PlayState());
				});
			});
		}
	}
}
