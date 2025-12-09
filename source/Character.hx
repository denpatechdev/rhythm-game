package;

import flixel.FlxSprite;

class Character extends FlxSprite {
    
    public function new() {
        super();
        loadGraphic('assets/images/spritesheet.png', true, 535, 461);
        animation.add('run', [10,21,32,43,54,65,76,87,98,109,120], 24, true);
        animation.add('up', [6,7,8,9,11,12,13,14,15,16,16,16,16,16], 24, false);
        animation.add('dual', [52,53,55,56,57,58,59,60,61,62,63,64,66,67,68,69,70,71,72,73], true);
        animation.add('down', [106,107,108,110,111,112,112,112,112,112], false);
        run();
    }

    public function run() {

        // if (!animation.exists('run')) {
        //     loadGraphic('assets/images/run.png', true, 535, 459);
        //     animation.add('run', [0,1,2,3,4,5,6,7,8,9,10,11,12,13], 24, true);
        // }
        animation.play('run');
    }

    public function attackUp() {
    // if (!animation.exists('up')) {
    //     loadGraphic('assets/images/air.png', true, 535, 459);
    //     animation.add('up', [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,18,18,18,18], 24, false);
            
    // }
        animation.play('up',true);
    }

    public function attackDown() {
        // if (!animation.exists('down')) {
        //     loadGraphic('assets/images/ground.png', true, 535, 459);
        //     animation.add('down', [0,1,2,3,4,5,6,7,8,9,10,11,12,13,13,13,13,13], 24, false);
        // }
        animation.play('down', true);
    }

    public function attackBoth() {
        // if (!animation.exists('dual')) {
        //     loadGraphic('assets/images/dual.png', true, 535, 459);
        //     animation.add('dual', [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,33,33,33,33], 24, false);
        // }
        animation.play('dual', true);
    }
}