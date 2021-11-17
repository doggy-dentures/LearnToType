package;

import lime.utils.Assets;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using StringTools;

class DialogueBox extends FlxSpriteGroup
{
	var box:FlxSprite;

	var curCharacter:String = '';

	// var dialogue:Alphabet;
	var dialogueList:Array<String> = [];

	// SECOND DIALOGUE FOR THE PIXEL SHIT INSTEAD???
	var swagDialogue:FlxTypeText;

	var skipNotice:FlxText = new FlxText(0,0,0,"Press ESC to skip");

	public var finishThing:Void->Void;

	var handSelect:FlxSprite;
	var bgFade:FlxSprite;

	var portraits:Map<String, FlxSprite> = new Map<String, FlxSprite>();

	public function new(talkingRight:Bool = true, ?dialogueList:Array<String>)
	{
		super();

		bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), 0xFFB3DFd8);
		bgFade.scrollFactor.set();
		bgFade.alpha = 0;
		add(bgFade);

		new FlxTimer().start(0.83, function(tmr:FlxTimer)
		{
			bgFade.alpha += (1 / 5) * 0.7;
			if (bgFade.alpha > 0.7)
				bgFade.alpha = 0.7;
		}, 5);

		var allChars = Main.characters.copy();
		allChars.push("betty");

		for (name in allChars)
		{
			var sprite = new FlxSprite();
			if (Assets.exists('assets/images/dialogue/' + name + '.png'))
				sprite.loadGraphic('assets/images/dialogue/' + name + '.png');
			else
				sprite.loadGraphic('assets/images/dialogue/test.png');
			sprite.scrollFactor.set();
			add(sprite);
			sprite.visible = false;
			if (name != 'senpai')
				sprite.antialiasing = true;
			portraits[name] = sprite;
		}

		box = new FlxSprite(-20, 45);

		switch (PlayState.SONG.song.toLowerCase())
		{
			default:
				box.loadGraphic('assets/images/chalkboard.png');
				box.y = FlxG.height - box.height;
		}

		add(box);

		box.screenCenter(X);

		if (!talkingRight)
		{
			// box.flipX = true;
		}

		// dropText = new FlxText(242, 502, Std.int(FlxG.width * 0.6), "", 32);
		// dropText.font = "assets/fonts/EraserDust.ttf";
		// dropText.color = 0xFFD89494;
		// add(dropText);

		swagDialogue = new FlxTypeText(240, 500, Std.int(FlxG.width * 0.6), "", 32);
		swagDialogue.font = "assets/fonts/EraserDust.ttf";
		swagDialogue.color = 0xFF3F2021;
		swagDialogue.sounds = [FlxG.sound.load('assets/sounds/pop' + TitleState.soundExt, 0.6)];
		add(swagDialogue);

		// dialogue = new Alphabet(0, 80, "", false, true);
		// dialogue.x = 90;
		// add(dialogue);

		this.dialogueList = dialogueList;

		skipNotice.setFormat(null, 16, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		skipNotice.x = box.x;
		skipNotice.y = box.y - skipNotice.height - 5;
		add(skipNotice);
	}

	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;

	override function update(elapsed:Float)
	{
		switch (PlayState.SONG.song.toLowerCase())
		{
			default:
				swagDialogue.color = FlxColor.WHITE;
				// dropText.color = FlxColor.BLACK;
		}

		// dropText.text = swagDialogue.text;

		dialogueOpened = true;

		if (dialogueOpened && !dialogueStarted)
		{
			startDialogue();
			dialogueStarted = true;
		}

		if (FlxG.keys.justPressed.ANY && dialogueStarted)
		{
			// remove(dialogue);
			

			FlxG.sound.play('assets/sounds/whoosh' + TitleState.soundExt, 0.8);

			if (dialogueList[1] == null || FlxG.keys.justPressed.ESCAPE)
			{
				if (!isEnding)
				{
					isEnding = true;

					skipNotice.visible = false;

					new FlxTimer().start(0.2, function(tmr:FlxTimer)
					{
						box.alpha -= 1 / 5;
						bgFade.alpha -= 1 / 5 * 0.7;
						for (char in portraits)
						{
							char.visible = false;
						}
						swagDialogue.alpha -= 1 / 5;
						// dropText.alpha = swagDialogue.alpha;
					}, 5);

					new FlxTimer().start(1.2, function(tmr:FlxTimer)
					{
						finishThing();
						kill();
					});
				}
			}
			else if (!isEnding)
			{
				dialogueList.remove(dialogueList[0]);
				startDialogue();
			}
		}

		super.update(elapsed);
	}

	var isEnding:Bool = false;

	function startDialogue():Void
	{
		cleanDialog();

		swagDialogue.resetText(dialogueList[0]);
		swagDialogue.start(0.04, true);

		for (char in portraits)
		{
			char.visible = false;
		}
		if (portraits[curCharacter] != null)
		{
			portraits[curCharacter].visible = true;
		}
	}

	function cleanDialog():Void
	{
		var splitName:Array<String> = dialogueList[0].split(":");
		curCharacter = splitName[1];
		dialogueList[0] = dialogueList[0].substr(splitName[1].length + 2).trim();
	}
}
