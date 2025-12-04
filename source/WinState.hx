package;

import flixel.FlxState;

class WinState extends FlxState {

    public var highestCombo:Int;
    public var noteAccuracies:Float;
    public var hitNotes:Int;
    public var score:Float;

    public function new(highestCombo, noteAccuracies, hitNotes, score) {
        super();
    }
}