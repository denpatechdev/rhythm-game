package;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;

class Note extends FlxSpriteGroup {
    public var time:Float;
    public var column:Int; // 0, 1, 2, 3
    public var kind:String;
    public var holdTime:Float = 0;
    public var fullHoldTime:Float = 0;
    public var hit:Bool = false;

    public var noteGraphic:FlxSprite;
    public var sustainSprite:FlxSprite;

    public static var NOTE_WIDTH:Int = 200;
    public static var NOTE_HEIGHT:Int = 100;
	public var canHit:Bool = true; 
    public var isSustain:Bool = false;
	public var missed:Bool;


    public function new(Time:Float, Column:Int, ?Kind:String = 'yunyun', ?HoldTime:Float = 0) {
        super(0, 0);
        time = Time;
        column = Column;
        kind = Kind;
        fullHoldTime = HoldTime;
        holdTime = HoldTime;

        noteGraphic = new FlxSprite().makeGraphic(NOTE_WIDTH, NOTE_HEIGHT);
        if (holdTime != 0) {
            switch (kind) {
                case 'yunyun':
                    sustainSprite = new FlxSprite().makeGraphic(NOTE_WIDTH, Std.int(holdTime * YunYunRhythmState.noteSpeed));
                case 'muse':
                    sustainSprite = new FlxSprite().makeGraphic(Std.int(holdTime * MuseRhythmState.noteSpeed), NOTE_HEIGHT);
            }
            sustainSprite.alpha = .5;
            isSustain =true;
        }
        add(noteGraphic);
        switch (column) {
            case 0:
                color = FlxColor.PURPLE;
            case 1:
                color = FlxColor.BLUE;
            case 2:
                color = FlxColor.GREEN;
            case 3:
                color = FlxColor.RED;   
        }

        if (holdTime != 0) {
            color = FlxColor.CYAN;
        }
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
    }
}