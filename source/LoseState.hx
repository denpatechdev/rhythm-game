package;

import data.SongData.Song;
import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class LoseState extends FlxState {
    public function new() {
        super();
    }

    var song:Song;

    override function create() {
        FlxG.sound.music.stop();
        FlxG.sound.play("assets/sounds/Failure.mp3");
		var text = new FlxText(20, 20, "You lost :(\nENTER for main menu screen", 32);
		text.color = FlxColor.LIME;
		add(text);
        super.create();
    }

    override function update(elapsed:Float) {
        
        if (FlxG.keys.justPressed.ENTER) {
			FlxG.switchState(MainMenu.new);
        }

        super.update(elapsed);
    }
}