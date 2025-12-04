package;

import data.DialogueData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.effects.chainable.FlxOutlineEffect;
import flixel.addons.text.FlxTypeText;
import flixel.addons.ui.FlxButtonPlus;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import haxe.Json;
import openfl.Assets;

using StringTools;
using StringTools;

class PlayState extends FlxState
{

	var startingBranch:String = "start";
	var branches:Map<String, Array<DialogueBlock>> = [];

	var curIdx:Int;
	var curBranch:Array<DialogueBlock>;
	var curBlock:DialogueBlock;
	var curChoices:Array<Choice>;

	var typingSpeedAttrName:String = "typing_speed";
	var defaultTypingSpeed:Float = 0.016;

	var events:Map<String, EventFunc> = [];
	
	var selectingChoices:Bool = false;
	var typingDone:Bool = true;
	
	var bg:FlxSprite;
	var sprites:FlxTypedGroup<FlxSprite>;
	var spriteTags:Map<String, FlxSprite> = [];

	var nameText:FlxText;
	var dialogueText:FlxTypeText;
	var defaultSpriteY:Float = 1000;

	var choiceButtons:FlxTypedSpriteGroup<FlxButtonPlus>;

	var characterTweens:Map<String, FlxTween> = [];

	override public function create()
	{
		FlxG.mouse.useSystemCursor=true;
		super.create();
		branches = getBranches("assets/data/example/example.json");
		curIdx = 0;
		curBranch = branches[startingBranch];
		curBlock = curBranch[curIdx];
		curChoices = curBlock.choices;

		bg = new FlxSprite().makeGraphic(1, 1, FlxColor.TRANSPARENT);
		add(bg);

		nameText = new FlxText(20, 20, 0, curBlock.name, 16);
		dialogueText = new FlxTypeText(20, 60, 0, "", 16);

		dialogueText.completeCallback = dialogueCompleteCallback;

		choiceButtons = new FlxTypedSpriteGroup<FlxButtonPlus>(20, 100);

		sprites = new FlxTypedGroup<FlxSprite>();
		add(sprites);

		add(nameText);
		add(dialogueText);
		add(choiceButtons);

		// Data
		
		registerEvent('set_branch', setBranch);
		registerEvent('set_file', placeholderFunc);

		// Conditional

		registerEvent('gt', placeholderFunc);
		registerEvent('lt', placeholderFunc);
		registerEvent('eq', placeholderFunc);
		registerEvent('neq', placeholderFunc);
		registerEvent('modcnd', placeholderFunc);

		// Visual

		registerEvent('set_bg', setBG);
		registerEvent('add_char', placeholderFunc);
		registerEvent('rm_char', placeholderFunc);
		registerEvent('add_spr', addSpr);
		registerEvent('rm_spr', rmSpr);
		registerEvent('move', moveSpr);
		registerEvent('move_smooth', placeholderFunc);

		// Audio
		registerEvent('set_bgm', setBGM);
		registerEvent('set_bgm_vol', placeholderFunc);
		registerEvent('pause_bgm', pauseBGM);
		registerEvent('play_sound', placeholderFunc);

		registerEvent('rhythm', (args, isChoice) -> {
			if (args[0] == 'yunyun')
			{
			FlxG.switchState(() -> {
					return new YunYunRhythmState(Json.parse(Assets.getText(args[1])));
				});
			}
			else
			{
				FlxG.switchState(() ->
				{
					return new MuseRhythmState(Json.parse(Assets.getText(args[1])));
				});
			}
		});

		runDialogue();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ENTER) {
			progressDialogue();
		}
	}

	function progressDialogue() {
		if (!typingDone) {
			skipDialogue();
		} else if (!selectingChoices && typingDone && curIdx < curBranch.length - 1) {
			curIdx++;
			curBlock = curBranch[curIdx];
			curChoices = curBlock.choices;
			runDialogue();
		}
	}
	
	function skipDialogue() {
		for (char in characterTweens.keys()) {
			characterTweens[char].percent = 1;
		}
		dialogueText.skip();
		typingDone = true;
		showChoices();
	}

	function runDialogue() {
		var typingSpeed:Float = defaultTypingSpeed;
		for (attr in curBlock.attrs) {
			if (attr.name == typingSpeedAttrName) {
				typingSpeed = attr.value;
			}
		}
		nameText.text = curBlock.name;
		dialogueText.resetText(curBlock.text);
		dialogueText.start(typingSpeed);

		for (char in characterTweens.keys()) {
			characterTweens[char].percent = 1;
		}

		for (event in curBlock.events) {
			handleEvent(event, false);
		}
		typingDone = false;
	}

	function showChoices() {
		if (curChoices.length == 0) {
			return;
		}

		selectingChoices = true;

		for (i in 0...curChoices.length) {
			var choice = curChoices[i];

			function onChoiceSelect() {
				handleEvent(choice.event, true);
				for (btn in choiceButtons.members) {
					btn.kill();
				}
				choiceButtons.clear();
				curChoices = [];
				selectingChoices = false;
			}

			var btn = new FlxButtonPlus(i * 100, 0, onChoiceSelect, choice.text);
			choiceButtons.add(btn);
		}
	}

	function handleEvent(ev:DialogueEvent, ?isChoice:Bool = false) {
		for (eventName in events.keys()) {
			var func = events[eventName];
			if (ev.name == eventName) {
				func(ev.args, isChoice);
			}
		}
	}

	function dialogueCompleteCallback() {
		typingDone = true;
		showChoices();
	}

	inline function registerEvent(name:String, func:EventFunc) {
		events.set(name, func);
	}

	function placeholderFunc(args:Array<Dynamic>, isChoice:Bool) {

	}

	function setBranch(args:Array<Dynamic>, isChoice:Bool) {
		if (!isChoice) {
			curIdx = -1;
			curBranch = branches[args[0]];
		} else {
			curIdx = 0;
			curBranch = branches[args[0]];
			curBlock = curBranch[curIdx];
			curChoices = curBlock.choices;
			runDialogue();
		}
	}
	
	function setBG(args:Array<Dynamic>, isChoice:Bool) {
		bg.loadGraphic(args[0]);
	}

	function addSpr(args:Array<Dynamic>, isChoice:Bool) {
		var spr = new FlxSprite(0, defaultSpriteY).loadGraphic(args[0]);
		spriteTags[args[1]] = spr;
		spr.screenCenter();
		if (args.length > 2) {
			switch (args[2]) {
				case 'left':
					spr.x = 0;
				case 'right':
					spr.x = FlxG.width - spr.width;
				case 'center':
					spr.screenCenter(X);
				default:
					if (Std.isOfType(args[2], Float) || Std.isOfType(args[2], Int)) {
						spr.x = args[2];
					}
			}
		}
		if (args.length > 3) {
			trace('gjtkfldj kgfds', args[3]);
			spr.y = args[3];
		}
		sprites.add(spr);
	}

	function rmSpr(args:Array<Dynamic>, isChoice:Bool) {
		var spr = spriteTags[args[0]];
		spr.kill();
		spriteTags.remove(args[0]);
	}

	function moveSpr(args:Array<Dynamic>, isChoice:Bool) {
		var spr = spriteTags[args[0]];
		switch (args[1]) {
			case 'left':
				if (args.length > 3) {
					characterTweens[args[0]] = FlxTween.tween(spr, {x: 0}, args[3]);
				} else {
					spr.x = 0;
				}
			case 'right':
				if (args.length > 3) {
					characterTweens[args[0]] = FlxTween.tween(spr, {x: FlxG.width - spr.width}, args[3]);
				}
				spr.x = FlxG.width - spr.width;
			case 'center':
				if (args.length > 3) {
					characterTweens[args[0]] = FlxTween.tween(spr, {x: FlxG.width / 2 - spr.width}, args[3]);
				} else {
					spr.screenCenter(X);
				}
		}
		if (args.length > 2) {
			spr.y = args[2];
		}
	}

	function setBGM(args:Array<Dynamic>, isChoice:Bool) {
		FlxG.sound.playMusic(args[0]);
	}

	function pauseBGM(args:Array<Dynamic>, isChoice:Bool) {
		FlxG.sound.music.pause();
	}

	function setBGMVol(args:Array<Dynamic>, isChoice:Bool) {	
		if (args.length > 1) {
			FlxTween.tween(FlxG.sound.music, {volume: args[0]}, args[1]);
		} else {
			FlxG.sound.music.volume = args[0];
		}
	}

	function playSound(args:Array<Dynamic>, isChoice:Bool) {
		FlxG.sound.play(args[0]);
	}
	
	function getBranches(filename:String):Map<String, Array<DialogueBlock>> {
		var ret:Map<String, Array<DialogueBlock>> = new Map<String, Array<DialogueBlock>>();
		var obj = Json.parse(Assets.getText(filename));
		var dialogue:Array<Dynamic> = obj.dialogue;
		var branchesList:Array<String> = obj.branches;
		trace(branchesList);

		for (item in dialogue) {
			for (branch in branchesList) {
				if (Reflect.field(item, branch) != null) {
					ret.set(branch, Reflect.field(item, branch));
				}
			}
		}

		return ret;
	}
}
