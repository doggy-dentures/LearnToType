package;

import flixel.FlxG;
import sys.FileSystem;
import webm.WebmPlayer;
import flixel.FlxGame;
import openfl.display.FPS;
import openfl.display.Sprite;

class Main extends Sprite
{
	public static var fpsDisplay:FPS;

	#if web
	var vHandler:VideoHandler;
	#elseif desktop
	var webmHandle:WebmHandler;
	#end

	// public static var novid:Bool = Sys.args().contains("-novid");
	public static var novid:Bool = true;
	// public static var nopreload:Bool = Sys.args().contains("-nopreload");
	public static var nopreload:Bool = true;
	public static var skipsound:Bool = Sys.args().contains("-skipsound");
	public static var skipcharacters:Bool = Sys.args().contains("-skipcharacters");
	public static var skipgraphics:Bool = Sys.args().contains("-skipgraphics");
	public static var flippymode:Bool = Sys.args().contains("-flippymode");

	public static var modelView:ModelView;
	// public static var wordList:Map<Int, Array<String>> = new Map<Int, Array<String>>();
	public static final alphabet:Array<String> = [
		'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'
	];

	public static var characters:Array<String> = [];
	public static var characterNames:Array<String> = [];
	public static var characterCredits:Array<String> = [];

	public static function addCharacter(who:String, name:String, credit:String = "")
	{
		characters.push(who);
		characterNames.push(name);
		characterCredits.push(credit);
	}

	public function new()
	{
		super();

		if (!nopreload)
			addChild(new FlxGame(0, 0, Startup, 1, 144, 144, true));
		else
			addChild(new FlxGame(0, 0, TitleVidState, 1, 144, 144, true));

		#if !mobile
		fpsDisplay = new FPS(10, 3, 0xFFFFFF);
		fpsDisplay.visible = false;
		addChild(fpsDisplay);
		#end

		if (!novid)
		{
			var ourSource:String = "assets/videos/DO NOT DELETE OR GAME WILL CRASH/dontDelete.webm";

			#if web
			var str1:String = "HTML CRAP";
			vHandler = new VideoHandler();
			vHandler.init1();
			vHandler.video.name = str1;
			addChild(vHandler.video);
			vHandler.init2();
			GlobalVideo.setVid(vHandler);
			vHandler.source(ourSource);
			#elseif desktop
			var str1:String = "WEBM SHIT";
			webmHandle = new WebmHandler();
			webmHandle.source(ourSource);
			webmHandle.makePlayer();
			webmHandle.webm.name = str1;
			addChild(webmHandle.webm);
			GlobalVideo.setWebm(webmHandle);
			#end
		}

		trace("-=Args=-");
		trace("novid: " + novid);
		trace("nopreload: " + nopreload);
		trace("skipsound: " + skipsound);
		trace("skipcharacters: " + skipcharacters);
		trace("skipgraphics: " + skipgraphics);
		trace("flippymode: " + flippymode);

		modelView = new ModelView();

		addCharacter("bf", "Boyfriend");
		addCharacter("gf", "Girlfriend");
		addCharacter("dad", "Daddy Dearest");
		addCharacter("pico", "Pico");
		addCharacter("senpai", "Senpai");
		addCharacter("cecilia", "Cecilia", "Ket_Overkill & CryMeARiverOfArt");
		addCharacter("salesman", "Door to Door Door Salesman", "Aurazona & Pizzapancakess_");
	}

	static public function playMusic()
	{
		if (FlxG.sound.music == null || !FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic("assets/music/soup.ogg");
		}
	}
}
