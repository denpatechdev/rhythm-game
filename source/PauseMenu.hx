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
	var restartText:FlxText;
    var exitText:FlxText;

    public function new() {
        super();
        if (FlxG.sound.music != null)
			FlxG.sound.music.pause();
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
		restartText = new FlxText(resumeText.x, resumeText.y + resumeText.height + 20, 0, "Restart", 32);
		exitText = new FlxText(restartText.x, restartText.y + restartText.height + 20, 0, "Return to main menu", 32);

        add(resumeText);
		add(restartText);
        add(exitText);
    }

    var idx:Int = 0;
	var options = ["resume", "restart", "exit"];

	var enterShit = false;

    override function update(elapsed:Float) {

        if (FlxG.keys.justPressed.UP && idx > 0) {
            idx--;
            FlxG.sound.play("assets/sounds/Select.mp3");
        } else if (FlxG.keys.justPressed.DOWN && idx < options.length - 1) {
            idx++;
            FlxG.sound.play("assets/sounds/Select.mp3");
        }

		if (!enterShit)
		{
        if (options[idx] == "resume") {
            resumeText.text = "> Resume";
				restartText.text = "Restart";
            exitText.text = "Exit to title screen";
        } else if (options[idx] == "exit") {
            exitText.text = "> Exit to title screen";
				restartText.text = "Restart";
				resumeText.text = "Resume";
			}
			else if (options[idx] == "restart")
			{
				exitText.text = "Exit to title screen";
				restartText.text = "> Restart";
				resumeText.text = "Resume";
			}
		}

        if (FlxG.keys.justPressed.ENTER) {
			enterShit = true;
            if (options[idx] == "resume") {
				textEffect(resumeText, "Resume");
                FlxG.sound.play("assets/sounds/Confirm.mp3", 1, false, null, true, () -> {

                });
                new FlxTimer().start(1, _ -> {
                    close();
                    if (FlxG.sound.music != null)
                        FlxG.sound.music.resume();
                });

            } else if (options[idx] == "exit") {
				textEffect(exitText, "Exit to main menu");
				FlxG.sound.play("assets/sounds/Confirm.mp3", 1, false, null, true, () -> {});
				new FlxTimer().start(1, _ ->
				{
					close();
					FlxG.switchState(MainMenu.new);
				});
			}
			else if (options[idx] == "restart")
			{
				textEffect(restartText, "Restart");
                FlxG.sound.play("assets/sounds/Confirm.mp3", 1, false, null, true, () -> {
                });
                new FlxTimer().start(1, _ -> {
                    close();
					FlxG.resetState();
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
					textObj.text = "  " + text;
				}
				else
				{
					textObj.text = "> " + text;
				}
			});
		}
    }
}