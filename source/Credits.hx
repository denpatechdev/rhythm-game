package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.Assets;

class Credits extends FlxState {
    public var creditsData:Array<Array<String>> = [];
    public var text:FlxText;

    public function new() {
        super();
        var asdf = Assets.getText("assets/data/credits.txt").split('\n');
        for (a in asdf) {
            creditsData.push(a.split(':'));
        }
    }

    override function create() {
        super.create();
        text = new FlxText(20, 20, FlxG.width - 20, "", 32);
        text.color = FlxColor.LIME;
        for (data in creditsData) {
            text.text += data[0] + " - " + data[1] + "\n"; 
        }

        add(text);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        if (FlxG.keys.justPressed.ESCAPE) {
            FlxG.switchState(MainMenu.new);
        }
    }
}