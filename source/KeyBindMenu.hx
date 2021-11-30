package;

import flixel.input.FlxInput;
import flixel.input.keyboard.FlxKey;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import io.newgrounds.NG;
import lime.app.Application;
import lime.utils.Assets;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.input.FlxKeyManager;

using StringTools;

class KeyBindMenu extends MusicBeatState
{
	var keyTextDisplay:FlxText;
	var keyWarning:FlxText;
	var warningTween:FlxTween;
	var backText:FlxText;

	var selectArray:Array<FlxText> = [];
	var selected:Int = 0;
	var currentLetter:Int = 0;

	var tempKeyMap:Map<Int, String>;

	var state:String = "select";

	var blacklist:Array<String> = ["ESCAPE", "ENTER", "BACKSPACE", "SPACE", "DELETE"];

	override function create()
	{
		// FlxG.sound.playMusic('assets/music/configurator' + TitleState.soundExt);

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic('assets/images/menuDesat.png');
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0;
		bg.setGraphicSize(Std.int(bg.width * 1.18));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		bg.color = 0xFF9766BE;
		add(bg);

		keyTextDisplay = new FlxText(0, 50, 1280, "Select a keyboard layout or manually assign keys if your layout is not of these:");
		keyTextDisplay.scrollFactor.set(0, 0);
		keyTextDisplay.setFormat(null, 24, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		keyTextDisplay.borderSize = 3;
		keyTextDisplay.borderQuality = 1;
		keyTextDisplay.updateHitbox();
		add(keyTextDisplay);

		for (i in 0...3)
		{
			selectArray[i] = new FlxText(0, 80 * (i + 2), 1280, "", 72);
			selectArray[i].scrollFactor.set(0, 0);
			selectArray[i].setFormat("assets/fonts/Funkin-Bold.otf", 72, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			selectArray[i].borderSize = 3;
			selectArray[i].borderQuality = 1;
			add(selectArray[i]);
		}
		selectArray[0].text = "QWERTY";
		selectArray[1].text = "AZERTY";
		selectArray[2].text = "MANUALLY ASSIGN";

		keyWarning = new FlxText(0, 580, 1280, "WARNING: BIND NOT SET. KEY IS ALREADY IN USE OR IS INVALID. TRY ANOTHER KEY", 42);
		keyWarning.scrollFactor.set(0, 0);
		keyWarning.setFormat("assets/fonts/vcr.ttf", 42, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		keyWarning.borderSize = 3;
		keyWarning.borderQuality = 1;
		keyWarning.screenCenter(X);
		keyWarning.alpha = 0;
		add(keyWarning);

		backText = new FlxText(5, FlxG.height - 37, 0, "ESCAPE - Back to Menu\nDELETE - Reset to Defaults\n", 16);
		backText.scrollFactor.set();
		backText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(backText);

		warningTween = FlxTween.tween(keyWarning, {alpha: 0}, 0);

		changeItem();

		super.create();
	}

	override function update(elapsed:Float)
	{
		switch (state)
		{
			case "select":
				if (controls.UP_P)
				{
					FlxG.sound.play('assets/sounds/scrollMenu.ogg');
					changeItem(-1);
				}

				if (controls.DOWN_P)
				{
					FlxG.sound.play('assets/sounds/scrollMenu.ogg');
					changeItem(1);
				}

				if (FlxG.keys.justPressed.ENTER)
				{
					FlxG.sound.play('assets/sounds/scrollMenu.ogg');
					switch (selected)
					{
						case 0:
							KeyboardMappings.qwertyPreset();
							quit();
						case 1:
							KeyboardMappings.azertyPreset();
							quit();
						case 2:
							state = "input";
							tempKeyMap = new Map<Int, String>();
							for (i in selectArray)
								i.visible = false;
							backText.text = "ESCAPE - Cancel Manual Mapping\n";
					}
				}
				else if (FlxG.keys.justPressed.ESCAPE || FlxG.gamepads.anyJustPressed(ANY))
				{
					FlxG.sound.play('assets/sounds/cancelMenu.ogg');
					quit();
				}
				else if (FlxG.keys.justPressed.DELETE)
				{
					FlxG.sound.play('assets/sounds/cancelMenu.ogg');
					reset();
				}

			case "input":
				if (currentLetter >= Main.alphabet.length || FlxG.keys.justPressed.ESCAPE)
				{
					state = "select";
                    currentLetter = 0;
					headerUpdate();
					for (i in selectArray)
						i.visible = true;
					backText.text = "ESCAPE - Back to Menu\nDELETE - Reset to Defaults\n";
				}
				else
				{
					headerUpdate();
					if (FlxG.keys.getIsDown().length > 0 && FlxG.keys.getIsDown()[0].justPressed)
					{
						if (blacklist.contains(FlxG.keys.getIsDown()[0].ID.toString()) || tempKeyMap[FlxG.keys.getIsDown()[0].ID] != null)
						{
							keyWarning.alpha = 1;
							warningTween.cancel();
							warningTween = FlxTween.tween(keyWarning, {alpha: 0}, 0.5, {ease: FlxEase.circOut, startDelay: 2});
						}
						else
						{
							tempKeyMap[FlxG.keys.getIsDown()[0].ID] = Main.alphabet[currentLetter];
							currentLetter++;
						}
					}
					if (currentLetter >= Main.alphabet.length)
					{
						for (keyCode in tempKeyMap.keys())
						{
							KeyboardMappings.assignKey(keyCode, tempKeyMap[keyCode]);
						}
					}
				}

			case "exiting":

			default:
				state = "select";
		}

		super.update(elapsed);
	}

	function textUpdate()
	{
		selectArray[0].text = "QWERTY";
		selectArray[1].text = "AZERTY";
		selectArray[2].text = "MANUALLY ASSIGN";

		for (i in 0...selectArray.length)
		{
			if (selected == i)
				selectArray[selected].text = ">" + selectArray[selected].text;
		}
	}

	function headerUpdate()
	{
		if (state == "input")
		{
			keyTextDisplay.text = "Press the Key for " + Main.alphabet[currentLetter];
		}
		else
			keyTextDisplay.text = "Select a keyboard layout or manually assign keys if your layout is not of these:";
	}

	function save()
	{
		KeyboardMappings.saveMappings();
	}

	function reset()
	{
		KeyboardMappings.resetMappings();
	}

	function quit()
	{
		save();
		ConfigMenu.startSong = false;
		FlxG.switchState(new ConfigMenu());
	}

	function changeItem(_amount:Int = 0)
	{
		selected += _amount;
		if (selected >= selectArray.length)
			selected = 0;
		else if (selected < 0)
			selected = selectArray.length - 1;

		textUpdate();
	}
}
