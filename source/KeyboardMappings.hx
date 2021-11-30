import flixel.FlxG;

class KeyboardMappings
{
	public static var keyMappings:Map<Int, String> = new Map<Int, String>();

	public static function saveMappings()
	{
		FlxG.save.data.keyMappings = keyMappings;
	}

	public static function loadMappings()
	{
		if (FlxG.save.data.keyMappings == null)
		{
			resetMappings();
		}
		else
			keyMappings = FlxG.save.data.keyMappings;
	}

	public static function resetMappings()
	{
		qwertyPreset();
		saveMappings();
	}

	public static function assignKey(id:Int, key:String)
	{
		keyMappings[id] = key;
	}

	public static function assignKeyRange(ids:Array<Int>)
	{
		if (ids.length != Main.alphabet.length)
		{
			trace("Key range failed. " + ids.length + " != " + Main.alphabet.length);
			return;
		}
		var i = 0;
		for (keyCode in ids)
		{
			assignKey(keyCode, Main.alphabet[i]);
			i++;
		}
	}

	public static function qwertyPreset()
	{
		var keyCodes:Array<Int> = [];
		for (i in 65...91)
			keyCodes.push(i);
		assignKeyRange(keyCodes);
	}

	public static function azertyPreset()
	{
		var keyCodes:Array<Int> = [];

		keyCodes.push(81);

		for (i in 66...77)
			keyCodes.push(i);

		keyCodes.push(186);

		for (i in 78...81)
			keyCodes.push(i);

		keyCodes.push(65);

		for (i in 82...87)
			keyCodes.push(i);

		keyCodes.push(90);
		keyCodes.push(88);
		keyCodes.push(89);
		keyCodes.push(87);

		assignKeyRange(keyCodes);
	}
}
