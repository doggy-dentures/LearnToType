package;

import sys.FileSystem;
import flixel.util.FlxDestroyUtil;
import flixel.FlxState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class EndState extends FlxState
{
	var doof:DialogueBox;

	var dialogue:Array<String> = ['strange code', '>:]'];

	override function create()
	{
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		if (FileSystem.exists("assets/data/end/dialogue-" + PlayState.SONG.player1 + ".txt"))
		{
			try
			{
				dialogue = CoolUtil.coolTextFile("assets/data/end/dialogue-" + PlayState.SONG.player1 + ".txt");
			}
			catch (e)
			{
			}
		}

		doof = new DialogueBox(false, dialogue);
		doof.scrollFactor.set();
		doof.finishThing = function()
		{
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				// FlxG.sound.playMusic("assets/music/klaskiiLoop.ogg", 0.75);
				PlayerSettings.menuControls();
				FlxG.switchState(new MainMenuState());
				FlxDestroyUtil.destroy(tmr);
			});
		};

		intro(doof);
	}

	function intro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				add(dialogueBox);
				remove(black);
				FlxDestroyUtil.destroy(tmr);
			}
		});
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
