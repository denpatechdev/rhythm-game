package;

import flixel.FlxState;

class Conductor {
    public static var bpm:Int = 147;
    public static function getCrochet() { return (60 / bpm) * 1000; }
    public static function getStepCrochet() { return getCrochet() / 4; }
}