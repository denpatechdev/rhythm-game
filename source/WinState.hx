package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class WinState extends FlxState {

    public var highestCombo:Int;
    public var noteAccuracies:Float;
    public var hitNotes:Int;
    public var score:Float;
	public var ratings:Map<String, Int>;

	var text:FlxText;

	public function new(highestCombo:Int, noteAccuracies:Float, hitNotes:Int, score:Float, ratings:Map<String, Int>)
	{
		this.highestCombo = highestCombo;
		this.noteAccuracies = noteAccuracies;
		this.hitNotes = hitNotes;
		this.score = FlxMath.roundDecimal(score, 2);
		this.ratings = ratings;
		switch (Settings.songToPlay)
		{
			case 'assets/data/herosim.json':
				Settings.goToVnPart = 'assets/data/dialogue/lv2.json';
			case 'assets/data/song.json':
				Settings.goToVnPart = 'assets/data/dialogue/lv3.json';
			case 'assets/data/last.json':
				Settings.goToVnPart = 'assets/data/dialogue/end.json';
			default:
				Settings.goToVnPart = null;
		}
		Settings.songToPlay = null;
		Settings.songType = null;
		


        super();
	}

	override function create()
	{
		var scoreText = 'Score: ${score}\nHits: ${hitNotes}\n\n';
		for (k in ratings.keys())
		{
			scoreText += '${k}: ${ratings[k]}\n';
		}
		text = new FlxText(20, 20, FlxG.width - 20, scoreText, 32);
		add(text);
		text.text += "\n\nPress ENTER to continue.";
		text.color = FlxColor.LIME;
		super.create();
	}
	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.ENTER)
		{
			if (Settings.goToVnPart != null)
				FlxG.switchState(PlayState.new);
			else
				FlxG.switchState(MainMenu.new);
		}
		super.update(elapsed);
	}
}