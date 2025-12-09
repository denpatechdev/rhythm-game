package;

import flixel.FlxG;
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

		if (Kind == 'yunyun')
		{
			noteGraphic = new FlxSprite().loadGraphic('assets/images/strum_note.png');
		}
		else
		{
			noteGraphic = new FlxSprite();
			switch (column)
			{
				case 0:
					var graphicPath = ('assets/images/' + FlxG.random.getObject(['Flyby', 'Technoswimmer', 'Vinylspiker']) + '.png');
					// trace(graphicPath);
					noteGraphic.loadGraphic('assets/images/' + FlxG.random.getObject(['Flyby', 'Technoswimmer', 'Vinylspiker']) + '.png', true, 535, 459);
					noteGraphic.animation.add('idle', [0, 1, 2, 3, 4, 5, 6, 7], 24);
					noteGraphic.animation.play('idle');
				case 1:
					var graphicPath = ('assets/images/' + FlxG.random.getObject(['Chadvibe', 'Technoskid']) + '.png');
					// trace(graphicPath);
					noteGraphic.loadGraphic('assets/images/' + FlxG.random.getObject(['Chadvibe', 'Technoskid']) + '.png', true, 535, 459);
					noteGraphic.animation.add('idle', [0, 1, 2, 3, 4, 5, 6, 7], 24);
					noteGraphic.animation.play('idle');
			}
		}
        if (holdTime != 0) {
            switch (kind) {
                case 'yunyun':
					sustainSprite = new FlxSprite().makeGraphic(Std.int(Note.NOTE_WIDTH - Note.NOTE_WIDTH / 2),
						Std.int(holdTime * YunYunRhythmState.noteSpeed), FlxColor.LIME);
                case 'muse':
					sustainSprite = new FlxSprite().makeGraphic(Std.int(holdTime * MuseRhythmState.noteSpeed), Std.int(Note.NOTE_WIDTH - NOTE_WIDTH / 2));
			}
            sustainSprite.alpha = .5;
            isSustain =true;
        }
		add(noteGraphic);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
    }
}