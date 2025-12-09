package;

import data.SongData.Song;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import haxe.Json;
import openfl.utils.Assets;

class MainMenu extends FlxState {


    var options = ["Play", "Options", "Credits"];
    var idx:Int = 0;

    public function new() {

        super();
    }

    override function create() {
        FlxG.sound.playMusic('assets/music/ThinkingSongbpm88.ogg');

        var title = new FlxSprite(20, 20).loadGraphic('assets/images/Title.png');
        add(title);
        
        var text = new FlxText(20, 20, 0, "Press ENTER to play.", 32);
        text.color = FlxColor.LIME;
        text.y = title.y + title.height + 20;
        add(text);
        super.create();
    }

    override function update(elapsed:Float) {
        if (FlxG.keys.justPressed.ENTER) {
            new FlxTimer().start(0, _ -> {
            if (options[idx] == "Play") {
                if (Settings.goToVnPart == null && Settings.songToPlay == null && Settings.songType == null) {
                    FlxG.switchState(PlayState.new);
                } else if (Settings.goToVnPart != null && Settings.songToPlay == null && Settings.songType == null) {
                    FlxG.switchState(PlayState.new);
                } 
                else if (Settings.goToVnPart == null && Settings.songToPlay != null && Settings.songType != null) {
                    var song:Song = Json.parse(Assets.getText(Settings.songToPlay));
                    if (Settings.songType == 'yunyun')
                    {
                        FlxG.switchState(() -> {
                            return new YunYunRhythmState(song);
                        });
                    }
                    else
                    {
                        FlxG.switchState(() ->
                        {
                            return new MuseRhythmState(song);
                        });
                    }
                }
            } else if (options[idx] == "Credits") {
                FlxG.switchState(Credits.new);
            }
        });
    }
        super.update(elapsed);
    }
}