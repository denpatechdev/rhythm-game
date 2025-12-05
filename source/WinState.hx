package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;

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
		this.score = score;
		this.ratings = ratings;
        super();
	}

	override function create()
	{
		var scoreText = 'Score: ${score}\nAccuracy ${noteAccuracies}\nHits: ${hitNotes}\n\n';
		for (k in ratings.keys())
		{
			scoreText += '${k}: ${ratings[k]}\n';
		}
		text = new FlxText(20, 20, FlxG.width - 20, scoreText, 32);
		add(text);
		super.create();
	}
}