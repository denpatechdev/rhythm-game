package;

import data.SongData.Song;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import haxe.Json;
import moonchart.formats.Midi;
import moonchart.formats.Quaver;
import moonchart.parsers.MidiParser;
import moonchart.parsers.QuaverParser;
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
        "Bad" => 0
    ];
    var dPressed:Bool;
    var fPressed:Bool;
	var kPressed:Bool;
	var jPressed:Bool;

    public function new(data:Song) {
        super();
        song = data;
        Conductor.bpm = song.bpm;
		FlxG.sound.playMusic(data.songPath);
        stepsInSong = Math.floor((FlxG.sound.music.length / 1000) / (60 / Conductor.bpm )) * 4;
        FlxG.watch.add(this, 'curStep', 'curStep');
        FlxG.watch.add(this, 'curBeat', 'curBeat');
        FlxG.watch.add(this, 'curMeasure', 'curMeasure');

		theText = Assets.getText("assets/data/code.txt").split(' ');
		nextText = theText[0];
        var fuck = [
            "D4" => 3,
            "D#4" => 2,
            "E4" => 1,
            "F4" => 0
        ];
        var jsonShit = Json.parse(Assets.getText("assets/data/VisiPiano.json"));
        notes = [];
        for (i in 0...jsonShit.tracks.length) {
            var track = jsonShit.tracks[i];
            var trackNotes = track.notes;
            for (j in 0...trackNotes.length) {
                var note = trackNotes[j];
                var column = fuck[note.name];
                var duration = note.duration * 1000;
                var time = note.time * 1000;
                if (duration < 250) {
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

    override function create() {
		codeText = new FlxText(20, 20, FlxG.width - 2, "", 16);  
        noteGroup = new FlxTypedGroup<Note>();
		hitBar = new FlxSprite(0, hitY - 20).makeGraphic(FlxG.width, 20);
		add(codeText);
        add(hitBar);
        sustainGroup = new FlxTypedGroup<FlxSprite>();
        add(sustainGroup);
        add(noteGroup);
		keyboardSound.loadEmbedded("assets/sounds/Keyboard.mp3");
		keyboardSound.volume = .35;
        for (note in notes) {
            var n = noteGroup.add(new Note(note.time, note.column, note.holdTime));
            if (note.holdTime > 0) {
                n.isSustain = true;
            }
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

		FlxG.sound.music.onComplete = () ->
		{
			FlxG.switchState(() ->
			{
				new WinState(highestCombo, noteAccuracies, hitNotes, score, ratings);
			});
		}

		FlxG.sound.music.looped = false;

        super.create();
    }

    override function update(elapsed) {

		codeText.updateHitbox();

		if (codeText.height > FlxG.height - 20)
		{
			codeText.text = "";
		}

		#if debug
		if (FlxG.keys.justPressed.ENTER)
		{
			FlxG.switchState(() ->
			{
				new WinState(highestCombo, noteAccuracies, hitNotes, score, ratings);
			});
		}
		#end
        
		if (FlxG.keys.justPressed.ESCAPE)
		{
			openSubState(new PauseMenu());
		}

        dPressed = fPressed = jPressed = kPressed = false;

        noteGroup.forEachAlive((note) -> {
            note.y = hitY + (FlxG.sound.music.time - note.time) * noteSpeed;
            note.x = (FlxG.width / 6) + FlxG.width/6*(note.column);
            if (!note.hit && note.isSustain) {
                note.sustainSprite.x = note.x;
                note.sustainSprite.color = note.color;
				note.sustainSprite.y = (note.y + note.height) - note.sustainSprite.height;
            }
            
            if (!note.hit && Math.abs(FlxG.sound.music.time - note.time) < hitLimit) {
                if (FlxG.keys.justPressed.D && !dPressed) {
                    if (canHitNote(note) && note.column == 0) {
                        if (!note.isSustain) {
                            hitNote(note);
                        } else {
                            holdNoteHit(note);
                        }
                    }
                    dPressed = true;
                }
                if (FlxG.keys.justPressed.F && !fPressed) {
                    if (canHitNote(note) && note.column == 1) {
                        if (!note.isSustain) {
                            hitNote(note);
                            // trace("BYE");
                        } else {
                            // trace("HI AGAIN");
                            holdNoteHit(note);
                        }
                    }
                    fPressed = true;
                }
                if (FlxG.keys.justPressed.J && !jPressed) {
                        if (canHitNote(note) && note.column == 2) {
                        if (!note.isSustain) {
                            hitNote(note);
                            // trace("BYE");
                        } else {
                            // trace("HI AGAIN");
                            holdNoteHit(note);
                        }
                    }
                    jPressed = true;
                }
                if (FlxG.keys.justPressed.K && !kPressed) {
                    if (canHitNote(note) && note.column == 3) {
                        if (!note.isSustain) {
                            hitNote(note);
                            // trace("BYE");
                        } else {
                            // trace("HI AGAIN");
                            holdNoteHit(note);
                        }
                }
                    kPressed = true;
            }
        }

			if (!note.hit && !note.missed && (note.time - FlxG.sound.music.time) < -hitLimit)
			{
				combo = 0;
				health -= 5;
				note.color = FlxColor.GRAY;
				note.canHit = false;
				note.missed = true;
			}
    });

        manageHoldNotesState(elapsed);

		if (health <= 0)
		{
			FlxG.switchState(LoseState.new);
		}

        super.update(elapsed);
    }

    var holdNotes:Array<Note> = [];
    var holdNotesStatus:Map<Note, String> = [];

    function holdNoteHit(note:Note) {
		codeText.text += nextText + ' ';
		codeIdx++;
		nextText = theText[codeIdx];
		FlxG.sound.play("assets/sounds/Key Press.mp3", .5);
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
        holdNotesStatus[note] = "press-"+note.column;
        trace(note, holdNotesStatus[note]);
        trace(holdNotes.contains(note));
		combo++;
    }

	var keyboardSound:FlxSound = new FlxSound();

    function manageHoldNotesState(elapsed:Float) {

        var oldStatus:Map<Note, String> = holdNotesStatus.copy();

        for (note in holdNotes) {
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
                }

				if (!note.missed
					&& note.hit
					&& note.holdTime <= 0
					&& (oldStatus[note] == press(note) && (holdNotesStatus[note] == "pass" || holdNotesStatus[note] == press(note))))
				{
                    trace("WIN");
					if (keyboardSound.playing)
					{
						keyboardSound.stop();
					}
					health += 10;
                    note.kill();
                    if (note.sustainSprite != null)
                        note.sustainSprite.kill();
                    holdNotes.remove(note);
                    return;
                } else if (!note.missed && note.holdTime > 0 && holdNotesStatus[note]=="pass") {
                    trace("MISS LOL");
					health -= 5;
					if (keyboardSound.playing)
					{
						keyboardSound.stop();
					}
                    note.missed=true;
                    note.kill();
                    note.sustainSprite.kill();
                    holdNotes.remove(note);
                    return;
                }
            }
        }
    }

    function canHitNote(note:Note) {
        return Math.abs(FlxG.sound.music.time - note.time) < hitLimit;
    }

    function hitNote(note:Note) {
		codeText.text += nextText + ' ';
		codeIdx++;
		nextText = theText[codeIdx];
        note.hit = true;
        note.kill();
        hitNotes++;
        score += getNoteScore(note);
		FlxG.sound.play("assets/sounds/Key Press.mp3", .5);
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
        return noteAccuracies / (hitLimit * hitNotes);
    }
}