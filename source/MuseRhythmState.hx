package;

import data.SongData.Song;
import data.SongData.Song;
import flixel.FlxG;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxColor;
import haxe.Json;
import haxe.Json;
import moonchart.formats.Midi;
import moonchart.formats.Midi;
import moonchart.formats.Quaver;
import moonchart.formats.Quaver;
import moonchart.parsers.MidiParser;
import moonchart.parsers.MidiParser;
import moonchart.parsers.QuaverParser;
import moonchart.parsers.QuaverParser;
import openfl.Assets;
import openfl.Assets;
class MuseRhythmState extends SongState {

    var noteGroup:FlxTypedGroup<Note>;
    var sustainGroup:FlxTypedGroup<FlxSprite>;

    var hitX:Float = FlxG.width / 6;
    var hitBar:FlxSprite;
    public static var noteSpeed:Float = 1;

    public static var song:Song;

    var hitLimit:Float = 210;
    var noteCount:Int;
    var score:Float;
    var noteAccuracies:Float;
    var hitNotes:Int;

    var stepsInSong:Int = 0;
    var ratingText:FlxText;

    var notes:Array<{time:Float, column:Int, holdTime:Float}> = [];


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


		var fuck = [
            "E4" => 1,
            "F4" => 0
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

    override function create() {
        noteGroup = new FlxTypedGroup<Note>();
        hitBar = new FlxSprite(hitX, 0).makeGraphic(20, FlxG.height);
        add(hitBar);
        sustainGroup = new FlxTypedGroup<FlxSprite>();
        add(sustainGroup);
		add(noteGroup);
        for (note in notes) {
            var n = noteGroup.add(new Note(note.time, note.column, 'muse', note.holdTime));
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
				new WinState(highestCombo, noteAccuracies, hitNotes, score);
			});
		}


        super.create();
    }

    override function update(elapsed) {

		if (FlxG.keys.justPressed.ESCAPE)
		{
			openSubState(new PauseMenu());
		}

		dPressed = fPressed = jPressed = kPressed = false;

        noteGroup.forEachAlive((note) -> {
            note.x = hitX - (FlxG.sound.music.time - note.time) * noteSpeed;
			note.y = (FlxG.height / 4) + FlxG.height / 4 * (note.column);
            if (!note.hit && note.isSustain) {
                note.sustainSprite.y = note.y;
                note.sustainSprite.color = note.color;
                note.sustainSprite.x = note.x;
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
				else if (FlxG.keys.justPressed.F && !fPressed)
				{
					if (canHitNote(note) && note.column == 0)
					{
                        if (!note.isSustain) {
                            hitNote(note);
                        } else {
                            holdNoteHit(note);
                        }
                    }
					fPressed = true;
                }
                if (FlxG.keys.justPressed.J && !jPressed) {
					if (canHitNote(note) && note.column == 1)
					{
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
				else if (FlxG.keys.justPressed.K && !kPressed)
				{
					if (canHitNote(note) && note.column == 1)
					{
						if (!note.isSustain)
						{
							hitNote(note);
							// trace("BYE");
						}
						else
						{
							// trace("HI AGAIN");
							holdNoteHit(note);
						}
					}
					jPressed = true;
				}
        }

        if (!note.hit && (note.time - FlxG.sound.music.time) < -hitLimit) {
            note.color = FlxColor.GRAY;
            note.canHit = false;
            note.missed=true;
        }
    });

        manageHoldNotesState(elapsed);

        super.update(elapsed);
    }

    var holdNotes:Array<Note> = [];
    var holdNotesStatus:Map<Note, String> = [];

    function holdNoteHit(note:Note) {
        note.hit = true;
        note.noteGraphic.kill();
        holdNotes.push(note);
		score += getNoteScore(note);
		noteAccuracies += getHitAccuracy(note);
		var diff = note.time - FlxG.sound.music.time;
		note.holdTime += diff;
        holdNotesStatus[note] = "press-"+note.column;
        trace(note, holdNotesStatus[note]);
        trace(holdNotes.contains(note));
    }

    function manageHoldNotesState(elapsed:Float) {

        var oldStatus:Map<Note, String> = holdNotesStatus.copy();

        for (note in holdNotes) {
            if (note.hit && note.alive && note.isSustain) {
                    switch (note.column) {
                        case 0:
						if (FlxG.keys.pressed.D || FlxG.keys.pressed.F)
						{
                                holdNotesStatus[note] = "press-0";
                            } else {
                                holdNotesStatus[note] = "pass";
                            }
                        case 1:
						if (FlxG.keys.pressed.J || FlxG.keys.pressed.K)
						{
							holdNotesStatus[note] = "press-1";
                            }else {
                                holdNotesStatus[note] = "pass";
						}
                    }

                function press(i:Note) {
                    return "press-"+i.column;

                }

                if (holdNotesStatus[note] == press(note)) {
                    note.holdTime -= (elapsed*1000);
                    note.sustainSprite.setGraphicSize(note.holdTime*noteSpeed, Note.NOTE_HEIGHT);
					note.sustainSprite.updateHitbox();
					note.sustainSprite.x = hitX; //- note.sustainSprite.height;
                }

                if (!note.missed && note.hit && note.holdTime <= 0 && (oldStatus[note] == press(note) && (holdNotesStatus[note] == "pass" || holdNotesStatus[note] == press(note)))) {
                    trace("WIN");
                    note.kill();
                    if (note.sustainSprite != null)
                        note.sustainSprite.kill();
                    holdNotes.remove(note);
                    return;
                } else if (!note.missed && note.holdTime > 0 && holdNotesStatus[note]=="pass") {
                    trace("MISS LOL");
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
        note.hit = true;
        note.kill();
        hitNotes++;
        score += getNoteScore(note);
        noteAccuracies += getHitAccuracy(note);
        var rating = Rating.rate(Math.abs(FlxG.sound.music.time - note.time));
        ratings[rating] += 1;
        ratingText.text = rating;
        
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