package;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class StrumNote extends FlxSpriteGroup {
    
    var sprite:FlxSprite;
    var text:FlxText;
    
    public function new(x:Float, y:Float, keyChar:String) {
        super(x, y);
        sprite = new FlxSprite().loadGraphic("assets/images/BeatBar.png");
        text = new FlxText(sprite.x + sprite.width / 2, sprite.y + sprite.height / 2, 0, keyChar, 24);
        text.x -= text.width / 2;
        text.y -= text.height / 2;
        text.color = FlxColor.BLACK;
        add(sprite);
        add(text);
    }
}