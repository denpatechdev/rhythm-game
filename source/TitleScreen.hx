package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import haxe.Json;
import lime.utils.Assets;

class TitleScreen extends SongState {
    var text:FlxText;
    public function new() {
        super();
    }

    var title:FlxSprite;
    override function create() {
        title = new FlxSprite(20, 20).loadGraphic('assets/images/Title.png');
        add(title);
        title.visible = false;
        FlxG.mouse.visible = false;
        FlxG.sound.playMusic('assets/music/Title.mp3', 1, false);
        FlxG.sound.music.onComplete = () -> {
            FlxG.switchState(MainMenu.new);
        };
        Conductor.bpm = 100;
        super.create();
        FlxG.watch.add(this, 'curStep', 'curStep');
		FlxG.watch.add(this, 'curBeat', 'curBeat');
		FlxG.watch.add(this, 'curMeasure', 'curMeasure');
        
        text =new FlxText(20, 20, FlxG.width - 20, '', 32);
        text.y = title.y + title.height + 20;
        text.color = FlxColor.LIME;
        add(text);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        if (FlxG.keys.justPressed.ENTER) {
            FlxG.switchState(MainMenu.new);
        }
    }

    override function onBeat(beat:Int) {
        super.onBeat(beat);
        trace(curBeat);
        switch (beat) {
            case 6:
                title.visible = true;
            case 12:
                addText('A rhythm game');
            case 16:
                addText('With hacking themes');
            case 20:
                addText('But not like Mr. Robot');
            case 24:
                addText('More like sci-fi unrealistic hacking movies');
            case 28:
                addText('Also inspired by Muse Dash and 4K rhythm games');
            case 32:
                addText('Like Quaver and StepMania');
            case 36:
                addText('Or osu!mania');
            case 40:
                addText('Or more recently, Yunyun Syndrome!? Denpa Psychosis');
            case 44:
                addText('TECHNOTES made by');
            case 48:
                addText('Francesco');
            case 52:
                addText('denpatech');
            case 56:
                addText('MYYA DYNAMIC');
            case 60:
                addText('Boudica');
            case 64:
                addText('InWater');
            case 68:
                var lol = [
                    'im burned out. ambitious projects for gamejams are hard',
                    'hope you can enjoy the game',
                    '874838478374387ngnhghjhfjsjkdsds',
                    'lololololololololollolololol'
                ];
                addText(FlxG.random.getObject(lol));
        }
    }

    function addText(str) {
        text.text += str+'\n';
    }
}