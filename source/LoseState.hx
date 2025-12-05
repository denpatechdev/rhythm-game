package;

import data.SongData.Song;
import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;

class LoseState extends FlxState {
    public function new() {
        super();
    }

    var song:Song;

    override function create() {
        FlxG.sound.music.stop();
        FlxG.sound.play("assets/sounds/Failure.mp3");
		add(new FlxText(20, 20, "You lost :(\nENTER for main menu screen", 24));
        super.create();
    }

    override function update(elapsed:Float) {
        
        if (FlxG.keys.justPressed.ENTER) {
            FlxG.switchState(PlayState.new);
        }

        super.update(elapsed);
    }
}