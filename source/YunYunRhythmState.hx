package;

import data.SongData.Song;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUIBar;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import haxe.Json;
import openfl.Assets;

using StringTools;

class YunYunRhythmState extends SongState {

    var noteGroup:FlxTypedGroup<Note>;
    var sustainGroup:FlxTypedGroup<FlxSprite>;

    var hitY:Float = FlxG.height - FlxG.height / 4;
    var hitBar:FlxSprite;
    public static var noteSpeed:Float = 1;

    public static var song:Song;

    var hitLimit:Float = 210;
	var noteCount:Int = 0;
	var score:Float = 0;
	var noteAccuracies:Float = 0;
	var hitNotes:Int = 0;

    var stepsInSong:Int = 0;
    var ratingText:FlxText;

	var health:Float = 100;

    var notes:Array<{time:Float, column:Int, holdTime:Float}> = [];

	var codeText:FlxText;

	var theText:Array<String>;
	var nextText:String;

    public var ratings:Map<String, Int> = [
        "Perfect" => 0,
        "Marvelous" => 0,
        "Great" => 0,
        "Good" => 0,
        "Ok" => 0,
		"Bad" => 0,
		"Miss" => 0
    ];
    var dPressed:Bool;
    var fPressed:Bool;
	var kPressed:Bool;
	var jPressed:Bool;

    public function new(data:Song) {
        super();
        song = data;
        Conductor.bpm = song.bpm;
		FlxG.sound.playMusic(data.songPath, 1.0, false);
        stepsInSong = Math.floor((FlxG.sound.music.length / 1000) / (60 / Conductor.bpm )) * 4;
        FlxG.watch.add(this, 'curStep', 'curStep');
        FlxG.watch.add(this, 'curBeat', 'curBeat');
        FlxG.watch.add(this, 'curMeasure', 'curMeasure');

		theText = Assets.getText("assets/data/code.txt").split(' ');
		nextText = theText[0];
        var fuck = [
		"F4" => 3, "E4" => 2, "D4" => 1, "C4" => 0
        ];
		var jsonShit = Json.parse(Assets.getText(song.notesPath));
        notes = [];
        for (i in 0...jsonShit.tracks.length) {
            var track = jsonShit.tracks[i];
            var trackNotes = track.notes;
            for (j in 0...trackNotes.length) {
                var note = trackNotes[j];
				var column = fuck[note.name];
                var duration = note.duration * 1000;
                var time = note.time * 1000;
				if (duration <= 250)
				{
                    notes.push({
                        time: time,
						column: column,
                        holdTime: 0
                    });
                } else {
                    notes.push({
                        time: time,
                        column: column,
						holdTime: duration
                    });
                }
            }
        }
    }
    //     notes = [{
    //         time: 1000,
    //         holdTime: 1000,
    //         column: 1
    //     },{
    //         time: 1000,
    //         holdTime: 1000,
    //         column: 0
    //     },{
    //         time: 1000,
    //         holdTime: 1000,
    //         column: 3
    //     },{
    //         time: 1000,
    //         holdTime: 1000,
    //         column: 2
    //     }];
    // }

	var codeTime:Float = .15;
	var codeIdx:Int = 0;
	var codeTimer:Float = 0.0;

	var strumNotes:FlxTypedSpriteGroup<StrumNote>;

    override function create() {
		codeText = new FlxText(20, 20, FlxG.width - 2, "", 32);  
		codeText.color = FlxColor.LIME;
        noteGroup = new FlxTypedGroup<Note>();
		hitBar = new FlxSprite(0, hitY).makeGraphic(FlxG.width, Math.ceil(FlxG.height / 4), 0x8e8e8e);
		strumNotes = new FlxTypedSpriteGroup<StrumNote>();
		add(codeText);
        add(hitBar);
        sustainGroup = new FlxTypedGroup<FlxSprite>();
		add(strumNotes);
		strumNotes.add(new StrumNote(0, hitY, ''));
		strumNotes.screenCenter(X);
        add(sustainGroup);
        add(noteGroup);
		add(new FlxSprite().loadGraphic('assets/images/Terminal2.png'));
		hacker = new FlxSprite(0, 0).loadGraphic('assets/images/floranahacking.png', true, 537, 461);
		hacker.animation.add('idle', [0, 1, 2, 3, 8, 9, 10, 11, 16, 17, 18, 19], 12, true);
		hacker.animation.add('miss', [4, 5, 6, 7, 12, 13, 14, 15, 20, 21, 22, 23], 12, false);
		hacker.animation.play('idle');
		hacker.y = FlxG.height - hacker.height;
		add(hacker);
		keyboardSound.loadEmbedded("assets/sounds/Keyboard.mp3");
        for (note in notes) {
            var n = noteGroup.add(new Note(note.time, note.column, note.holdTime));
            if (note.holdTime > 0) {
                n.isSustain = true;
            }
			n.hit = false;
        }
		FlxG.mouse.useSystemCursor=true;
        noteCount = noteGroup.length;

        ratingText = new FlxText(20, 20, 0, "", 32);
        add(ratingText);

        noteGroup.forEachAlive((note) -> {
            if (note.isSustain) {
                sustainGroup.add(note.sustainSprite);
            }
        });

		if (hacker.animation.curAnim != null && hacker.animation.curAnim.name == 'miss')
		{
			hacker.animation.play('idle');
		}

		FlxG.sound.music.onComplete = () ->
		{
			noteGroup.forEach((n) ->
			{
				if (n.missed)
				{
					ratings["Miss"] = ratings["Miss"] + 1;
				}
			});
			FlxG.switchState(() ->
			{
				return new WinState(highestCombo, getTotalAccuracy(), hitNotes, score, ratings);
			});
		}

		FlxG.sound.music.looped = false;

		var text = new FlxText(0, 0, 0, "3", 54);
		FlxG.sound.music.pause();
		add(text);
		text.screenCenter();
		// noteGroup.forEach(_ ->
		// {
		// 	_.visible = false;
		// });
		// sustainGroup.forEach(_ ->
		// {
		// 	_.visible = false;
		// });
		new FlxTimer().start(1, _ ->
		{
			text.text = "2";
		});
		new FlxTimer().start(2, _ ->
		{
			text.text = "1";
		});
		new FlxTimer().start(3, _ ->
		{
			text.text = "START!";
			text.screenCenter(X);
			FlxG.sound.music.resume();
			gameOn = true;
		});
		new FlxTimer().start(3.3, _ ->
		{
			remove(text);
		});

		ratingText.y = hitY - 64;

        super.create();
		for (note in noteGroup.members)
		{
			note.noteGraphic.visible = true;
			note.y = hitY + (FlxG.sound.music.time - note.time) * noteSpeed;
			note.x = strumNotes.members[0].x + 200 * (note.column);
			if (note.isSustain)
			{
				note.sustainSprite.visible = true;
				note.sustainSprite.x = note.x + Note.NOTE_WIDTH / 4;
				note.sustainSprite.color = note.color;
				note.sustainSprite.y = (note.y + note.height) - note.sustainSprite.height;
			}
		}

		var b = new FlxUIBar(strumNotes.members[0].x, strumNotes.members[0].y + strumNotes.members[0].height + 20, FlxBarFillDirection.LEFT_TO_RIGHT,
			Note.NOTE_WIDTH * 4, 25, this, "health", 0, 100).createColoredFilledBar(FlxColor.LIME);
		add(b);
		b.screenCenter(X);
    }

	var evilMap:Map<Int, Int> = [0 => 0, 1 => 0, 2 => 0, 3 => 0];

	var ratingTimer:Float = 0;

	var gameOn = false;

	var hacker:FlxSprite;

    override function update(elapsed) {

		if (gameOn)
			ratingTimer += elapsed;

		if (ratingTimer > 0.55)
		{
			ratingText.visible = false;
		}
		else
		{
			ratingText.visible = true;
		}

		ratingText.screenCenter(X);
		#if debug
		if (FlxG.keys.justPressed.E)
		{
			FlxG.switchState(new WinState(0, 0, 0, 0, ratings));
		}
		#end

		evilMap = [0 => 0, 1 => 0, 2 => 0, 3 => 0];
		codeText.updateHitbox();

		if (codeText.height > FlxG.height - 20)
		{
			codeText.text = "";
		}

		if (FlxG.keys.justPressed.ESCAPE)
		{
			openSubState(new PauseMenu());
		}
		if (gameOn)
		{
		for (note in noteGroup.members)
		{
            note.y = hitY + (FlxG.sound.music.time - note.time) * noteSpeed;
				note.x = strumNotes.members[0].x + 200 * (note.column);
			if (note.isSustain)
			{
					note.sustainSprite.x = note.x + Note.NOTE_WIDTH / 4;
                note.sustainSprite.color = note.color;
				note.sustainSprite.y = (note.y + note.height) - note.sustainSprite.height;
            }

			if (!note.hit && Math.abs(FlxG.sound.music.time - note.time) < hitLimit)
			{
				if (FlxG.keys.justPressed.J && !jPressed)
				{
					if (canHitNote(note) && note.column == 2 && evilMap[note.column] == 0)
					{
                        if (!note.isSustain) {
                            hitNote(note);
							// trace("BYE");
                        } else {
							// trace("HI AGAIN");
                            holdNoteHit(note);
                        }
                    }
					// jPressed = true;
                }
				if (FlxG.keys.justPressed.K && !kPressed)
				{
					if (canHitNote(note) && note.column == 3 && evilMap[note.column] == 0)
					{
                        if (!note.isSustain) {
                            hitNote(note);
                            // trace("BYE");
                        } else {
                            // trace("HI AGAIN");
                            holdNoteHit(note);
                        }
					}
					// kPressed = true;
				}
				if (FlxG.keys.justPressed.D && !dPressed)
				{
					if (canHitNote(note) && note.column == 0 && evilMap[note.column] == 0)
					{
                        if (!note.isSustain) {
							hitNote(note);
						}
						else
						{
                            holdNoteHit(note);
                        }
                    }
					// dPressed = true;
                }
				if (FlxG.keys.justPressed.F && !fPressed)
				{
					if (canHitNote(note) && note.column == 1 && evilMap[note.column] == 0)
					{
                        if (!note.isSustain) {
                            hitNote(note);
                            // trace("BYE");
                        } else {
                            // trace("HI AGAIN");
                            holdNoteHit(note);
                        }
					}
					// fPressed = true;
				}
			}

			if (!note.hit && !note.missed && (note.time - FlxG.sound.music.time) < -hitLimit)
			{
				combo = 0;
				health -= 5;
				note.color = FlxColor.GRAY;
				note.canHit = false;
				note.missed = true;
					hacker.animation.play('miss', true);
			}
		};
		}

        manageHoldNotesState(elapsed);

		if (health <= 0)
		{
			FlxG.switchState(LoseState.new);
		}
		else if (health > 100)
		{
			health = 100;
		}
		dPressed = false;
		fPressed = false;
		jPressed = false;
		kPressed = false;
		// dPressed = fPressed = jPressed = kPressed = false;

        super.update(elapsed);
    }

    var holdNotes:Array<Note> = [];
    var holdNotesStatus:Map<Note, String> = [];

    function holdNoteHit(note:Note) {
		hacker.animation.play('idle');
		ratingTimer = 0;
		evilMap[note.column] += 1;
		codeText.text += nextText + ' ';
		codeIdx++;
		nextText = theText[codeIdx];
		FlxG.sound.play("assets/sounds/Key Press.mp3");
        note.hit = true;
        note.noteGraphic.kill();
		score += getNoteScore(note);
		noteAccuracies += getHitAccuracy(note);
		var rating = Rating.rate(Math.abs(FlxG.sound.music.time - note.time));
		if (rating != "Bad" || rating != "Ok")
		{
			health += 10;
		}
		ratings[rating] += 1;
		ratingText.text = rating;
		var diff = note.time - FlxG.sound.music.time;
		note.holdTime += diff;
        holdNotes.push(note);
		holdNotesStatus[note] = "press-" + note.column;
		combo++;
    }

	var keyboardSound:FlxSound = new FlxSound();

    function manageHoldNotesState(elapsed:Float) {

        var oldStatus:Map<Note, String> = holdNotesStatus.copy();
		var notesToRemove = [];
		for (note in holdNotes)
		{
            if (note.hit && note.alive && note.isSustain) {
                    switch (note.column) {
                        case 0:
                            if (FlxG.keys.pressed.D) {
                                holdNotesStatus[note] = "press-0";
                            } else {
                                holdNotesStatus[note] = "pass";
                            }
                        case 1:
                            if (FlxG.keys.pressed.F) {
                                holdNotesStatus[note] = "press-1";
                            }else {
                                holdNotesStatus[note] = "pass";
                            }
					case 2:
                            if (FlxG.keys.pressed.J) {
                                holdNotesStatus[note] = "press-2";
                            } else {
                                holdNotesStatus[note] = "pass";
                            }
					case 3:
                            if (FlxG.keys.pressed.K) {
                                holdNotesStatus[note] = "press-3";
                            }else {
                                holdNotesStatus[note] = "pass";
                            }
                    }

                function press(i:Note) {
                    return "press-"+i.column;

                }

                if (holdNotesStatus[note] == press(note)) {
                    note.holdTime -= (elapsed*1000);
                    note.sustainSprite.setGraphicSize(note.sustainSprite.width, note.holdTime*noteSpeed);
                    note.sustainSprite.updateHitbox();
					keyboardSound.play(false);
					note.sustainSprite.y = hitY - note.sustainSprite.height;
					codeTimer += elapsed;
					if (codeTimer >= codeTime)
					{
						codeText.text += nextText + ' ';
						codeIdx++;
						nextText = theText[codeIdx];
						codeTimer = 0;
					}
					ratingTimer = 0;
                }

				if (!note.missed
					&& note.hit
					&& note.holdTime <= 0
					&& (oldStatus[note] == press(note) && (holdNotesStatus[note] == "pass" || holdNotesStatus[note] == press(note))))
				{
					if (keyboardSound.playing)
					{
						keyboardSound.stop();
					}
					health += 10;
					note.kill();
					if (note.sustainSprite != null)
						note.sustainSprite.kill();
					notesToRemove.push(note);
				}
				else if (!note.missed && holdNotesStatus[note] == "pass")
				{
					if (note.holdTime > 210)
					{
						if (keyboardSound.playing)
						{
							keyboardSound.stop();
						}
						else
							health += 10;
						note.kill();
						if (note.sustainSprite != null)
							note.sustainSprite.kill();
						notesToRemove.push(note);
					}
					else
					{
					health -= 5;
						hacker.animation.play('miss', true);
					if (keyboardSound.playing)
					{
						keyboardSound.stop();
					}
                    note.missed=true;
                    note.kill();
                    note.sustainSprite.kill();
					notesToRemove.push(note);
                }
				}
			}
        }
		for (i in notesToRemove)
		{
			holdNotes.remove(i);
			holdNotesStatus.remove(i);
		}
        
    }

    function canHitNote(note:Note) {
        return Math.abs(FlxG.sound.music.time - note.time) < hitLimit;
    }

    function hitNote(note:Note) {
		hacker.animation.play('idle');
		ratingTimer = 0;
		evilMap[note.column] += 1;
		codeText.text += nextText + ' ';
		codeIdx++;
		nextText = theText[codeIdx];
		note.hit = true;
		note.noteGraphic.kill();
        hitNotes++;
        score += getNoteScore(note);
		FlxG.sound.play("assets/sounds/Key Press.mp3");
        noteAccuracies += getHitAccuracy(note);
        var rating = Rating.rate(Math.abs(FlxG.sound.music.time - note.time));
        ratings[rating] += 1;
        ratingText.text = rating;

		combo++;
    }

    function getNoteScore(note:Note) {
        return Math.abs(note.time - hitLimit);
    }

    function getHitAccuracy(note:Note) {
        return Math.abs(note.time - hitLimit) / hitLimit;
    }

    function getHitNotesRatio() {
        return hitNotes / noteCount;
    }

    function getTotalAccuracy() {
		return noteAccuracies / (hitLimit * noteCount);
    }
}