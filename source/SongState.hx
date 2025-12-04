package;

import flixel.FlxG;
import flixel.FlxState;

class SongState extends FlxState {

    public var curStep:Int = 0;
    public var curBeat:Int = 0;
    public var curMeasure:Int = 0;

	public var combo:Int = 0;
	public var highestCombo:Int = 0;


    public function new() {
        super();
    }

    override function create() {
        super.create();
        
    }

    override function update(elapsed:Float) {

        var oldStep = curStep;

        updateCurStep();
        if (curStep != oldStep && curStep > 0) {
            onStep(curStep);
        }

		if (combo > highestCombo)
		{
			highestCombo = combo;
		}

        super.update(elapsed);
    }

    function updateCurStep() {
        curStep = Math.floor(FlxG.sound.music.time / Conductor.getStepCrochet());   
    }

    function onStep(step:Int) {
        if (step % 4 == 0) {
            curBeat++;
            onBeat(Math.floor(step / 4));
        }
    }

    function onBeat(beat:Int) {
        if (beat % 4 == 0) {
            curMeasure++;
            onMeasure(Math.floor(beat % 4));
        }
    }

    @:keep
    function onMeasure(measure:Int) {}
}