package;

import flixel.FlxObject;
import flixel.util.FlxDestroyUtil;
import away3d.events.AnimationStateEvent;
import away3d.library.Asset3DLibrary;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import away3d.core.base.data.Face;
import flixel.tweens.FlxTween;
import away3d.errors.AbstractMethodError;

using StringTools;

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';

	public var holdTimer:Float = 0;

	public var canAutoAnim:Bool = true;

	public var isModel:Bool = false;
	public var beganLoading:Bool = false;
	public var modelName:String;
	public var modelScale:Float = 1;
	public var modelSpeed:Map<String, Float> = new Map<String, Float>();
	public var model:ModelThing;
	public var noLoopList:Array<String> = [];
	public var modelType:String = "md2";
	public var md5Anims:Map<String, String> = new Map<String, String>();

	public var spinYaw:Bool = false;
	public var spinYawVal:Int = 0;
	public var spinPitch:Bool = false;
	public var spinPitchVal:Int = 0;
	public var spinRoll:Bool = false;
	public var spinRollVal:Int = 0;
	public var yTween:FlxTween;
	public var xTween:FlxTween;
	public var originalY:Float = -1;
	public var originalX:Float = -1;
	public var circleTween:FlxTween;
	public var initYaw:Float = 0;
	public var initPitch:Float = 0;
	public var initRoll:Float = 0;
	public var initX:Float = 0;
	public var initY:Float = 0;
	public var initZ:Float = 0;

	public var initFrameWidth:Int = -1;
	public var initWidth:Float = -1;

	var widthMultiplier:Float = 1;
	var heightMultiplier:Float = 1;

	var initFacing:Int = FlxObject.RIGHT;

	public var spellingYOffset:Float = 0;

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false)
	{
		animOffsets = new Map<String, Array<Dynamic>>();
		super(x, y);

		curCharacter = character;
		this.isPlayer = isPlayer;

		var tex:FlxAtlasFrames;
		antialiasing = true;

		switch (curCharacter)
		{
			case 'betty':
				modelName = "betty";
				modelScale = 7;
				modelSpeed = [
					"default" => 1.0,
					"idle" => 2.0,
					"singUP" => 1.5,
					"singLEFT" => 2.8,
					"singRIGHT" => 1.7,
					"singDOWN" => 1.5
				];
				isModel = true;
				loadGraphicFromSprite(Main.modelView.sprite);
				updateHitbox();
				noLoopList = ["idle", "singUP", "singLEFT", "singRIGHT", "singDOWN"];
				Main.modelView.light.ambient = 1;
				Main.modelView.light.specular = 1;
				Main.modelView.light.diffuse = 1;

			case 'cube':
				modelName = "cube";
				modelScale = 55;
				modelSpeed = ["default" => 2.0];
				isModel = true;
				loadGraphicFromSprite(Main.modelView.sprite);
				initYaw = -45;
				updateHitbox();
				noLoopList = ["idle", "singUP", "singLEFT", "singRIGHT", "singDOWN"];
				Main.modelView.light.ambient = 0.7;
				Main.modelView.light.specular = 0.7;
				Main.modelView.light.diffuse = 0.7;

			case 'cecilia':
				frames = Paths.getSparrowAtlas("cecilia");
				animation.addByPrefix('idle', '19 idle 1 remake', 12, false);
				animation.addByPrefix('singUP', '22 up remake ', 12, false);
				animation.addByPrefix('singRIGHT', '20 Right Remake', 12, false);
				animation.addByPrefix('singDOWN', '23 Down Remake ', 12, false);
				animation.addByPrefix('singLEFT', '21 left 1 remake', 12, false);

				addOffset('idle');
				addOffset("singUP", 0, 30);
				addOffset("singRIGHT", 0, 0);
				addOffset("singLEFT", 113, -6);
				addOffset("singDOWN", -64, -18);

				playAnim('idle');

			case 'salesman':
				initFacing = FlxObject.LEFT;
				var tex = FlxAtlasFrames.fromSparrow('assets/images/Door.png', 'assets/images/Door.xml');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);

				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

				animation.addByPrefix('scared', 'BF idle shaking', 24);

				addOffset('idle');
				addOffset("hey");
				addOffset("singUP", 2, 5);
				addOffset("singRIGHT", -38, -7);
				addOffset("singLEFT", 12, -6);
				addOffset("singDOWN", -10, -28);
				addOffset("singUPmiss", 2, 5);
				addOffset("singRIGHTmiss", -38, -7);
				addOffset("singLEFTmiss", 12, -6);
				addOffset("singDOWNmiss", -10, -28);
				addOffset('firstDeath', 0, 199);
				addOffset('deathLoop', 0, 199);
				addOffset('deathConfirm', 0, 199);
				addOffset('scared', 0, 1);

				playAnim('idle');

			// case 'wip':
			// 	frames = Paths.getSparrowAtlas("wip");
			// 	animation.addByPrefix('idle', 'wipIdle', 24, false);
			// 	animation.addByPrefix('singUP', 'wipUp', 24, false);
			// 	animation.addByPrefix('singRIGHT', 'wipRight', 24, false);
			// 	animation.addByPrefix('singDOWN', 'wipDown', 24, false);
			// 	animation.addByPrefix('singLEFT', 'wipLeft', 24, false);

			// 	addOffset('idle');
			// 	addOffset("singUP", 44, 111);
			// 	addOffset("singRIGHT", -12, 13);
			// 	addOffset("singLEFT", -37, 4);
			// 	addOffset("singDOWN", -104, -53);

			// 	scale.x = scale.y = 0.7;
			// 	updateHitbox();

			// 	playAnim('idle');

			case 'nothing':
				loadGraphic('assets/images/nothing.png');

			case 'gf':
				// GIRLFRIEND CODE
				initFacing = FlxObject.LEFT;
				frames = Paths.getSparrowAtlas("GF_assets");
				animation.addByPrefix('cheer', 'GF Cheer', 24, false);
				animation.addByPrefix('singLEFT', 'GF left note', 24, false);
				animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
				animation.addByPrefix('singUP', 'GF Up Note', 24, false);
				animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
				animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
				animation.addByPrefix('scared', 'GF FEAR', 24);

				addOffset('cheer');
				addOffset('sad', -2, -21);
				addOffset('danceLeft', 0, -9);
				addOffset('danceRight', 0, -9);

				addOffset("singUP", 0, 4);
				addOffset("singRIGHT", 0, -20);
				addOffset("singLEFT", 0, -19);
				addOffset("singDOWN", 0, -20);
				addOffset('hairBlow', 45, -8);
				addOffset('hairFall', 0, -9);

				addOffset('scared', -2, -17);

				playAnim('danceRight');

			case 'gf-christmas':
				frames = Paths.getSparrowAtlas("christmas/gfChristmas");
				animation.addByPrefix('cheer', 'GF Cheer', 24, false);
				animation.addByPrefix('singLEFT', 'GF left note', 24, false);
				animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
				animation.addByPrefix('singUP', 'GF Up Note', 24, false);
				animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
				animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
				animation.addByPrefix('scared', 'GF FEAR', 24);

				addOffset('cheer');
				addOffset('sad', 0, -21);
				addOffset('danceLeft', 0, -9);
				addOffset('danceRight', 0, -9);

				addOffset("singUP", 0, 4);
				addOffset("singRIGHT", 0, -20);
				addOffset("singLEFT", 0, -19);
				addOffset("singDOWN", 0, -20);
				addOffset('hairBlow', 45, -8);
				addOffset('hairFall', 0, -9);

				addOffset('scared', -2, -17);

				playAnim('danceRight');

			case 'gf-car':
				frames = Paths.getSparrowAtlas("gfCar");
				animation.addByIndices('singUP', 'GF Dancing Beat Hair blowing CAR', [0], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat Hair blowing CAR', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat Hair blowing CAR', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24,
					false);

				addOffset('danceLeft', 0);
				addOffset('danceRight', 0);

				playAnim('danceRight');

			case 'gf-pixel':
				frames = Paths.getSparrowAtlas("weeb/gfPixel");
				animation.addByIndices('singUP', 'GF IDLE', [2], "", 24, false);
				animation.addByIndices('danceLeft', 'GF IDLE', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF IDLE', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

				addOffset('danceLeft', 0);
				addOffset('danceRight', 0);

				playAnim('danceRight');

				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();
				antialiasing = false;

			case 'dad':
				// DAD ANIMATION LOADING CODE
				frames = Paths.getSparrowAtlas("DADDY_DEAREST");
				animation.addByPrefix('idle', 'Dad idle dance', 24, false);
				animation.addByPrefix('singUP', 'Dad Sing Note UP', 24);
				animation.addByPrefix('singRIGHT', 'Dad Sing Note RIGHT', 24);
				animation.addByPrefix('singDOWN', 'Dad Sing Note DOWN', 24);
				animation.addByPrefix('singLEFT', 'Dad Sing Note LEFT', 24);

				addOffset('idle');
				addOffset("singUP", -9, 50);
				addOffset("singRIGHT", -4, 26);
				addOffset("singLEFT", -11, 10);
				addOffset("singDOWN", 2, -32);

				playAnim('idle');
			case 'spooky':
				frames = Paths.getSparrowAtlas("spooky_kids_assets");
				animation.addByPrefix('singUP', 'spooky UP NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'spooky DOWN note', 24, false);
				animation.addByPrefix('singLEFT', 'note sing left', 24, false);
				animation.addByPrefix('singRIGHT', 'spooky sing right', 24, false);
				animation.addByIndices('danceLeft', 'spooky dance idle', [0, 2, 6], "", 12, false);
				animation.addByIndices('danceRight', 'spooky dance idle', [8, 10, 12, 14], "", 12, false);

				addOffset('danceLeft');
				addOffset('danceRight');

				addOffset("singUP", -18, 25);
				addOffset("singRIGHT", -130, -14);
				addOffset("singLEFT", 124, -13);
				addOffset("singDOWN", -46, -144);

				playAnim('danceRight');
			case 'mom':
				frames = Paths.getSparrowAtlas("Mom_Assets");
				animation.addByPrefix('idle', "Mom Idle", 24, false);
				animation.addByPrefix('singUP', "Mom Up Pose", 24, false);
				animation.addByPrefix('singDOWN', "MOM DOWN POSE", 24, false);
				animation.addByPrefix('singLEFT', 'Mom Left Pose', 24, false);
				// ANIMATION IS CALLED MOM LEFT POSE BUT ITS FOR THE RIGHT
				// CUZ DAVE IS DUMB!
				animation.addByPrefix('singRIGHT', 'Mom Pose Left', 24, false);

				addOffset('idle');
				addOffset("singUP", -1, 81);
				addOffset("singRIGHT", 21, -54);
				addOffset("singLEFT", 250, -23);
				addOffset("singDOWN", 20, -157);

				playAnim('idle');

			case 'mom-car':
				frames = Paths.getSparrowAtlas("momCar");
				animation.addByPrefix('idle', "Mom Idle", 24, false);
				animation.addByPrefix('singUP', "Mom Up Pose", 24, false);
				animation.addByPrefix('singDOWN', "MOM DOWN POSE", 24, false);
				animation.addByPrefix('singLEFT', 'Mom Left Pose', 24, false);
				// ANIMATION IS CALLED MOM LEFT POSE BUT ITS FOR THE RIGHT
				// CUZ DAVE IS DUMB!
				animation.addByPrefix('singRIGHT', 'Mom Pose Left', 24, false);

				addOffset('idle');
				addOffset("singUP", -1, 81);
				addOffset("singRIGHT", 21, -54);
				addOffset("singLEFT", 250, -23);
				addOffset("singDOWN", 20, -157);

				playAnim('idle');
			case 'monster':
				frames = Paths.getSparrowAtlas("Monster_Assets");
				animation.addByPrefix('idle', 'monster idle', 24, false);
				animation.addByPrefix('singUP', 'monster up note', 24, false);
				animation.addByPrefix('singDOWN', 'monster down', 24, false);
				animation.addByPrefix('singLEFT', 'Monster left note', 24, false);
				animation.addByPrefix('singRIGHT', 'Monster Right note', 24, false);

				addOffset('idle');
				addOffset("singUP", -23, 87);
				addOffset("singRIGHT", -51, 15);
				addOffset("singLEFT", -31, 4);
				addOffset("singDOWN", -63, -86);
				playAnim('idle');
			case 'monster-christmas':
				frames = Paths.getSparrowAtlas("christmas/monsterChristmas");
				animation.addByPrefix('idle', 'monster idle', 24, false);
				animation.addByPrefix('singUP', 'monster up note', 24, false);
				animation.addByPrefix('singDOWN', 'monster down', 24, false);
				animation.addByPrefix('singLEFT', 'Monster left note', 24, false);
				animation.addByPrefix('singRIGHT', 'Monster Right note', 24, false);

				addOffset('idle');
				addOffset("singUP", -21, 53);
				addOffset("singRIGHT", -51, 10);
				addOffset("singLEFT", -30, 7);
				addOffset("singDOWN", -52, -91);
				playAnim('idle');
			case 'pico':
				frames = Paths.getSparrowAtlas("Pico_FNF_assetss");
				animation.addByPrefix('idle', "Pico Idle Dance", 24, false);
				animation.addByPrefix('singUP', 'pico Up note0', 24, false);
				animation.addByPrefix('singDOWN', 'Pico Down Note0', 24, false);
				animation.addByPrefix('singLEFT', 'Pico NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'Pico Note Right0', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'Pico Note Right Miss', 24, false);
				animation.addByPrefix('singLEFTmiss', 'Pico NOTE LEFT miss', 24, false);
				animation.addByPrefix('singUPmiss', 'pico Up note miss', 24, false);
				animation.addByPrefix('singDOWNmiss', 'Pico Down Note MISS', 24, false);

				addOffset('idle');
				addOffset("singUP", 26, 29);
				addOffset("singLEFT", 85, -11);
				addOffset("singRIGHT", -45, 2);
				addOffset("singDOWN", 114, -76);
				addOffset("singUPmiss", 32, 67);
				addOffset("singLEFTmiss", 85, 28);
				addOffset("singRIGHTmiss", -30, 50);
				addOffset("singDOWNmiss", 116, -34);

				playAnim('idle');

				initFacing = FlxObject.LEFT;

			case 'bf':
				frames = Paths.getSparrowAtlas("BOYFRIEND");
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);
				animation.addByPrefix('attack', 'boyfriend attack', 24, false);

				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

				animation.addByPrefix('scared', 'BF idle shaking', 24);

				addOffset('idle', -5);
				addOffset("singUP", -29, 27);
				addOffset("singRIGHT", -38, -7);
				addOffset("singLEFT", 12, -6);
				addOffset("singDOWN", -10, -50);
				addOffset("singUPmiss", -29, 27);
				addOffset("singRIGHTmiss", -30, 21);
				addOffset("singLEFTmiss", 12, 24);
				addOffset("singDOWNmiss", -11, -19);
				addOffset("hey", 7, 4);
				addOffset('firstDeath', 37, 11);
				addOffset('deathLoop', 37, 5);
				addOffset('deathConfirm', 37, 69);
				addOffset('scared', -4);

				playAnim('idle');

				initFacing = FlxObject.LEFT;

			case 'senpai':
				antialiasing = false;
				frames = Paths.getSparrowAtlas("senpai");
				// animation.addByPrefix('idle', 'Senpai Idle', 24, false);
				animation.addByPrefix('danceLeft', 'Senpai IdleA', 24, false);
				animation.addByPrefix('danceRight', 'Senpai IdleB', 24, false);
				animation.addByPrefix('singUP', 'SENPAI UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'SENPAI LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'SENPAI RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'SENPAI DOWN NOTE', 24, false);
				animation.addByPrefix('singUPmiss', 'Angry Senpai UP NOTE', 24, false);
				animation.addByPrefix('singLEFTmiss', 'Angry Senpai LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'Angry Senpai RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWNmiss', 'Angry Senpai DOWN NOTE', 24, false);

				// addOffset('idle');
				addOffset('danceLeft');
				addOffset('danceRight');
				addOffset("singUP", 12, 36);
				addOffset("singRIGHT", 6);
				addOffset("singLEFT", 30);
				addOffset("singDOWN", 12);
				addOffset("singUPmiss", 6, 36);
				addOffset("singRIGHTmiss");
				addOffset("singLEFTmiss", 24, 6);
				addOffset("singDOWNmiss", 6, 6);

				// playAnim('idle');
				playAnim('danceRight');

				scale.x = scale.y = 6;
				widthMultiplier = 0.7;
				heightMultiplier = 0.8;
				updateHitbox();

			case 'senpai-angry':
				frames = Paths.getSparrowAtlas("senpai");
				animation.addByPrefix('idle', 'Angry Senpai Idle', 24, false);
				animation.addByPrefix('singUP', 'Angry Senpai UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'Angry Senpai LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'Angry Senpai RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'Angry Senpai DOWN NOTE', 24, false);

				addOffset('idle');
				addOffset("singUP", 6, 36);
				addOffset("singRIGHT");
				addOffset("singLEFT", 24, 6);
				addOffset("singDOWN", 6, 6);
				playAnim('idle');

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				antialiasing = false;

			case 'spirit':
				frames = Paths.getPackerAtlas("weeb/spirit");
				animation.addByPrefix('idle', "idle spirit_", 24, false);
				animation.addByPrefix('singUP', "up_", 24, false);
				animation.addByPrefix('singRIGHT', "right_", 24, false);
				animation.addByPrefix('singLEFT', "left_", 24, false);
				animation.addByPrefix('singDOWN', "spirit down_", 24, false);

				addOffset('idle', -220, -280);
				addOffset('singUP', -220, -238);
				addOffset("singRIGHT", -220, -280);
				addOffset("singLEFT", -202, -280);
				addOffset("singDOWN", 170, 110);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

			case 'parents-christmas':
				frames = Paths.getSparrowAtlas("christmas/mom_dad_christmas_assets");
				animation.addByPrefix('idle', 'Parent Christmas Idle', 24, false);
				animation.addByPrefix('singUP', 'Parent Up Note Dad', 24, false);
				animation.addByPrefix('singDOWN', 'Parent Down Note Dad', 24, false);
				animation.addByPrefix('singLEFT', 'Parent Left Note Dad', 24, false);
				animation.addByPrefix('singRIGHT', 'Parent Right Note Dad', 24, false);

				animation.addByPrefix('singUP-alt', 'Parent Up Note Mom', 24, false);

				animation.addByPrefix('singDOWN-alt', 'Parent Down Note Mom', 24, false);
				animation.addByPrefix('singLEFT-alt', 'Parent Left Note Mom', 24, false);
				animation.addByPrefix('singRIGHT-alt', 'Parent Right Note Mom', 24, false);

				addOffset('idle');
				addOffset("singUP", -47, 24);
				addOffset("singRIGHT", -1, -23);
				addOffset("singLEFT", -30, 16);
				addOffset("singDOWN", -31, -29);
				addOffset("singUP-alt", -47, 24);
				addOffset("singRIGHT-alt", -1, -24);
				addOffset("singLEFT-alt", -30, 15);
				addOffset("singDOWN-alt", -30, -27);

				playAnim('idle');
		}

		dance();

		initFrameWidth = frameWidth;
		initWidth = width;
		setFacingFlip((initFacing == FlxObject.LEFT ? FlxObject.RIGHT : FlxObject.LEFT), true, false);

		switch (curCharacter)
		{
			case 'betty':
				spellingYOffset = 75;
			case 'cube':
				spellingYOffset = 125;
			case 'dad' | 'senpai':
				spellingYOffset = height / 2;
			case 'salesman':
				spellingYOffset = 0;
			default:
				spellingYOffset = -100;
		}

		if (isPlayer)
		{
			// flipX = !flipX;
			facing = FlxObject.LEFT;
		}
		else
			facing = FlxObject.RIGHT;

		if (!isModel && initFacing != facing)
		{
			// var animArray
			if (animation.getByName('singRIGHT') != null)
			{
				var oldRight = animation.getByName('singRIGHT').frames;
				var oldOffset = animOffsets['singRIGHT'];
				animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
				animOffsets['singRIGHT'] = animOffsets['singLEFT'];
				animation.getByName('singLEFT').frames = oldRight;
				animOffsets['singLEFT'] = oldOffset;
			}

			// IF THEY HAVE MISS ANIMATIONS??
			if (animation.getByName('singRIGHTmiss') != null)
			{
				var oldMiss = animation.getByName('singRIGHTmiss').frames;
				var oldOffset = animOffsets['singRIGHTmiss'];
				animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
				animOffsets['singRIGHTmiss'] = animOffsets['singLEFTmiss'];
				animation.getByName('singLEFTmiss').frames = oldMiss;
				animOffsets['singLEFTmiss'] = oldOffset;
			}

			if (animation.getByName('singRIGHT-alt') != null)
			{
				var oldRight = animation.getByName('singRIGHT-alt').frames;
				var oldOffset = animOffsets['singRIGHT-alt'];
				animation.getByName('singRIGHT-alt').frames = animation.getByName('singLEFT-alt').frames;
				animOffsets['singRIGHT-alt'] = animOffsets['singLEFT-alt'];
				animation.getByName('singLEFT-alt').frames = oldRight;
				animOffsets['singLEFT-alt'] = oldOffset;
			}
		}

		animation.finishCallback = animationEnd;
	}

	override function update(elapsed:Float)
	{
		if (curCharacter == 'nothing')
		{
			super.update(elapsed);
			return;
		}

		if (!isPlayer && !isModel)
		{
			if (animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}

			var dadVar:Float = 4;

			if (curCharacter == 'dad')
				dadVar = 6.1;
			if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
			{
				idleEnd();
				holdTimer = 0;
			}
		}
		else if (!isPlayer && isModel)
		{
			if (model.currentAnim.startsWith('sing'))
			{
				holdTimer += elapsed;
			}

			var dadVar:Float = 4;

			if (curCharacter == 'dad')
				dadVar = 6.1;
			if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
			{
				idleEnd();
				holdTimer = 0;
			}
		}

		switch (curCharacter)
		{
			case 'gf':
				if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
					playAnim('danceRight');
		}

		super.update(elapsed);

		if (isModel)
		{
			if (spinYaw)
			{
				model.addYaw(elapsed * spinYawVal);
			}

			if (spinPitch)
			{
				model.addPitch(elapsed * spinPitchVal);
			}

			if (spinRoll)
			{
				model.addRoll(elapsed * spinRollVal);
			}
		}
	}

	private var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance(?ignoreDebug:Bool = false)
	{
		if (curCharacter == 'nothing')
			return;

		if (!debugMode || ignoreDebug)
		{
			switch (curCharacter)
			{
				case 'gf' | 'gf-car' | 'gf-christmas' | 'gf-pixel':
					if (!animation.curAnim.name.startsWith('hair'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight', true);
						else
							playAnim('danceLeft', true);
					}

				case 'spooky':
					danced = !danced;

					if (danced)
						playAnim('danceRight', true);
					else
						playAnim('danceLeft', true);

				case 'senpai':
					danced = !danced;

					if (danced)
						playAnim('danceRight', true);
					else
						playAnim('danceLeft', true);

				default:
					if (holdTimer == 0)
					{
						if (isModel && model == null)
						{
							trace("NO DANCE - NO MODEL");
							return;
						}
						if (isModel && !model.fullyLoaded)
						{
							trace("NO DANCE - NO FULLY LOAD");
							return;
						}
						if (isModel && !noLoopList.contains('idle'))
							return;
						playAnim('idle', true);
					}
			}
		}
	}

	public function idleEnd(?ignoreDebug:Bool = false)
	{
		if (curCharacter == 'nothing')
			return;

		if (!isModel && (!debugMode || ignoreDebug))
		{
			switch (curCharacter)
			{
				case 'gf' | 'gf-car' | 'gf-christmas' | 'gf-pixel' | "spooky":
					playAnim('danceRight', true, false, animation.getByName('danceRight').numFrames - 1);
				default:
					playAnim('idle', true, false, animation.getByName('idle').numFrames - 1);
			}
		}
		else if (isModel && (!debugMode || ignoreDebug))
		{
			playAnim('idleEnd', true, false);
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		if (curCharacter == 'nothing')
			return;

		if (isModel)
		{
			model.playAnim(AnimName, Force, Frame);
		}
		else
		{
			var daAnim:String = AnimName;
			if (AnimName.endsWith('miss') && animation.getByName(AnimName) == null)
			{
				daAnim = AnimName.substring(0, AnimName.length - 4);
				color = 0x5462bf;
			}
			else
				color = 0xffffff;

			animation.play(daAnim, Force, Reversed, Frame);

			updateHitbox();

			var daOffset = animOffsets.get(animation.curAnim.name);
			if (animOffsets.exists(animation.curAnim.name))
			{
				if (initFrameWidth > -1)
					offset.set((facing != initFacing ? -1 : 1) * daOffset[0]
						+ (facing != initFacing ? frameWidth - initFrameWidth : 0)
						+ offset.x,
						daOffset[1]
						+ offset.y);
				else
					offset.set(daOffset[0] + offset.x, daOffset[1] + offset.y);
			}
			else
				offset.set(0, 0);

			if (curCharacter == 'gf')
			{
				if (AnimName == 'singLEFT')
				{
					danced = true;
				}
				else if (AnimName == 'singRIGHT')
				{
					danced = false;
				}

				if (AnimName == 'singUP' || AnimName == 'singDOWN')
				{
					danced = !danced;
				}
			}
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}

	function animationEnd(name:String)
	{
		if (curCharacter == 'nothing')
			return;

		switch (curCharacter)
		{
			case "mom-car":
				switch (name)
				{
					case "idle":
						playAnim(name, false, false, 8);
					case "singUP":
						playAnim(name, false, false, 4);
					case "singDOWN":
						playAnim(name, false, false, 4);
					case "singLEFT":
						playAnim(name, false, false, 2);
					case "singRIGHT":
						playAnim(name, false, false, 2);
				}

			case "bf-car":
				switch (name)
				{
					case "idle":
						playAnim(name, false, false, 8);
					case "singUP":
						playAnim(name, false, false, 3);
					case "singDOWN":
						playAnim(name, false, false, 2);
					case "singLEFT":
						playAnim(name, false, false, 4);
					case "singRIGHT":
						playAnim(name, false, false, 2);
				}

			case "monster-christmas" | "monster":
				switch (name)
				{
					case "idle":
						playAnim(name, false, false, 10);
					case "singUP":
						playAnim(name, false, false, 8);
					case "singDOWN":
						playAnim(name, false, false, 7);
					case "singLEFT":
						playAnim(name, false, false, 5);
					case "singRIGHT":
						playAnim(name, false, false, 6);
				}
		}
	}

	override public function updateHitbox()
	{
		width = Math.abs(scale.x) * frameWidth * widthMultiplier;
		height = Math.abs(scale.y) * frameHeight * heightMultiplier;
		offset.set(-0.5 * (width - frameWidth), -0.5 * (height - frameHeight));
		centerOrigin();
	}

	override public function destroy()
	{
		FlxDestroyUtil.destroy(yTween);
		FlxDestroyUtil.destroy(xTween);
		FlxDestroyUtil.destroy(circleTween);
		super.destroy();
	}
}
