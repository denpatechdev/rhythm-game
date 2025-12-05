package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class PauseMenu extends FlxSubState {
    var screen:FlxSprite;
    var topSpr:FlxSprite;
    var leftSpr:FlxSprite;
    var rightSpr:FlxSprite;
    var bottomSpr:FlxSprite;

    var resumeText:FlxText;
    var exitText:FlxText;

    public function new() {
        super();
        if (FlxG.sound.music != null)
            FlxG.sound.music.pause();
        FlxG.sound.play("assets/sounds/Pause.mp3");
    }

    override function create() {
        screen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.GRAY);
        topSpr = new FlxSprite().makeGraphic(FlxG.width, Math.ceil(FlxG.width / 8), FlxColor.GRAY);
        leftSpr = new FlxSprite().makeGraphic(Math.ceil(FlxG.width / 8), FlxG.height, FlxColor.GRAY);
        bottomSpr = new FlxSprite(0, FlxG.height - FlxG.width / 8).makeGraphic(FlxG.width, Math.ceil(FlxG.width / 8), FlxColor.GRAY);
        rightSpr = new FlxSprite(FlxG.width - FlxG.width / 8, 0).makeGraphic(Math.ceil(FlxG.width / 8), FlxG.height, FlxColor.GRAY);
        super.create();

        add(screen);
        screen.alpha = 0.3;
        add(topSpr);
        add(leftSpr);
        add(bottomSpr);
        add(rightSpr);

        resumeText = new FlxText(leftSpr.x + leftSpr.width + 20, topSpr.y + topSpr.height + 20, 0, "Resume", 32);
        exitText = new FlxText(resumeText.x, resumeText.y + resumeText.height + 20, 0, "Exit to title screen", 32);

        add(resumeText);
        add(exitText);
    }

    var idx:Int = 0;
    var options = ["resume", "exit"];

    override function update(elapsed:Float) {

        if (FlxG.keys.justPressed.UP && idx > 0) {
            idx--;
            FlxG.sound.play("assets/sounds/Select.mp3");
        } else if (FlxG.keys.justPressed.DOWN && idx < options.length - 1) {
            idx++;
            FlxG.sound.play("assets/sounds/Select.mp3");
        }

        if (options[idx] == "resume") {
            resumeText.text = "> Resume";
            exitText.text = "Exit to title screen";
        } else if (options[idx] == "exit") {
            exitText.text = "> Exit to title screen";
            resumeText.text = "Resume";
        }

        if (FlxG.keys.justPressed.ENTER) {
            if (options[idx] == "resume") {
                FlxG.sound.play("assets/sounds/Confirm.mp3", 1, false, null, true, () -> {

                });
                new FlxTimer().start(1, _ -> {
                    close();
                    if (FlxG.sound.music != null)
                        FlxG.sound.music.resume();
                });

            } else if (options[idx] == "exit") {
                FlxG.sound.play("assets/sounds/Confirm.mp3", 1, false, null, true, () -> {
                });
                new FlxTimer().start(1, _ -> {
                    close();
                    FlxG.switchState(PlayState.new);
				});
			}
		}
		super.update(elapsed);
	}

	function textEffect(textObj:FlxText, text)
	{
		for (i in 0...10)
		{
			new FlxTimer().start(i * .1, _ ->
			{
				if (i % 2 == 0)
				{
					textObj.text = text;
				}
				else
				{
					textObj.text = "> " + text;
				}
			});
		}
    }
}